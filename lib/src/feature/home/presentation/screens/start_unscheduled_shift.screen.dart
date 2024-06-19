import 'dart:io';

import 'package:flutter_svg/svg.dart';
import 'package:kiosk/src/core/constants/constants.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/core/domain/entities/project.entity.dart';
import 'package:kiosk/src/core/domain/entities/shift.entity.dart';
import 'package:kiosk/src/core/presentation/widgets/app_bar.widget.dart';
import 'package:kiosk/src/core/presentation/widgets/loading_overlay.dart';
import 'package:kiosk/src/core/router/route.constants.dart';
import 'package:kiosk/src/feature/authentication/presentation/providers/auth.provider.dart';
import 'package:kiosk/src/feature/client_connection/presentation/providers/client.provider.dart';
import 'package:kiosk/src/feature/employees/domain/entities/employee.entity.dart';
import 'package:kiosk/src/feature/employees/presentation/providers/employee.provider.dart';
import 'package:kiosk/src/feature/employees/presentation/screens/employee.screen.dart';
import 'package:kiosk/src/feature/home/data/models/start_unscheduled_shift_request.model.dart';
import 'package:kiosk/src/feature/home/presentation/providers/home.provider.dart';
import 'package:kiosk/src/feature/home/presentation/screens/home.screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/mainbutton.dart';

class StartUnscheduledScreen extends StatefulWidget {
  final String jobType;
  final String jobTypeId;
  final String base64Image;
  final File image;
  final int projectId;
  final String projectName;
  final Employee employee;

  const StartUnscheduledScreen({
    Key? key,
    required this.jobType,
    required this.jobTypeId,
    required this.base64Image,
    required this.image,
    required this.projectId,
    required this.projectName,
    required this.employee,
  }) : super(key: key);

  @override
  State<StartUnscheduledScreen> createState() => _StartUnscheduledScreenState();
}

class _StartUnscheduledScreenState extends State<StartUnscheduledScreen> {
  TextEditingController remarksController = TextEditingController();
  TextEditingController ratePerHourController = TextEditingController();
  TextEditingController projectController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  final _fromTop = true;

  final ProgressBar _sendingMsgProgressBar = ProgressBar();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool loading = false;

  Future<void> startUnscheduledShift() async {
    setState(() {
      loading = true;
    });
    if (!mounted) return;
    var baseUrl = context.read<ClientConnectionProvider>().baseUrl;
    return await context
        .read<HomeProvider>()
        .startUnscheduledShift(
            context,
            baseUrl,
            StartUnscheduledShiftRequest(
                employeeId: widget.employee.id,
                latitude: '',
                longitude: '',
                projectId: widget.projectId.toString(),
                jobTypeId: widget.jobTypeId,
                remarks: remarksController.text,
                ratePerHour: ratePerHourController.text,
                image: widget.base64Image,
                comment: commentController.text,
                authToken: context.read<AuthProvider>().authToken!))
        .whenComplete(() async {
      Shift? shift = context.read<HomeProvider>().shift;
      setState(() {
        loading = true;
      });
      if (shift != null) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteConstants.homeScreen,
          (route) => false,
          arguments: HomeScreen(
            employee: widget.employee,
            projectName: widget.projectName,
            shift: shift,
            projectId: int.parse(widget.projectId.toString() ?? '0'),
          ),
        );
      }
    });
  }

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
    projectController.text = widget.projectName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: Text('Start Unscheduled Shift', style: TextStyle(color: Colors.white))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 37,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image.file(
                            widget.image,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        height: 60,
                        width: 0.5,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(
                            context.watch<AuthProvider>().user?.name ?? '-',
                          ),
                          subtitle: Text(widget.jobType),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: projectController,
                  decoration: const InputDecoration(labelText: 'Site / Venue'),
                  readOnly: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: ratePerHourController,
                  decoration: const InputDecoration(labelText: 'Rate Per Hour'),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter an amount';
                    } else {
                      if (double.parse(val) <= 0) {
                        return 'Please enter a valid amount';
                      }
                    }
                    return null;
                  },
                ),
                // const SizedBox(
                //   height: 10,
                // ),
                // TextFormField(
                //   controller: remarksController,
                //   decoration: const InputDecoration(labelText: 'Remarks'),
                // ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: commentController,
                  decoration: const InputDecoration(labelText: 'Signin/out Comment'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Button(
                    height: 50,
                    width: 172,
                    child: Center(
                      child:
                        loading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          'Start',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                    ),
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        startUnscheduledShift();
                      }
                    },
                    colorB:
                    const Color(0xff0ABE52)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
