import 'package:cached_network_image/cached_network_image.dart';
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

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
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
    return Scaffold(
        appBar: AppBarWidget(
          title: !_searchBoolean
              ? const Text('Select Employee', style: TextStyle(color: Colors.white),)
              : _searchTextField(),
          leading: Consumer(builder: (context, AuthProvider provider, _) {
            if (provider.isBusy) {
              return const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              );
            }
            return IconButton(
              onPressed: () {
                var baseUrl = context.read<ClientConnectionProvider>().baseUrl;
                context.read<AuthProvider>().logout(context, baseUrl);
              },
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
              ),
            );
          }),
          actions: context.watch<EmployeeProvider>().employees.isNotEmpty
              ? !_searchBoolean
                  ? [
                      IconButton(
                          icon: const Icon(Icons.search, color: Colors.white,),
                          onPressed: () {
                            setState(() {
                              _searchBoolean = true;
                            });
                          })
                    ]
                  : [
                      IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _searchBoolean = false;
                              _searchController.clear();
                              emp = context.read<EmployeeProvider>().employees;
                            });
                          })
                    ]
              : [],
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
                Visibility(
                  visible: loaded,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        projects.isNotEmpty
                            ? Visibility(
                                visible: projects.isNotEmpty,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    hint: const Text('Select Site'),
                                    value: _selectedProjectId ??
                                        projects.first.id.toString(),
                                    // underline: Divider(color: appColor, height: 3),
                                    icon: const Icon(
                                        Icons.arrow_drop_down_outlined),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedProjectId = value!;
                                        _selectedProjectName = projects.singleWhere((element) => element.id.toString() == value).projectName;
                                        _searchBoolean = false;
                                        _searchController.clear();
                                      });

                                      Future.microtask(
                                          () async => await fetchEmployees());
                                    },
                                    items: projects.map((value) {
                                      return DropdownMenuItem<String>(
                                        value: value.id.toString(),
                                        child: Text(value.projectName ?? ''),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text('Select Site'),
                            value: _selectedEmpFilter ?? empFilter.first,
                            // underline: Divider(color: appColor, height: 3),
                            icon: const Icon(Icons.arrow_drop_down_outlined),
                            onChanged: (value) {
                              setState(() {
                                _selectedEmpFilter = value!;
                                _searchBoolean = false;
                                _searchController.clear();
                              });

                              Future.microtask(
                                  () async => await fetchEmployees());
                            },
                            items: empFilter.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value ?? ''),
                              );
                            }).toList(),
                          ),
                        ),
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
                        height: MediaQuery.of(context).size.height * 2.5 / 4,
                        child: const Center(
                          child: Text('No Employees'),
                        ),
                      );
                    }
                    if (provider.isBusy) {
                      return SizedBox(
                          height: MediaQuery.of(context).size.height * 3 / 4,
                          child:
                              const Center(child: CircularProgressIndicator()));
                    }
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: emp.length,
                            physics: const ScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.09),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    onTap: () {
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              title:
                                                  Text(emp[index].fName ?? '-'),
                                              content: TextFormField(
                                                controller: _pinController,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'Pin'),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                              actionsAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              actions: <Widget>[
                                                StatefulBuilder(builder:
                                                    (context, setState) {
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      submit
                                                          ? const SizedBox(
                                                              height: 16,
                                                              width: 16,
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            )
                                                          : TextButton(
                                                              child: const Text(
                                                                  "Submit"),
                                                              onPressed: () {
                                                                checkPin(
                                                                  emp[index]
                                                                          .id ??
                                                                      0,
                                                                  emp[index],
                                                                );
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                      TextButton(
                                                        child: const Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(false);
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                }),
                                              ],
                                            );
                                          });
                                    },
                                    leading: CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        child: CircleAvatar(
                                          radius: 18,
                                          child: Container(
                                            width: 86,
                                            clipBehavior: Clip.hardEdge,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle),
                                            child: CachedNetworkImage(
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
                                        )),
                                    title: Text(emp[index].fName ?? '-'),
                                    trailing: const Icon(Icons.arrow_right),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          emp[index].contactNumber ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey.shade300
                                                    : Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '#${emp[index].licenseNo}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey.shade300
                                                    : Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
