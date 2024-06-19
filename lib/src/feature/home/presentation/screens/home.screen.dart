import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
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

import '../../../../core/constants/mainbutton.dart';
import '../../../../core/domain/entities/shift.entity.dart';
import '../../../employees/presentation/screens/employee.screen.dart';

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
  final _fromTop = true;

  TextEditingController commentController = TextEditingController();

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

  Future<void> signInAndOut(
      int id, String path, String type, String image) async {
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
        Navigator.of(context).pushNamed(
          RouteConstants.startUnscheduledScreen,
          arguments: StartUnscheduledScreen(
            employee: widget.employee,
            jobType: _jobType ?? '-',
            jobTypeId: _selectedJobTypeId ?? '0',
            base64Image: base64Image ?? '',
            image: File(image.path),
            projectName: widget.projectName,
            projectId: widget.projectId,
          ),
        );
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
                            decoration: const InputDecoration(
                                labelText: 'Signin/out Comment'),
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
                          style: TextStyle(color: Colors.white)),
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                        32,
                      ),
                      bottomRight: Radius.circular(32)),
                ),
                color: Colors.white,
                elevation: 5,
                child: Container(
                  height: 165,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(
                          32,
                        ),
                        bottomRight: Radius.circular(32)),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Future.microtask(
                                    () => Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          RouteConstants.employeeScreen,
                                          (_) => false,
                                          arguments: {
                                            'projectName': widget.projectName,
                                            'projectId':
                                                widget.projectId.toString(),
                                          },
                                        ));
                              },
                              child: SvgPicture.asset(
                                'assets/png/back.svg',
                                height: 45,
                                width: 45,
                              ),
                            ),
                            const Text(
                              'Shift',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 45)
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
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
                            '${widget.projectName}',
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xffF96B07),
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.employee.image ?? '',
                  width: 100,
                  // Set a fixed width for the image
                  height: 100,
                  // Set a fixed height for the image
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
                  fit: BoxFit.cover,
                  // Adjust the fit based on your preference
                  errorWidget: (context, url, error) {
                    final iconSize = 28.0;
                    return Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: iconSize,
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                '${widget.employee.fName ?? ""} ${widget.employee.mName != null ? widget.employee.mName! + " " : ""}${widget.employee.lName ?? ""}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 33,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
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
                            visible: widget.shift == null &&
                                jobTypes.isNotEmpty,
                            replacement: const LinearProgressIndicator(),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                jobTypes.isNotEmpty
                                    ? Expanded(
                                        child:
                                            DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _selectedJobTypeId ??
                                                jobTypes.first.id
                                                    .toString(),
                                            // underline: Divider(color: appColor, height: 3),
                                            icon: const Icon(Icons
                                                .arrow_drop_down_outlined),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedJobTypeId =
                                                    value!;
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
                                                value:
                                                    value.id.toString(),
                                                child: Text(
                                                    value.name ?? ''),
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
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Column(children: [
                widget.shift != null
                    ? StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              height: 360,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xff8E8E93))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${widget.shift?.jobType?.name ?? ''}',
                                    style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Visibility(
                                        visible: widget.shift != null,
                                        // && widget.shift?.singIn == null
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
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .lock_clock,
                                                                  size: 30,
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  getSystemTime(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          32,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .black87),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              widget.shift?.singIn !=
                                                                      null
                                                                  ? getShiftStartEndDuration(
                                                                      widget
                                                                          .shift!
                                                                          .singIn!,
                                                                      true)
                                                                  : getShiftStartEndDuration(
                                                                      widget
                                                                          .shift!
                                                                          .shiftStart!,
                                                                      false),
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xffF5630A),
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 60,
                                  ),
                                  Row(
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
                                              ? Button(
                                                  height: 50,
                                                  width: 172,
                                                  child: Center(
                                                    child: Text(
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
                                                    if (widget.shift?.singIn ==
                                                        null) {
                                                      pickImageForSignInOut(
                                                          widget.shift?.id ?? 0,
                                                          'admin/kiosk/sign/in',
                                                          'Sign In');
                                                    } else {
                                                      pickImageForSignInOut(
                                                          widget.shift?.id ?? 0,
                                                          'admin/kiosk/sign/out',
                                                          'Sign Out');
                                                    }
                                                  },
                                                  colorB:
                                                      const Color(0xff0ABE52))
                                              : Button(
                                                  height: 50,
                                                  width: 172,
                                                  child: Center(
                                                    child: Text(
                                                      'End',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    if (widget.shift?.singIn ==
                                                        null) {
                                                      pickImageForSignInOut(
                                                          widget.shift?.id ?? 0,
                                                          'admin/kiosk/sign/in',
                                                          'Sign In');
                                                    } else {
                                                      pickImageForSignInOut(
                                                          widget.shift?.id ?? 0,
                                                          'admin/kiosk/sign/out',
                                                          'Sign Out');
                                                    }
                                                  },
                                                  colorB: Colors.red),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Button(
                                          height: 50,
                                          width: 172,
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
                                            Future.microtask(() => Navigator
                                                    .pushNamedAndRemoveUntil(
                                                  context,
                                                  RouteConstants.employeeScreen,
                                                  (_) => false,
                                                  arguments: {
                                                    'projectName':
                                                        widget.projectName,
                                                    'projectId': widget
                                                        .projectId
                                                        .toString(),
                                                  },
                                                ));
                                          },
                                          colorB: const Color(0xffF5630A)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                    : Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5)),
                          clipBehavior: Clip.hardEdge,
                          child: Button(
                              height: 50,
                              width: 272,
                              child: Center(
                                child: Text(
                                  'Start Unscheduled Shift',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (widget.shift == null) {
                                  pickImage();
                                }
                              },
                              colorB: const Color(0xff0ABE52)),
                        ),
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
                        DateFormat("EEEE, d MMMM").format(
                            widget.shift?.roasterDate ?? DateTime.now()),
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
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Text(
                                            '${widget.shift?.jobType?.name ?? ''} at ${widget.shift?.project?.projectName ?? ''}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.black
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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
              ]),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBarWidget(
        title: Text(widget.employee.fName ?? '-',
            style: TextStyle(color: Colors.white)),
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
                                                  style: const TextStyle(
                                                      fontSize: 15),
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
                  : Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Start Unscheduled Shift',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  alertBox() {
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
                    height: 250,
                    width: 430,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/png/ss.png',
                          fit: BoxFit.fill,
                          height: 135,
                          width: 190,
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Button(
                                  height: 32,
                                  width: 134,
                                  child: const Center(
                                    child: Text(
                                      'Start',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  onTap: () {},
                                  colorB: const Color(0xff0ABE52)),
                              const SizedBox(
                                width: 5,
                              ),
                              Button(
                                  height: 32,
                                  width: 134,
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
                                  colorB: const Color(0xffF5630A)),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            );
          });
        });
  }
}
