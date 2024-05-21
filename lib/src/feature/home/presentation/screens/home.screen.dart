import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:kiosk/src/core/constants/constants.dart';
import 'package:kiosk/src/core/constants/helpers.dart';
import 'package:kiosk/src/core/domain/entities/common_get_request.model.dart';
import 'package:kiosk/src/core/domain/entities/job_type.entity.dart';
import 'package:kiosk/src/core/presentation/widgets/app_bar.widget.dart';
import 'package:kiosk/src/core/router/route.constants.dart';
import 'package:kiosk/src/feature/authentication/presentation/providers/auth.provider.dart';
import 'package:kiosk/src/feature/client_connection/presentation/providers/client.provider.dart';
import 'package:kiosk/src/feature/employees/domain/entities/employee.entity.dart';
import 'package:kiosk/src/feature/home/data/models/sign_in_out_request.model.dart';
import 'package:kiosk/src/feature/home/presentation/providers/home.provider.dart';
import 'package:kiosk/src/feature/home/presentation/screens/start_unscheduled_shift.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/domain/entities/shift.entity.dart';
import '../../data/models/start_unscheduled_shift_request.model.dart';
class HomeScreen extends StatefulWidget {
  final Employee employee;
  final int projectId;
  final String projectName;
  final Shift? shift;

