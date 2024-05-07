import 'dart:async';

import 'package:kiosk/src/app.dart';
import 'package:kiosk/src/core/presentation/screens/system_error_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:kiosk/src/core/error/logger.dart'
    show activateCrashlytics, cPrint, setupRemoteConfig;
import 'src/injection_container.dart' as di;

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    await di.init();
    ErrorWidget.builder = (errorDetails) => const CustomSystemErrorScreen();

    Future<FirebaseRemoteConfig> remoteConfig = setupRemoteConfig();

    activateCrashlytics();

    runApp(EazytaskKiosk(remoteConfig: remoteConfig,));
  },
      (error, stack) =>
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}
