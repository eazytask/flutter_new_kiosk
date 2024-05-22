import 'package:kiosk/src/core/data/datasources/local/device_info.datasource.dart';
import 'package:kiosk/src/core/error/logger.dart';
import 'package:kiosk/src/core/provider/remote_config.provider.dart';
import 'package:kiosk/src/feature/client_connection/presentation/providers/client.provider.dart';
import 'package:kiosk/src/feature/home/presentation/screens/home.screen.dart';
import 'package:kiosk/src/core/constants/constants.dart';
import 'package:kiosk/src/core/domain/entities/user.entity.dart';
import 'package:kiosk/src/core/router/route.constants.dart';
import 'package:kiosk/src/feature/authentication/data/models/auth_request.dart';
import 'package:kiosk/src/feature/authentication/presentation/providers/auth.provider.dart';
import 'package:kiosk/src/feature/employees/presentation/screens/employee.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiosk/src/feature/projects/presentation/provider/selected.project.dart';
import 'package:provider/provider.dart';

import 'package:kiosk/src/feature/projects/project.screen.dart';
import 'package:kiosk/constants/mainbutton.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isVisible = false;

  late Future<User?> _getCurrentUserFuture;
  late Future<String> deviceInfoDetails;
  late DeviceInfo deviceInfo;

  void login() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    print(_isLoading);

    try {
      var auth = context.read<AuthProvider>();

      var request = AuthRequest(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      var baseUrl = context.read<ClientConnectionProvider>().baseUrl;

      context
          .read<AuthProvider>()
          .signIn(baseUrl, request, RouteConstants.loginScreen, context)
          .then((_) {
        if (auth.user != null) {
          setState(() {
            _isLoading = false;
          });

          Future.microtask(() => Navigator.pushNamedAndRemoveUntil(
              context, RouteConstants.projectScreen, (_) => false,
              arguments: "Empty"));
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } on Exception {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {

    context.read<SelectedProjectProvider>().loadValue().whenComplete(() {
      if(context.read<SelectedProjectProvider>().projectId != ""){
        Navigator.pushNamedAndRemoveUntil(context, RouteConstants.employeeScreen,(_)=>false );
      }
    });


    _getCurrentUserFuture = context.read<AuthProvider>().getCurrentUser();
    try {
      context.read<RemoteConfigProvider>().remoteConfig?.fetchAndActivate();
    } catch (e) {
      cPrint(e.toString());
    }
    deviceInfo = DeviceInfo();
    deviceInfoDetails = deviceInfo.getUserAgent();


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return FutureBuilder(
        future: _getCurrentUserFuture,
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(
                    child: CircularProgressIndicator(
              color: Colors.purpleAccent,
            )));
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.token != null) {
              return const ProjectListScreen();
            }
          }
          return SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/png/llogo.png',
                              height: 130,
                              width: 130,
                            ),
                            const SizedBox(
                              height: 66,
                            ),
                            Container(
                              // height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                // color: Color(0xffE4DFDF).withOpacity(0.2),
                              ),
                              child: TextFormField(
                                controller: emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email';
                                  } else {
                                    bool emailValid = RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(value);
                                    if (emailValid) {
                                      return null;
                                    } else {
                                      return 'Please enter a valid email';
                                    }
                                  }
                                },

                                style: const TextStyle(fontSize: 20),
                                decoration: InputDecoration(
                                  enabled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xff6EC2FA),
                                    ),
                                  ),
                                  disabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xff6EC2FA))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                      const BorderSide(color: Color(0xff6EC2FA)),
                                      borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 20,
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'Email',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  hintStyle: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 13,
                            ),
                            Container(
                              // height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                // color: Color(0xffE4DFDF).withOpacity(0.2),
                              ),
                              child: TextFormField(
                                controller: passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                                obscureText: !isVisible,
                                style: const TextStyle(fontSize: 18),
                                obscuringCharacter: '*',
                                decoration: InputDecoration(
                                  enabled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xff6EC2FA),
                                    ),
                                  ),
                                  disabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xff6EC2FA))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                      const BorderSide(color: Color(0xff6EC2FA)),
                                      borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 21,

                                  ),
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  hintText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: const Color(0xffB8B8B8),
                                      size: 27,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isVisible = !isVisible;
                                      });
                                    },
                                  ),
                                  hintStyle: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            // const Row(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     Text(
                            //       'Forgot your password?',
                            //       style: TextStyle(fontSize: 17, color: Color(0xff46A0DD)),
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(
                            //   height: 15,
                            // ),
                            Button(
                                height: 55,
                                width: double.infinity,
                                child: const Center(
                                  child: Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onTap: login,
                                colorB: const Color(0xff6EC2FA)),
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<String>(
                            future: deviceInfoDetails,
                            builder: (context, AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 50,
                                  child: LinearProgressIndicator(minHeight: 4),
                                );
                              }
                              String projectVersion = deviceInfo.projectVersion;
                              String mobileAppVersionCode =
                                  deviceInfo.mobileAppVersionCode;
                              return Text(
                                "",
                                // "${projectVersion}v ($mobileAppVersionCode)",
                                // style: Theme.of(context)
                                //     .textTheme
                                //     .subtitle2!
                                //     .copyWith(
                                //     color: (Theme.of(context).brightness ==
                                //         Brightness.dark)
                                //         ? AppColors.kLighterGrey.withAlpha(110)
                                //         : AppColors.kLighterGrey.withAlpha(150)),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