  const HomeScreen({
    Key? key,
    required this.employee,
    required this.shift,
    required this.projectId,
    required this.projectName,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedJobTypeId;
  String? _jobType;
  List<JobType> jobTypes = [];
  bool loading = false;

  TextEditingController commentController = TextEditingController();

  TextEditingController remarksController = TextEditingController();
  TextEditingController ratePerHourController = TextEditingController();
  TextEditingController projectController = TextEditingController();

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
        _selectedJobTypeId = jobTypes.first.id.toString();
        _jobType = jobTypes.first.name;
      });
    });
  }

  Future<void> signInAndOut(int id, String path, String type, String image) async {
    print(id);
    setState(() {
      loading = true;
    });
    if (!mounted) return;
    var baseUrl = context.read<ClientConnectionProvider>().baseUrl;
    return await context
        .read<HomeProvider>()
        .signInAndOut(
            context,
            baseUrl,
            path,
            type,
            SignInAndOutRequest(
                timekeeperId: id,
                image: image,
                comment: commentController.text,
                authToken: context.read<AuthProvider>().authToken!))
                  .whenComplete(() {
                setState(() {
                  loading = true;
                });
              });
  }

  File? image;
  String? base64Image;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front);
      if (image == null) return;
      final imageTemp = File(image.path);
      String? base64Img;
      setState(() {
        this.image = imageTemp;
        String extension = image.path.split('.').last;
        Uint8List bytes = imageTemp.readAsBytesSync();
        base64Img = base64Encode(bytes);
        base64Image = 'data:image/$extension;base64,$base64Img';
      });

      if (base64Img != null) {
        if (!mounted) return;
        startUnscheduledShift();
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageForSignInOut(int id, String path, String type) async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front);
      if (image == null) return;
      final imageTemp = File(image.path);
      String? base64Img;
      setState(() {
        this.image = imageTemp;
        String extension = image.path.split('.').last;
        Uint8List bytes = imageTemp.readAsBytesSync();
        base64Img = base64Encode(bytes);
        base64Image = 'data:image/$extension;base64,$base64Img';
      });

      if (base64Img != null) {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(type),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.file(
                              imageTemp,
                              height:
                                  MediaQuery.of(context).size.height * 1 / 4,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: commentController,
                            decoration: const InputDecoration(labelText: 'Signin/out Comment'),
                          ),
                        ],
                      );
                    }),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.shift?.singIn != null
                        ? getAuDateTime().isAfter(
                                widget.shift?.shiftEnd ?? DateTime.now())
                            ? Colors.red
                            : Colors.green.shade800
                        : getAuDateTime().isAfter(
                                widget.shift?.shiftStart ?? DateTime.now())
                            ? Colors.red
                            : Colors.green.shade800,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    signInAndOut(id, path, type, base64Image!);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.shift?.singIn == null
                            ? 'Start Shift'
                            : 'End Shift',
                          style: TextStyle(color: Colors.white)
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  bool canSignIn(Shift shift) {
    bool canSignIn = false;
    final DateTime start = shift.shiftStart ?? DateTime.now();
    final DateTime now = getAuDateTime();
    Duration duration;
    // can sign in 15 minutes before shift start and before shift end
    if (now.isBefore(start)) {
      duration = start.difference(now);
      // if (duration.inMinutes <= 15) {
        canSignIn = true;
      // }
    } else {
      if (shift.singOut == null) {
        // final DateTime end = DateTime.parse(shift.shiftEnd!);
        // if (now.isBefore(end)) {
        //   printMessage(' before shift end');
        //   canSignIn = true;
        // }
        canSignIn = true;
      }
    }
    return canSignIn;
  }

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
            jobTypeId: _selectedJobTypeId ?? '0',
            remarks: remarksController.text,
            ratePerHour: ratePerHourController.text,
            image: base64Image ?? '',
            comment: commentController.text,
            authToken: context.read<AuthProvider>().authToken!))
        .whenComplete(() async {

      Shift? shift = context.read<HomeProvider>().shift;
      setState(() {
        loading = false;
      });
      if (shift != null) {
        setState(() {
          loading = true;
        });
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
  void initState() {
    if (widget.shift == null) {
      Future.microtask(() async => await fetchJobTypes());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shift != null) {
      final Shift shift = widget.shift!;
      bool canSignIn = this.canSignIn(shift);
    }
    return Scaffold(
      appBar: AppBarWidget(
        title: Text(widget.employee.fName ?? '-', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteConstants.employeeScreen, (route) => false);
            },
            icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Center(
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      clipBehavior: Clip.hardEdge,
                      height: 100,
                      width: 100,
                      child: CachedNetworkImage(
                        imageUrl: widget.employee.image ?? '',
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                8.0,
                              ),
                              child: CircularProgressIndicator(
                                value: downloadProgress.progress,
                              ),
                            ),
                          );
                        },
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              (widget.shift == null ||
                      (widget.shift != null && widget.shift?.singIn == null))
                  ? Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            title: const Text(
                              'Job Type',
                              style: TextStyle(color: Colors.grey),
                            ),
                            subtitle: Visibility(
                              visible: widget.shift != null,
                              replacement: Visibility(
                                visible:
                                    widget.shift == null && jobTypes.isNotEmpty,
                                replacement: const LinearProgressIndicator(),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    jobTypes.isNotEmpty
                                        ? Expanded(
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: _selectedJobTypeId ??
                                                    jobTypes.first.id
                                                        .toString(),
                                                // underline: Divider(color: appColor, height: 3),
                                                icon: const Icon(Icons
                                                    .arrow_drop_down_outlined),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedJobTypeId = value!;
                                                    _jobType = jobTypes
                                                        .where((element) =>
                                                            element.id
                                                                .toString() ==
                                                            value)
                                                        .first
                                                        .name;
                                                  });
                                                },
                                                items: jobTypes.map((value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value.id.toString(),
                                                    child:
                                                        Text(value.name ?? ''),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          )
                                        : const LinearProgressIndicator(),
                                  ],
                                ),
                              ),
                              child: Text(
                                widget.shift?.jobType?.name ?? '',
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade300
                                      : Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            // trailing: Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ),
                        Visibility(
                          visible: widget.shift != null &&
                              widget.shift?.singIn == null,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              StreamBuilder(
                                  stream: Stream.periodic(
                                      const Duration(seconds: 1)),
                                  builder: (context, snapshot) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(.09),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  getSystemTime(),
                                                  style: const TextStyle(
                                                    fontSize: 40,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  widget.shift?.singIn != null
                                                      ? getShiftStartEndDuration(
                                                          widget.shift!.singIn!,
                                                          true)
                                                      : getShiftStartEndDuration(
                                                          widget.shift!
                                                              .shiftStart!,
                                                          false),
                                                  style:
                                                      const TextStyle(fontSize: 15),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        )
                      ],
                    )
                  : StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        return Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.09),
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      getSystemTime(),
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      widget.shift?.singIn != null
                                          ? getShiftStartEndDuration(
                                              widget.shift!.singIn!, true)
                                          : getShiftStartEndDuration(
                                              widget.shift!.shiftStart!, false),
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }),
              const SizedBox(
                height: 10,
              ),
              widget.shift != null
                  ? StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            decoration: BoxDecoration(
                                color: widget.shift?.singIn != null
                                    ? getAuDateTime().isAfter(
                                            widget.shift?.shiftEnd ??
                                                DateTime.now())
                                        ? Colors.red
                                        : Colors.green.shade800
                                    : getAuDateTime().isAfter(
                                            widget.shift?.shiftStart ??
                                                DateTime.now())
                                        ? Colors.red
                                        : Colors.green.shade800,
                                borderRadius: BorderRadius.circular(5)),
                            clipBehavior: Clip.hardEdge,
                            child: InkWell(
                              onTap: () {
                                if (widget.shift?.singIn == null) {
                                  pickImageForSignInOut(widget.shift?.id ?? 0,
                                      'admin/kiosk/sign/in', 'Sign In');
                                } else {
                                  pickImageForSignInOut(widget.shift?.id ?? 0,
                                      'admin/kiosk/sign/out', 'Sign Out');
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    loading
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ))
                                        : widget.shift?.singIn == null
                                            ? const Text(
                                                'Start Shift',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : const Text(
                                                'End Shift',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      })
                  : Column(
                children: [

                  // TextFormField(
                  //   controller: projectController,
                  //   decoration: const InputDecoration(labelText: 'Site / Venue'),
                  //   readOnly: true,
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
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

                  !loading ?
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5)),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(

                      onTap: () {
                        if (widget.shift == null) {
                          pickImage();
                        }
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child:

                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Start Unscheduled Shift',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                      ),
                    ),
                  ):
                  const Center(
                    child: CircularProgressIndicator(), // Display loading indicator
                  )
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              const Divider(),
              const SizedBox(
                height: 18,
              ),
              Visibility(
                visible: widget.shift == null,
                replacement: Column(
                  children: [
                    Text(
                      DateFormat("EEEE, d MMMM")
                          .format(widget.shift?.roasterDate ?? DateTime.now()),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(
                              height: 20.5,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(10)),
                              clipBehavior: Clip.hardEdge,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.09),
                                      // border: const Border(
                                      //   bottom: BorderSide(
                                      //       color: Colors.purpleAccent),
                                      // ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.only(
                                        top: 25,
                                        left: 16,
                                        right: 16,
                                        bottom: 5,
                                      ),
                                      title: Visibility(
                                        visible: widget.shift?.singIn == null,
                                        replacement: Text(
                                          'Started at ${DateFormat.jm().format(widget.shift?.singIn ?? DateTime.now())}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            wordSpacing: 4,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        child: Text(
                                          '${DateFormat.jm().format(widget.shift?.shiftStart ?? DateTime.now())} - ${DateFormat.jm().format(widget.shift?.shiftEnd ?? DateTime.now())}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            wordSpacing: 4,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          '${widget.shift?.jobType?.name ?? ''} at ${widget.shift?.project?.projectName ?? ''}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    : Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   children: [
                                  //     const Expanded(
                                  //       child: ListTile(
                                  //         title: Text('Meal Break'),
                                  //         subtitle: Text('Unpaid'),
                                  //       ),
                                  //     ),
                                  //     Container(
                                  //       width: 1,
                                  //       height: 30,
                                  //       color: Colors.grey,
                                  //     ),
                                  //     Expanded(
                                  //       child: ListTile(
                                  //         title: Row(
                                  //           mainAxisAlignment:
                                  //               MainAxisAlignment.center,
                                  //           children: [
                                  //             Container(
                                  //               padding:
                                  //                   const EdgeInsets.symmetric(
                                  //                 vertical: 6,
                                  //                 horizontal: 10,
                                  //               ),
                                  //               decoration: BoxDecoration(
                                  //                 color: Colors.purpleAccent,
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(15),
                                  //               ),
                                  //               child: const Text(
                                  //                 'In Progress',
                                  //                 style: TextStyle(
                                  //                     color: Colors.white,
                                  //                     fontSize: 15),
                                  //                 textAlign: TextAlign.center,
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // )
                                ],
                              ),
                            )
                          ],
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                widget.shift?.roasterType ?? '-',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/png/calendar.png',
                      width: 180,
                      color: Colors.grey,
                    ),
                    const Text(
                      'Nothing Scheduled Today',
                      style: TextStyle(fontSize: 17),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
