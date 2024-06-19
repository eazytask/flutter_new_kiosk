import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kiosk/src/core/constants/app_strings.dart';
import 'package:kiosk/src/core/constants/constants.dart';
import 'package:kiosk/src/core/domain/entities/project.entity.dart';
import 'package:kiosk/src/core/presentation/widgets/app_bar.widget.dart';
import 'package:kiosk/src/core/presentation/widgets/loading_overlay.dart';
import 'package:kiosk/src/core/presentation/widgets/wave_loading.widget.dart';
import 'package:kiosk/src/feature/authentication/presentation/providers/auth.provider.dart';
import 'package:kiosk/src/feature/client_connection/presentation/providers/client.provider.dart';
import 'package:kiosk/src/feature/employees/data/models/check_pin_request.model.dart';
import 'package:kiosk/src/feature/employees/data/models/get_employee_request.model.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/feature/employees/domain/entities/employee.entity.dart';
import 'package:kiosk/src/feature/employees/presentation/providers/employee.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk/src/feature/home/presentation/screens/start_unscheduled_shift.screen.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/employeelist_data.dart';
import '../../../../core/constants/mainbutton.dart';
import '../../../../core/router/route.constants.dart';

class EmployeeScreen extends StatefulWidget {
  final String? projectId;
  final String? projectName;

  const EmployeeScreen({
    Key? key,
    this.projectId,
    this.projectName,
  }) : super(key: key);

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  bool loaded = false;
  bool submit = false;
  final _fromTop = true;
  String? _selectedProjectId;
  String? _selectedProjectName;
  List<Project> projects = [];
  List<String> empFilter = ['all', 'shift', 'inducted'];
  String? _selectedEmpFilter;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> fetchProjects() async {
    if (!mounted) return;
    var baseUrl = context.read<ClientConnectionProvider>().baseUrl;
    return await context
        .read<EmployeeProvider>()
        .fetchProject(
            context,
            baseUrl,
            CommonGetRequest(
                authToken: context.read<AuthProvider>().authToken!))
        .whenComplete(() async {
      setState(() {
        projects = context.read<EmployeeProvider>().projects;
        if(widget.projectId == null) {
          _selectedProjectId = projects.first.id.toString();
        }else{
          _selectedProjectId = widget.projectId;
        }

        if(widget.projectName == null) {
          _selectedProjectName = projects.first.projectName;
        }else{
          _selectedProjectName = widget.projectName;
        }
      });
      Future.microtask(() async => await fetchEmployees());
    });
  }

  Future<void> fetchEmployees() async {
    if (!mounted) return;
    var baseUrl = context.read<ClientConnectionProvider>().baseUrl;
    return await context
        .read<EmployeeProvider>()
        .fetchEmployee(
            context,
            baseUrl,
            GetEmployeeRequest(
                projectId: _selectedProjectId ?? projects.first.id.toString(),
                employeeFilter: _selectedEmpFilter ?? 'all',
                authToken: context.read<AuthProvider>().authToken!))
        .whenComplete(() {
      emp = context.read<EmployeeProvider>().employees;
      setState(() {
        loaded = true;
      });
    });
  }

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  bool _searchBoolean = false;
  List<Employee> emp = [];

