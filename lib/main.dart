import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kiosk/src/app.dart';
import 'package:kiosk/src/core/helpers/notification_handler.dart';
import 'package:kiosk/src/core/presentation/screens/system_error_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:kiosk/src/core/error/logger.dart'
    show activateCrashlytics, cPrint, setupRemoteConfig;
import 'src/injection_container.dart' as di;
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // WidgetsFlutterBinding.ensureInitialized();
    // await Firebase.initializeApp();
    NotificationServices().init();
    NotificationServices().requestIOSPermissions();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      RemoteNotification? notification = message.notification;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && Platform.isAndroid) {
        NotificationServices().showNotifications(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          // payload: message.data,
        );

        print('Message also contained a notification: ${message.notification}');
      }
    });

    await di.init();
    ErrorWidget.builder = (errorDetails) => const CustomSystemErrorScreen();

    Future<FirebaseRemoteConfig> remoteConfig = setupRemoteConfig();

    activateCrashlytics();

    runApp(EazytaskKiosk(remoteConfig: remoteConfig,));
  },
      (error, stack) =>
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  print('Message data: ${message.data}');

  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  var messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: true,
    sound: true,
    provisional: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  // await messaging.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
}