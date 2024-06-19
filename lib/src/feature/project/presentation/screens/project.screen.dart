import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:provider/provider.dart';

import '../../../../core/router/route.constants.dart';
import '../../../authentication/presentation/screens/authentication.screen.dart';
import '../../../employees/presentation/screens/employee.screen.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  bool loaded = false;
  bool submit = false;
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
        _selectedProjectId = projects.first.id.toString();
        _selectedProjectName = projects.first.projectName;
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
                      Image.asset('assets/png/home-line.png',
                          color: Color(0xff3498DB)),
                      const SizedBox(
                        height: 6,
                      ),
                      const Text(
                        'Home',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xff3498DB)),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Future.microtask(() => Navigator.pushNamedAndRemoveUntil(
                        context, RouteConstants.employeeScreen, (_) => false));
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset('assets/png/user-03.png',
                          color: Color(0xff999999)),
                      const SizedBox(
                        height: 6,
                      ),
                      const Text(
                        'User',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xff999999)),
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
                      Image.asset('assets/png/Icon.png',
                          color: Color(0xff999999)),
                      const SizedBox(
                        height: 6,
                      ),
                      const Text(
                        'Log Out',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xff999999)),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  const Text(
                    'Select Project',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => EmployeeScreen()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    projects.isNotEmpty
                        ? Visibility(
                      visible: projects.isNotEmpty,
                      child: Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: projects.length,
                          physics: const ScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  RouteConstants.employeeScreen,
                                  arguments: {
                                    'projectName': projects[index].projectName,
                                    'projectId': projects[index].id.toString(),
                                  },
                                );
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => EmployeeScreen()),
                                // );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    // onTap: () {
                                    //   Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(builder: (context) => LoginScreen()),
                                    //   );
                                    // },
                                    child: SvgPicture.asset(
                                      'assets/png/elements.svg',
                                      height: 25,
                                      width: 25,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '${projects[index].projectName}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xffF96B07),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 35,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                        : const SizedBox(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