  Widget _searchTextField() {
    return TextFormField(
      onChanged: (text) {
        text = text.toLowerCase();
        setState(() {
          emp = context.read<EmployeeProvider>().employees.where((item) {
            var name =
                '${item.fName?.toLowerCase()} ${item.mName?.toLowerCase()} ${item.lName?.toLowerCase()}';
            return name.contains(text);
          }).toList();
        });
      },
      focusNode: focusNode,
      autofocus: true,
      controller: _searchController,
      cursorColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Search',
        hintStyle: TextStyle(
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
    );
  }

  Future<void> checkPin(int empId, Employee employee) async {
    showSendingProgressBar();
    setState(() {
      submit = true;
    });
    print(_pinController.text.trim());
    if (!mounted) return;
    var baseUrl = context.read<ClientConnectionProvider>().baseUrl;
    context
        .read<EmployeeProvider>()
        .checkPin(
          context,
          baseUrl,
          CheckPinRequest(
            projectId: int.parse(_selectedProjectId ?? '0'),
            employeeId: empId,
            authToken: context.read<AuthProvider>().authToken ?? "",
            pin: _pinController.text.trim(),
          ),
          employee,
          int.parse(_selectedProjectId ?? '0'),
          _selectedProjectName ?? '-',
        )
        .whenComplete(() {
      setState(() {
        _pinController.clear();
        submit = false;
      });
      hideSendingProgressBar();
    });
  }

  final ProgressBar _sendingMsgProgressBar = ProgressBar();

  @override
  void dispose() {
    _sendingMsgProgressBar.hide();
    super.dispose();
  }

  void showSendingProgressBar() {
    _sendingMsgProgressBar.show(context);
  }

  void hideSendingProgressBar() {
    _sendingMsgProgressBar.hide();
  }

  @override
  void initState() {
    Future.microtask(() async => await fetchProjects());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //     appBar: AppBarWidget(
    //       title: !_searchBoolean
    //           ? const Text('Select Employee', style: TextStyle(color: Colors.white),)
    //           : _searchTextField(),
    //       leading: Consumer(builder: (context, AuthProvider provider, _) {
    //         if (provider.isBusy) {
    //           return const Center(
    //             child: SizedBox(
    //               height: 20,
    //               width: 20,
    //               child: CircularProgressIndicator(
    //                 color: Colors.white,
    //                 strokeWidth: 3,
    //               ),
    //             ),
    //           );
    //         }
    //         return IconButton(
    //           onPressed: () {
    //             var baseUrl = context.read<ClientConnectionProvider>().baseUrl;
    //             context.read<AuthProvider>().logout(context, baseUrl);
    //           },
    //           icon: const Icon(
    //             Icons.logout_rounded,
    //             color: Colors.white,
    //           ),
    //         );
    //       }),
    //       actions: context.watch<EmployeeProvider>().employees.isNotEmpty
    //           ? !_searchBoolean
    //               ? [
    //                   IconButton(
    //                       icon: const Icon(Icons.search, color: Colors.white,),
    //                       onPressed: () {
    //                         setState(() {
    //                           _searchBoolean = true;
    //                         });
    //                       })
    //                 ]
    //               : [
    //                   IconButton(
    //                       icon: const Icon(Icons.clear, color: Colors.white),
    //                       onPressed: () {
    //                         setState(() {
    //                           _searchBoolean = false;
    //                           _searchController.clear();
    //                           emp = context.read<EmployeeProvider>().employees;
    //                         });
    //                       })
    //                 ]
    //           : [],
    //     ),
    //     body:
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: Container(
              height: 100,
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black45)),
              child: BottomAppBar(
                elevation: 0,
                color: Colors.white,
                notchMargin: 0.9,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Future.microtask(() => Navigator.pushNamedAndRemoveUntil(
                              context, RouteConstants.projectScreen, (_) => false,
                              arguments: "Empty"));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              'assets/png/home-line.png',
                              color: Color(0xff999999)
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            const Text(
                              'Home',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff999999)),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Future.microtask(() => Navigator.pushNamedAndRemoveUntil(
                              context, RouteConstants.employeeScreen, (_) => false,
                              arguments: "Empty"));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              'assets/png/user-03.png',
                              color: Color(0xff3498DB)
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            const Text(
                              'User',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xff3498DB)),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          var baseUrl =
                              context.read<ClientConnectionProvider>().baseUrl;
                          context.read<AuthProvider>().logout(context, baseUrl);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              'assets/png/Icon.png',
                              color: Color(0xff999999)
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            const Text(
                              'Log Out',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xff999999)),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  loaded = false;
                  _selectedEmpFilter = empFilter.first;
                });
                Future.microtask(() async => await fetchProjects());

                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Future.microtask(() => Navigator.pushNamedAndRemoveUntil(
                                context, RouteConstants.projectScreen, (_) => false,
                                arguments: "Empty"));
                          },
                          child: SvgPicture.asset(
                            'assets/png/Frame 1000005539.svg',
                            height: 45,
                            width: 45,
                          ),
                        ),
                        const Text(
                          'Select Employee',
                          style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        SvgPicture.asset(
                          'assets/png/Frame 1000005570.svg',
                          height: 45,
                          width: 45,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      // height: 60,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        // color: Color(0xffE4DFDF).withOpacity(0.2),
                      ),
                      child: TextFormField(
                        onChanged: (text) {
                          text = text.toLowerCase();
                          setState(() {
                            emp = context.read<EmployeeProvider>().employees.where((item) {
                              var name =
                                  '${item.fName?.toLowerCase()} ${item.mName?.toLowerCase()} ${item.lName?.toLowerCase()}';
                              return name.contains(text);
                            }).toList();
                          });
                        },
                        style: const TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          enabled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xff2ECC71),
                            ),
                          ),
                          disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff2ECC71))),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Color(0xff2ECC71)),
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 16,
                          ),
                          border: InputBorder.none,
                          hintText: 'Search employee',
                          prefixIcon: const Icon(
                            Icons.search_outlined,
                            size: 28,
                          ),
                          hintStyle: const TextStyle(
                              color: Colors.black45,
                              fontSize: 17,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                            Container(
                            height: 43,
                            width: 230,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xffF96B07).withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/png/elements.svg',
                                  height: 25,
                                  width: 25,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Future.microtask(() => Navigator.pushNamedAndRemoveUntil(
                                        context, RouteConstants.projectScreen, (_) => false,
                                        arguments: "Empty"));
                                  },
                                  child: Text(
                                    _selectedProjectName ?? '-',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xffF96B07),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: loaded,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // projects.isNotEmpty
                            //     ? Visibility(
                            //         visible: projects.isNotEmpty,
                            //         child: DropdownButtonHideUnderline(
                            //           child: DropdownButton<String>(
                            //             hint: const Text('Select Site'),
                            //             value: _selectedProjectId ??
                            //                 projects.first.id.toString(),
                            //             // underline: Divider(color: appColor, height: 3),
                            //             icon: const Icon(
                            //                 Icons.arrow_drop_down_outlined),
                            //             onChanged: (value) {
                            //               setState(() {
                            //                 _selectedProjectId = value!;
                            //                 _selectedProjectName = projects
                            //                     .singleWhere((element) =>
                            //                         element.id.toString() ==
                            //                         value)
                            //                     .projectName;
                            //                 _searchBoolean = false;
                            //                 _searchController.clear();
                            //               });
                            //
                            //               Future.microtask(() async =>
                            //                   await fetchEmployees());
                            //             },
                            //             items: projects.map((value) {
                            //               return DropdownMenuItem<String>(
                            //                 value: value.id.toString(),
                            //                 child:
                            //                     Text(value.projectName ?? ''),
                            //               );
                            //             }).toList(),
                            //           ),
                            //         ),
                            //       )
                            //     : const SizedBox(),
                            // DropdownButtonHideUnderline(
                            //   child: DropdownButton<String>(
                            //     hint: const Text('Select Site'),
                            //     value: _selectedEmpFilter ?? empFilter.first,
                            //     // underline: Divider(color: appColor, height: 3),
                            //     icon:
                            //         const Icon(Icons.arrow_drop_down_outlined),
                            //     onChanged: (value) {
                            //       setState(() {
                            //         _selectedEmpFilter = value!;
                            //         _searchBoolean = false;
                            //         _searchController.clear();
                            //       });
                            //
                            //       Future.microtask(
                            //           () async => await fetchEmployees());
                            //     },
                            //     items: empFilter.map((value) {
                            //       return DropdownMenuItem<String>(
                            //         value: value,
                            //         child: Text(value ?? ''),
                            //       );
                            //     }).toList(),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Consumer(
                      builder: (context, EmployeeProvider provider, _) {
                        var employees = provider.employees;

                        if ((employees.isEmpty && !provider.isBusy) ||
                            (emp.isEmpty && !provider.isBusy)) {
                          return SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2.5 / 4,
                            child: const Center(
                              child: Text('No Employees'),
                            ),
                          );
                        }
                        if (provider.isBusy) {
                          return SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 3 / 4,
                              child: const Center(
                                  child: CircularProgressIndicator()));
                        }
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: emp.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return InkWell(
                                      onTap: () {
                                        alertBox(emp[index]);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Container(
                                          height: 85,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                                width: 0.5, color: const Color(0xff6EC2FA)),
                                            color: Colors.white,
                                          ),
                                          child: Padding(
                                            padding:
                                            const EdgeInsets.only(left: 15, right: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    CachedNetworkImage(
                                                      imageUrl: emp[index].image ?? '',
                                                      width: 75, // Set a fixed width for the image
                                                      height: 75, // Set a fixed height for the image
                                                      progressIndicatorBuilder: (context, url, downloadProgress) {
                                                        return Center(
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: CircularProgressIndicator(
                                                              value: downloadProgress.progress,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      fit: BoxFit.cover, // Adjust the fit based on your preference
                                                      errorWidget: (context, url, error) {
                                                        final iconSize = 28.0;
                                                        return Icon(
                                                          Icons.person,
                                                          color: Colors.grey,
                                                          size: iconSize,
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          '${emp[index].fName ?? ""} ${emp[index].mName != null ? emp[index].mName! + " " : ""}${emp[index].lName ?? ""}',
                                                          style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight: FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        Text(
                                                          emp[index].contactNumber ?? '-',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  emp[index].licenseNo ?? '-',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                              const SizedBox(
                                height: 30,
                              ),



                              // const SizedBox(
                              //   height: 10,
                              // ),
                              // ListView.builder(
                              //   shrinkWrap: true,
                              //   itemCount: emp.length,
                              //   physics: const ScrollPhysics(),
                              //   itemBuilder: (context, index) {
                              //     return Padding(
                              //       padding: const EdgeInsets.symmetric(
                              //           horizontal: 8, vertical: 4),
                              //       child: Container(
                              //         decoration: BoxDecoration(
                              //             color: Theme.of(context)
                              //                 .primaryColor
                              //                 .withOpacity(.09),
                              //             borderRadius:
                              //                 BorderRadius.circular(10)),
                              //         child: ListTile(
                              //           onTap: () {
                              //             showDialog(
                              //                 barrierDismissible: false,
                              //                 context: context,
                              //                 builder: (BuildContext context) {
                              //                   return AlertDialog(
                              //                     shape: RoundedRectangleBorder(
                              //                       borderRadius:
                              //                           BorderRadius.circular(
                              //                               10),
                              //                     ),
                              //                     title: Text(
                              //                         emp[index].fName ?? '-'),
                              //                     content: TextFormField(
                              //                       controller: _pinController,
                              //                       decoration:
                              //                           const InputDecoration(
                              //                               labelText: 'Pin'),
                              //                       inputFormatters: [
                              //                         FilteringTextInputFormatter
                              //                             .digitsOnly
                              //                       ],
                              //                       keyboardType:
                              //                           TextInputType.number,
                              //                     ),
                              //                     actionsAlignment:
                              //                         MainAxisAlignment
                              //                             .spaceAround,
                              //                     actions: <Widget>[
                              //                       StatefulBuilder(builder:
                              //                           (context, setState) {
                              //                         return Row(
                              //                           mainAxisAlignment:
                              //                               MainAxisAlignment
                              //                                   .spaceEvenly,
                              //                           children: [
                              //                             submit
                              //                                 ? const SizedBox(
                              //                                     height: 16,
                              //                                     width: 16,
                              //                                     child:
                              //                                         CircularProgressIndicator(),
                              //                                   )
                              //                                 : TextButton(
                              //                                     child: const Text(
                              //                                         "Submit"),
                              //                                     onPressed:
                              //                                         () {
                              //                                       checkPin(
                              //                                         emp[index]
                              //                                                 .id ??
                              //                                             0,
                              //                                         emp[index],
                              //                                       );
                              //                                       Navigator.of(
                              //                                               context)
                              //                                           .pop();
                              //                                     },
                              //                                   ),
                              //                             TextButton(
                              //                               child: const Text(
                              //                                 'Cancel',
                              //                                 style: TextStyle(
                              //                                   color:
                              //                                       Colors.red,
                              //                                 ),
                              //                               ),
                              //                               onPressed: () {
                              //                                 Navigator.of(
                              //                                         context)
                              //                                     .pop(false);
                              //                               },
                              //                             ),
                              //                           ],
                              //                         );
                              //                       }),
                              //                     ],
                              //                   );
                              //                 });
                              //           },
                              //           leading: CircleAvatar(
                              //               radius: 20,
                              //               backgroundColor:
                              //                   Theme.of(context).primaryColor,
                              //               child: CircleAvatar(
                              //                 radius: 18,
                              //                 child: Container(
                              //                   width: 86,
                              //                   clipBehavior: Clip.hardEdge,
                              //                   decoration: const BoxDecoration(
                              //                       shape: BoxShape.circle),
                              //                   child: CachedNetworkImage(
                              //                     imageUrl:
                              //                         emp[index].image ?? '',
                              //                     progressIndicatorBuilder:
                              //                         (context, url,
                              //                             downloadProgress) {
                              //                       return Center(
                              //                         child: Padding(
                              //                           padding:
                              //                               const EdgeInsets
                              //                                   .all(8.0),
                              //                           child:
                              //                               CircularProgressIndicator(
                              //                             value:
                              //                                 downloadProgress
                              //                                     .progress,
                              //                           ),
                              //                         ),
                              //                       );
                              //                     },
                              //                     fit: BoxFit.cover,
                              //                     errorWidget:
                              //                         (context, url, error) =>
                              //                             const Icon(
                              //                       Icons.person,
                              //                       color: Colors.grey,
                              //                       size: 28,
                              //                     ),
                              //                   ),
                              //                 ),
                              //               )),
                              //           title: Text(emp[index].fName ?? '-'),
                              //           trailing: const Icon(Icons.arrow_right),
                              //           subtitle: Column(
                              //             crossAxisAlignment:
                              //                 CrossAxisAlignment.start,
                              //             children: [
                              //               Text(
                              //                 emp[index].contactNumber ?? '',
                              //                 style: TextStyle(
                              //                   fontSize: 12,
                              //                   color: Theme.of(context)
                              //                               .brightness ==
                              //                           Brightness.dark
                              //                       ? Colors.grey.shade300
                              //                       : Colors.grey,
                              //                 ),
                              //               ),
                              //               Text(
                              //                 '#${emp[index].licenseNo}',
                              //                 style: TextStyle(
                              //                   fontSize: 12,
                              //                   color: Theme.of(context)
                              //                               .brightness ==
                              //                           Brightness.dark
                              //                       ? Colors.grey.shade300
                              //                       : Colors.grey,
                              //                 ),
                              //               ),
                              //               const SizedBox(
                              //                 height: 5,
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //     );
                              //   },
                              // )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )));
  }

  alertBox(Employee theemployee) {
    showGeneralDialog(
        barrierDismissible: true,
        barrierLabel:
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(
                begin: Offset(0, _fromTop ? -1 : 1),
                end: const Offset(0, 0))
                .animate(anim1),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        barrierColor: Colors.black26,
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Container(
              child: Dialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                // backgroundColor: Colors.black,
                child: Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        color: Colors.white),
                    height: 475,
                    width: 430,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              CachedNetworkImage(
                                imageUrl: theemployee.image ?? '',
                                width: 90, // Set a fixed width for the image
                                height: 90, // Set a fixed height for the image
                                progressIndicatorBuilder: (context, url, downloadProgress) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        value: downloadProgress.progress,
                                      ),
                                    ),
                                  );
                                },
                                fit: BoxFit.cover, // Adjust the fit based on your preference
                                errorWidget: (context, url, error) {
                                  final iconSize = 28.0;
                                  return Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: iconSize,
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                '${theemployee.fName}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff46A0DD),
                                ),
                              ),
                              const SizedBox(
                                height: 33,
                              ),
                              const Text(
                                'Enter Your Pin',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff46A0DD),
                                ),
                              ),
                              OtpTextField(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // obscureText: true,
                                cursorColor: const Color(0xff6EC2FA),
                                enabledBorderColor: const Color(0xff6EC2FA),
                                margin: const EdgeInsets.all(7),
                                borderWidth: 2,

                                textStyle: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w500),
                                numberOfFields: 4,
                                enabled: true,
                                borderColor: const Color(0xff6EC2FA),
                                disabledBorderColor: const Color(0xff6EC2FA),
                                focusedBorderColor: const Color(0xff6EC2FA),
                                showFieldAsBox: false,

                                // filled: true,

                                fieldWidth: 66,

                                onCodeChanged: (String code) {
                                  // Update the value of _pinController when the code changes

                                  // You can also perform any validation or checks here if needed
                                },
                                onSubmit: (String verificationCode) {
                                  _pinController.text = verificationCode;
                                  // showDialog(
                                  //     context: context,
                                  //     builder: (context){
                                  //       return AlertDialog(
                                  //               title: const Text("Verification Code"),
                                  //               content: Text('Code entered is $verificationCode'),
                                  //       );
                                  //     }
                                  // );
                                }, // end onSubmit
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Button(
                                    height: 34,
                                    width: 144,
                                    child: const Center(
                                      child: Text(
                                        'Ok',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      checkPin(
                                        theemployee.id ?? 0,
                                        theemployee,
                                      );
                                      Navigator.of(
                                              context)
                                          .pop();
                                    },
                                    colorB: const Color(0xff6EC2FA)),
                                const SizedBox(
                                  width: 5,
                                ),
                                Button(
                                    height: 34,
                                    width: 144,
                                    child: const Center(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    colorB: const Color(0xff999999)),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
              ),
            );
          });
        });
  }
}