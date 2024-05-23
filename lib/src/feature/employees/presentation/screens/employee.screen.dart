import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kiosk/src/core/constants/app_strings.dart';
import 'package:kiosk/src/core/constants/constants.dart';
import 'package:kiosk/src/core/domain/entities/project.entity.dart';
import 'package:kiosk/src/core/domain/entities/shift.details.entity.dart';
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


import 'package:kiosk/src/feature/projects/presentation/provider/selected.project.dart';
import '../../../../../constants/mainbutton.dart';
import '../../../../core/domain/entities/job_type.entity.dart';
import '../../../home/presentation/providers/home.provider.dart';
import '../../../projects/project.screen.dart';
import 'package:kiosk/src/core/presentation/widgets/bottom_nav_bar.dart';

class EmployeeScreen extends StatefulWidget {
  final String filterType;

  const EmployeeScreen({this.filterType = 'shift', super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  bool loaded = false;
  bool otpBoxDisabled = false;
  bool submit = false;
  final _fromTop = true;
  String? _selectedProjectId;
  String? _selectedProjectName;
  List<Project> projects = [];
  List<String> empFilter = ['all', 'shift', 'inducted'];
  List<JobType> jobTypes = [];
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
                projectId: _selectedProjectId ?? "",
                employeeFilter: _selectedEmpFilter ?? "shift",
                authToken: context.read<AuthProvider>().authToken!))
        .whenComplete(() {
      // emp = context.read<EmployeeProvider>().employees;

      setState(() {
        loaded = true;
        emp = context.read<EmployeeProvider>().employees;
      });
    });
  }

  Future<void> fetchJobTypes() async {
    if (!mounted) return;
    var baseUrl = context.read<ClientConnectionProvider>().baseUrl;
    return await context
        .read<HomeProvider>()
        .fetchJobType(
        context,
        baseUrl,
        CommonGetRequest(
            authToken: context.read<AuthProvider>().authToken!))
        .whenComplete(() async {
      setState(() {
        jobTypes = context.read<HomeProvider>().jobTypes;
      });
    });
  }

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  List<Employee> emp = [];

  alertBox(int employeeIndex) {
    // print(emp[employeeIndex]);

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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10000.0),
                                child: CachedNetworkImage(
                                  height: 90,
                                  width: 90,

                                  imageUrl: emp[employeeIndex].image ?? '',
                                  progressIndicatorBuilder:
                                      (context, url,
                                      downloadProgress) {
                                    return Center(
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            8.0),
                                        child:
                                        CircularProgressIndicator(
                                          value: downloadProgress
                                              .progress,
                                        ),
                                      ),
                                    );
                                  },
                                  fit: BoxFit.cover,
                                  errorWidget:
                                      (context, url, error) =>
                                  const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 28,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                emp[employeeIndex].fName ?? '',
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
                                autoFocus: true,
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

                                fieldWidth: 50,

                                onCodeChanged: (String code) {
                                  //handle validation or checks here
                                },
                                onSubmit: (String verificationCode) {
                                  checkPin(
                                      emp[employeeIndex].id ?? 0,
                                      emp[employeeIndex],
                                      verificationCode
                                  );

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
                                    width: 100,
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
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             TaskScreen()));
                                    },
                                    colorB: const Color(0xff6EC2FA)),
                                const SizedBox(
                                  width: 5,
                                ),
                                Button(
                                    height: 34,
                                    width: 100,
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
  Future<void> checkPin(int empId, Employee employee,String verificationCode) async {
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
            pin: verificationCode,
          ),
          employee,
          int.parse(_selectedProjectId ?? '0'),
          _selectedProjectName ?? '-',
        )
        .whenComplete(() {
      setState(() {
        // _pinController.clear();
        submit = false;
      });
      hideSendingProgressBar();
    });
  }

  String getShiftTimeString(DateTime startTime, DateTime endTime){
    var result = "";
    result += DateFormat.Hm().format(startTime);
    result += ' to ';
    result += DateFormat.Hm().format(endTime);
    return result;
  }

  Color getBackgroundColor(List<ShiftDetails> shiftDetails){
    var result = Colors.transparent;
    var now  = DateTime.now();

    if(shiftDetails.isNotEmpty){

      var shiftDetail = shiftDetails[0];
      if(shiftDetail.singOut == null && shiftDetail.singIn != null){
        if(now.isAfter(shiftDetail.shiftEnd as DateTime)){
          result = Colors.redAccent;
        }
      }
      else if(shiftDetail.singIn != null){
        result = Colors.greenAccent;
      }
      else if(shiftDetail.singIn == null){
        if(shiftDetail.shiftStart!.isBefore(now)){
          result = Colors.redAccent;
        }
      }

    }
    return result;
  }


  String getJobTypeNname(int jobTypeId){
    var result = "";
    if(jobTypeId > 0){
      var jobType = jobTypes.firstWhere((element) => element.id == jobTypeId);
      result = jobType.name ?? "";
    }
    return result;
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
    context.read<SelectedProjectProvider>().loadValue().whenComplete(() {
      _selectedProjectName = context.read<SelectedProjectProvider>().projectName;;
      _selectedProjectId = context.read<SelectedProjectProvider>().projectId;
      _selectedEmpFilter = widget.filterType;
      Future.microtask(() async => await fetchJobTypes()).whenComplete(() {
        Future.microtask(() async => await fetchEmployees());
      });

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar:const BottomNavBar(),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
            child:
            loaded ?

            Column(
              children: [
                emp.isNotEmpty ?
                Column(
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top:10.0,left: 16.0),
                          child: Text(
                            _selectedEmpFilter == 'all' ? "All Employees" : "Rosted Employees",
                            style:
                            const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),

                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      // height: 60,
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
                    Row(
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
                              Text(
                                _selectedProjectName!,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xffF96B07),
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: emp.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              alertBox(index);
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
                                  color: getBackgroundColor(emp[index].shiftDetails as List<ShiftDetails>),
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
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10000.0),
                                            child: CachedNetworkImage(
                                              height: 50,
                                              width: 50,

                                              imageUrl: emp[index].image ?? '',
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                  downloadProgress) {
                                                return Center(
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        8.0),
                                                    child:
                                                    CircularProgressIndicator(
                                                      value: downloadProgress
                                                          .progress,
                                                    ),
                                                  ),
                                                );
                                              },
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) =>
                                              const Icon(
                                                Icons.person,
                                                color: Colors.grey,
                                                size: 28,
                                              ),
                                            ),
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
                                                emp[index].fName.toString() + ' ' + emp[index].lName.toString(),
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  color: emp[index].shiftDetails!.isNotEmpty ? Colors.white : Colors.black,
                                                ),
                                              ),
                                              Text(
                                                emp[index].contactNumber ?? '',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: emp[index].shiftDetails!.isNotEmpty ? Colors.white : Colors.black,
                                                ),
                                              ),
                                              Text(
                                                emp[index].shiftDetails!.isNotEmpty ?
                                                getShiftTimeString(
                                                  emp[index].shiftDetails?[0].shiftStart as DateTime,
                                                  emp[index].shiftDetails?[0].shiftEnd as DateTime,
                                                ) +' ( ' + getJobTypeNname(
                                                    emp[index].shiftDetails![0].jobTypeId as int
                                                ) + ' )':
                                                '',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: emp[index].shiftDetails!.isNotEmpty ? Colors.white : Colors.black,
                                                ),
                                              ),


                                            ],
                                          ),
                                        ],
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
                  ],
                ):
                Column(
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top:10.0,left: 16.0),
                          child: Text(
                            _selectedEmpFilter == 'all' ? "All Employees" : "Rosted Employees",
                            style:
                            const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),

                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    const SizedBox(
                      height: 16,
                    ),
                    Row(
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
                              Text(
                                _selectedProjectName!,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xffF96B07),
                                    fontWeight: FontWeight.w500),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 2.5 / 4,
                      child: const Center(
                        child: Text('No Employees'),
                      ),
                    )
                  ],
                )

              ],
            ):

            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50, left: 5, right: 5),
                child: CircularProgressIndicator(),
              ), // Display loading indicator
            )
        ),
      ),
    );
  }
}
