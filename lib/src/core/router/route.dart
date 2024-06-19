import 'package:kiosk/src/feature/client_connection/presentation/screens/config.screen.dart';
import 'package:kiosk/src/feature/home/presentation/screens/home.screen.dart';
import 'package:kiosk/src/core/error/logger.dart';
import 'package:kiosk/src/core/presentation/screens/splash.screen.dart';
import 'package:kiosk/src/core/presentation/screens/unknown.screen.dart';
import 'package:kiosk/src/core/router/route.constants.dart';
import 'package:kiosk/src/feature/authentication/presentation/screens/authentication.screen.dart';
import 'package:kiosk/src/feature/employees/presentation/screens/employee.screen.dart';
import 'package:kiosk/src/feature/home/presentation/screens/start_unscheduled_shift.screen.dart';
import 'package:flutter/material.dart';

import '../../feature/project/presentation/screens/project.screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    cPrint("Navigating to ${settings.name}");
    switch (settings.name) {
      case RouteConstants.configScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.configScreen),
          builder: (context) {
            return ConfigScreen();
          },
        );
      case RouteConstants.splashScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.splashScreen),
          builder: (context) {
            return SplashScreen();
          },
        );
      case RouteConstants.homeScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.homeScreen),
          builder: (context) {
            final text = settings.arguments as HomeScreen;
            return HomeScreen(
              employee: text.employee,
              shift: text.shift,
              projectId: text.projectId,
              projectName: text.projectName,
            );
          },
        );
      case RouteConstants.startUnscheduledScreen:
        return MaterialPageRoute(
          settings:
              const RouteSettings(name: RouteConstants.startUnscheduledScreen),
          builder: (context) {
            final text = settings.arguments as StartUnscheduledScreen;
            return StartUnscheduledScreen(
              jobType: text.jobType,
              jobTypeId: text.jobTypeId,
              image: text.image,
              base64Image: text.base64Image,
              projectId: text.projectId,
              projectName: text.projectName,
              employee: text.employee,
            );
          },
        );
      case RouteConstants.loginScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.loginScreen),
          builder: (context) {
            return const LoginScreen();
          },
        );

      case RouteConstants.employeeScreen:
        final Map<String, dynamic>? arguments = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.employeeScreen),
          builder: (context) {
            return EmployeeScreen(
              projectId: arguments?['projectId'],
              projectName: arguments?['projectName'],
            );
          },
        );
      case RouteConstants.projectScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.projectScreen),
          builder: (context) {
            return const ProjectScreen();
          },
        );

    }

    assert(false, 'Need to implement ${settings.name}');
    return MaterialPageRoute(builder: (_) => UnknownScreen());
  }
}

class MenuSlideUpRoute<T> extends MaterialPageRoute<T> {
  MenuSlideUpRoute(
      {required WidgetBuilder builder, required RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}
