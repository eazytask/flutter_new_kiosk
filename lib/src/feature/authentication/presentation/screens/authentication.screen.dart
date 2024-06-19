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
import 'package:provider/provider.dart';

import '../../../../core/constants/mainbutton.dart';
import '../../../project/presentation/screens/project.screen.dart';

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
  bool? _passwordVisible;

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
    _getCurrentUserFuture = context.read<AuthProvider>().getCurrentUser();
    try {
      context.read<RemoteConfigProvider>().remoteConfig?.fetchAndActivate();
    } catch (e) {
      cPrint(e.toString());
    }
    deviceInfo = DeviceInfo();
    deviceInfoDetails = deviceInfo.getUserAgent();
    _passwordVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return Material(
        child: FutureBuilder(
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
              return const ProjectScreen();
            }
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 80),
              child: Form(
                  key: _formKey,
                  child: Column(
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
                          style: const TextStyle(fontSize: 20),
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
                          decoration: InputDecoration(
                            enabled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xff6EC2FA),
                              ),
                            ),
                            disabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff6EC2FA))),
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
                          obscureText: !_passwordVisible!,
                          style: const TextStyle(fontSize: 18),
                          obscuringCharacter: '*',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            enabled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xff6EC2FA),
                              ),
                            ),
                            disabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xff6EC2FA))),
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
                                _passwordVisible!
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xffB8B8B8),
                                size: 27,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible!;
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
                      // const SizedBox(
                      //   height: 7,
                      // ),
                      // const Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     Text(
                      //       'Forgot your password?',
                      //       style: TextStyle(fontSize: 17, color: Color(0xff46A0DD)),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(
                        height: 15,
                      ),
                      Button(
                          height: 55,
                          width: double.infinity,
                          child: Center(
                            child: Visibility(
                                visible: !_isLoading,
                                replacement: const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                ),
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ),
                          onTap: login,
                          colorB: const Color(0xff6EC2FA)),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  )),
            ),
          );

          // return SafeArea(
          //   child: Scaffold(
          //     body: Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 25),
          //       child: Form(
          //         key: _formKey,
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             Expanded(
          //               child: Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 children: [
          //                   Image.asset(
          //                     'assets/png/kiosk.png',
          //                     width: 200,
          //                   ),
          //                   SizedBox(
          //                     height: 20,
          //                   ),
          //                   Text(
          //                     'Welcome to Eazytask Kiosk',
          //                     style: TextStyle(
          //                       color: Colors.black,
          //                       fontSize: 20,
          //                       fontWeight: FontWeight.bold,
          //                     ),
          //                   ),
          //                   const SizedBox(height: 20),
          //                   Text(
          //                     'Sign in to continue',
          //                     style: TextStyle(
          //                       color: Colors.grey[600],
          //                       fontSize: 16,
          //                       fontWeight: FontWeight.bold,
          //                     ),
          //                   ),
          //                   TextFormField(
          //                     controller: emailController,
          //                     validator: (value) {
          //                       if (value == null || value.isEmpty) {
          //                         return 'Please enter email';
          //                       } else {
          //                         bool emailValid = RegExp(
          //                                 r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          //                             .hasMatch(value);
          //                         if (emailValid) {
          //                           return null;
          //                         } else {
          //                           return 'Please enter a valid email';
          //                         }
          //                       }
          //                     },
          //                     decoration:
          //                         const InputDecoration(label: Text('Email')),
          //                   ),
          //                   TextFormField(
          //                     controller: passwordController,
          //                     obscureText: !isVisible,
          //                     validator: (value) {
          //                       if (value == null || value.isEmpty) {
          //                         return 'Please enter email';
          //                       }
          //                       return null;
          //                     },
          //                     decoration: InputDecoration(
          //                       label: Text('Password'),
          //                       suffixIcon: IconButton(
          //                         onPressed: () {
          //                           setState(() {
          //                             isVisible = !isVisible;
          //                           });
          //                         },
          //                         splashRadius: 1,
          //                         color: Theme.of(context).primaryColor,
          //                         iconSize: 20,
          //                         icon: Icon(isVisible
          //                             ? Icons.visibility
          //                             : Icons.visibility_off),
          //                       ),
          //                     ),
          //                   ),
          //                   Row(
          //                     mainAxisAlignment: MainAxisAlignment.end,
          //                     children: [
          //                       FutureBuilder(
          //                         future: context
          //                             .read<RemoteConfigProvider>()
          //                             .checkIfConnectionChangeAvailable(),
          //                         builder: (BuildContext context,
          //                             AsyncSnapshot snapshot) {
          //                           if (snapshot.hasData && snapshot.data) {
          //                             // return Row(
          //                             //   mainAxisAlignment:
          //                             //       MainAxisAlignment.end,
          //                             //   children: [
          //                             //     IconButton(
          //                             //       icon: const Icon(
          //                             //         Icons.settings_ethernet_outlined,
          //                             //         // color: AppColors.kLighterGrey,
          //                             //       ),
          //                             //       onPressed: () {
          //                             //         Navigator.pushNamed(context,
          //                             //             RouteConstants.configScreen);
          //                             //       },
          //                             //     ),
          //                             //   ],
          //                             // );
          //                           }
          //                           return const SizedBox();
          //                         },
          //                       ),
          //                     ],
          //                   ),
          //                   const SizedBox(
          //                     height: 30,
          //                   ),
          //                   Padding(
          //                     padding:
          //                         const EdgeInsets.symmetric(horizontal: 10),
          //                     child: ElevatedButton(
          //                       onPressed: login,
          //                       style: ElevatedButton.styleFrom(
          //                           padding: EdgeInsets.symmetric(
          //                               vertical: 15, horizontal: 10),
          //                           shape: RoundedRectangleBorder(
          //                             borderRadius:
          //                                 BorderRadius.all(Radius.circular(10)),
          //                           ),
          //                           textStyle: TextStyle(
          //                               fontFamily: 'medium', fontSize: 15),
          //                           backgroundColor:
          //                               Theme.of(context).primaryColor),
          //                       child: Row(
          //                         mainAxisAlignment: MainAxisAlignment.center,
          //                         children: [
          //                           Visibility(
          //                             visible: !_isLoading,
          //                             replacement: const SizedBox(
          //                               height: 16,
          //                               width: 16,
          //                               child: CircularProgressIndicator(
          //                                 color: Colors.white,
          //                                 strokeWidth: 3,
          //                               ),
          //                             ),
          //                             child: const Text(
          //                               'Login',
          //                               style: TextStyle(color: Colors.white),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //             Padding(
          //               padding: const EdgeInsets.all(8.0),
          //               child: FutureBuilder<String>(
          //                   future: deviceInfoDetails,
          //                   builder: (context, AsyncSnapshot<String> snapshot) {
          //                     if (snapshot.connectionState ==
          //                         ConnectionState.waiting) {
          //                       return const SizedBox(
          //                         width: 50,
          //                         child: LinearProgressIndicator(minHeight: 4),
          //                       );
          //                     }
          //                     String projectVersion = deviceInfo.projectVersion;
          //                     String mobileAppVersionCode =
          //                         deviceInfo.mobileAppVersionCode;
          //                     return Text(
          //                       "",
          //                       // "${projectVersion}v ($mobileAppVersionCode)",
          //                       // style: Theme.of(context)
          //                       //     .textTheme
          //                       //     .subtitle2!
          //                       //     .copyWith(
          //                       //     color: (Theme.of(context).brightness ==
          //                       //         Brightness.dark)
          //                       //         ? AppColors.kLighterGrey.withAlpha(110)
          //                       //         : AppColors.kLighterGrey.withAlpha(150)),
          //                     );
          //                   }),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // );
        })
    );
  }
}
