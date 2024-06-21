import 'dart:io';

import 'package:kiosk/src/core/constants/constants.dart';
import 'package:kiosk/src/core/presentation/base.view.dart';
import 'package:kiosk/src/core/provider/remote_config.provider.dart';
import 'package:kiosk/src/core/provider/theme.provider.dart';
import 'package:kiosk/src/core/router/route.constants.dart';
import 'package:kiosk/src/core/router/route.dart';
import 'package:kiosk/src/core/theme/dark_theme.data.dart';
import 'package:kiosk/src/core/theme/light_theme.data.dart';
import 'package:kiosk/src/feature/authentication/presentation/providers/auth.provider.dart';
import 'package:kiosk/src/feature/client_connection/presentation/providers/client.provider.dart';
import 'package:kiosk/src/feature/employees/presentation/providers/employee.provider.dart';
import 'package:kiosk/src/feature/home/presentation/providers/home.provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, SystemUiOverlayStyle;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'feature/authentication/presentation/screens/authentication.screen.dart';

import 'feature/projects/presentation/provider/selected.project.dart';

class EazytaskKiosk extends StatefulWidget {
  final Future<FirebaseRemoteConfig> remoteConfig;

  const EazytaskKiosk({Key? key, required this.remoteConfig}) : super(key: key);

  @override
  _EazytaskKioskState createState() => _EazytaskKioskState();
}

class _EazytaskKioskState extends State<EazytaskKiosk> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (Theme.of(context).brightness == Brightness.dark && Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ));
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SelectedProjectProvider>(create: (_) => SelectedProjectProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<EmployeeProvider>(
            create: (_) => EmployeeProvider()),
        ChangeNotifierProvider<HomeProvider>(
            create: (_) => HomeProvider()),
        ChangeNotifierProvider<RemoteConfigProvider>(
            create: (_) => RemoteConfigProvider()),
        ChangeNotifierProvider<ClientConnectionProvider>(
            create: (_) => ClientConnectionProvider()),
      ],
      child: BaseView<ThemeProvider>(
        onModelReady: (model) => model.themeMode,
        builder: (context, provider, child) => FutureBuilder<
            FirebaseRemoteConfig>(
          future: widget.remoteConfig,
          builder: (BuildContext context,
              AsyncSnapshot<FirebaseRemoteConfig> snapshot) {
            var clientProvider =
            Provider.of<ClientConnectionProvider>(context, listen: false);

            var clientSavedUrl = clientProvider.fetchClientBaseUrl();
            if (clientSavedUrl == null || clientSavedUrl == "") {
              clientProvider.baseUrl = urlHost;
            } else {
              clientProvider.baseUrl = clientSavedUrl;
            }

            if (snapshot.hasData) {
              Provider.of<RemoteConfigProvider>(context).remoteConfig =
                  snapshot.requireData;
            }
            return MaterialApp(
              builder: (context, child) => ResponsiveWrapper.builder(
                child,
                maxWidth: 1200,
                minWidth: 480,
                defaultScale: true,
                breakpoints: [
                  const ResponsiveBreakpoint.resize(480, name: MOBILE),
                  const ResponsiveBreakpoint.autoScale(800, name: TABLET),
                  const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
                ],
              ),
              title: 'Eazytask Kiosk',
              debugShowCheckedModeBanner: false,
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              // theme: LightTheme.getTheme.copyWith(
              //   textTheme: GoogleFonts.sourceSansProTextTheme(
              //           Theme.of(context).textTheme)
              //       .copyWith(
              //     bodyText1: LightTheme.textTheme.bodyText1,
              //     bodyText2: LightTheme.textTheme.bodyText2,
              //     subtitle1: LightTheme.textTheme.subtitle1,
              //     subtitle2: LightTheme.textTheme.subtitle2,
              //     headline6: LightTheme.textTheme.headline6,
              //     headline5: LightTheme.textTheme.headline5,
              //     headline4: LightTheme.textTheme.headline4,
              //     headline3: LightTheme.textTheme.headline3,
              //     headline2: LightTheme.textTheme.headline2,
              //     headline1: LightTheme.textTheme.headline1,
              //   ),
              // ),
              darkTheme: DarkTheme.getTheme.copyWith(
                textTheme: GoogleFonts.sourceSansProTextTheme(
                        Theme.of(context).textTheme)
                    .copyWith(
                  bodyLarge: DarkTheme.textTheme.bodyLarge,
                  bodyMedium: DarkTheme.textTheme.bodyMedium,
                  titleMedium: DarkTheme.textTheme.titleMedium,
                  titleSmall: DarkTheme.textTheme.titleSmall,
                  titleLarge: DarkTheme.textTheme.titleLarge,
                  headlineSmall: DarkTheme.textTheme.headlineSmall,
                  headlineMedium: DarkTheme.textTheme.headlineMedium,
                  displaySmall: DarkTheme.textTheme.displaySmall,
                  displayMedium: DarkTheme.textTheme.displayMedium,
                  displayLarge: DarkTheme.textTheme.displayLarge,
                ),
              ),
              themeMode: provider.themeMode,
              initialRoute: RouteConstants.loginScreen,
              onGenerateRoute: AppRouter.onGenerateRoute,
              home: const LoginScreen(),
            );
          },
        ),
      ),
    );
  }
}
