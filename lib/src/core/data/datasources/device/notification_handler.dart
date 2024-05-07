//
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// class NotificationServices {
//   //instance of FlutterLocalNotificationsPlugin
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   Future<void> init() async {
//     //Initialization Settings for Android
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     //Initialization Settings for iOS
//     const DarwinInitializationSettings initializationSettingsIOS =
//     DarwinInitializationSettings();
//
//     //Initializing settings for both platforms (Android & iOS)
//     const InitializationSettings initializationSettings =
//     InitializationSettings(
//         android: initializationSettingsAndroid,
//         iOS: initializationSettingsIOS);
//
//     tz.initializeTimeZones();
//
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }
//
//   onSelectNotification(String? payload) async {
//     // if (payload != null && payload.isNotEmpty){
//     //   switch (payload) {
//     //     case 'unconfirmed-shift':
//     //       print(navigatorKey.currentState);
//     //       navigatorKey.currentState?.push(
//     //           MaterialPageRoute(
//     //               builder: (context) =>
//     //                   DashboardScreen()));
//     //
//     //       break;
//     //     case 'unconfirmed':
//     //       print('one!');
//     //       break;
//     //     case 'unconfi':
//     //       print('two!');
//     //       break;
//     //     default:
//     //       print('choose a different number!');
//     //   }
//     // }
//   }
//
//   requestIOSPermissions() {
//     flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//       alert: true,
//       badge: true,
//       sound: true,
//       critical: true,
//     );
//   }
//
//   Future<void> showNotifications({id, title, body, payload}) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//     AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       channelDescription: 'your channel description',
//       importance: Importance.high,
//       priority: Priority.high,
//       ticker: 'ticker',
//     );
//     const NotificationDetails platformChannelSpecifics =
//     NotificationDetails(android: androidPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin
//         .show(id, title, body, platformChannelSpecifics, payload: payload);
//   }
//
//   Future<void> scheduleNotifications({id, title, body, time}) async {
//     try {
//       await flutterLocalNotificationsPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         tz.TZDateTime.from(time, tz.local),
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'your channel id',
//             'your channel name',
//             channelDescription: 'your channel description',
//           ),
//         ),
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime,
//       );
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   Future<void> cancelScheduledNotification() async {
//     await flutterLocalNotificationsPlugin.cancelAll();
//   }
// }
