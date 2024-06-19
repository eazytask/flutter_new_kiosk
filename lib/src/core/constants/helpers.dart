// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:image/image.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
DateTime getLastMondayOfWeek(DateTime today) {
  return today.subtract(Duration(days: today.weekday - 1));
}

DateTime getNextSundayOfWeek(DateTime today) {
  return today.add(Duration(days: 7 - today.weekday));
}

// get random alpha numeric string of n length
String getRandomString(int length) {
  var r = Random();
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(length, (index) => chars[r.nextInt(chars.length)])
      .join();
}

String imageToBase64({required String path, bool forUpload = true}) {
  // image to base64 with extension
  File file = File(path);
  // get extension
  String extension = path.split('.').last;
  Uint8List bytes = file.readAsBytesSync();
  String base64Image = base64Encode(bytes);
  return forUpload ? 'data:image/$extension;base64,$base64Image' : base64Image;
  // return base64Encode(bytes);
}

String sanitizeNull(String? str) {
  return str ?? '';
}

List chunks({required List array, int n = 3}) {
  // divide array into chunks
  List chunks = [];
  for (var i = 0; i < array.length; i += n) {
    chunks.add(array.sublist(i, min(i + n, array.length)));
  }
  return chunks;
}

DateTime getEndDate(DateTime date, DateTime endDate) {
  return date.add(Duration(hours: endDate.hour, minutes: endDate.minute));
}

// get Australian date time
DateTime getAustralianDateTime() {
  final DateTime now = DateTime.now();
  final DateTime utc = now.toUtc();
  final DateTime australianDateTime = utc.add(const Duration(hours: 10));
  return DateTime.parse(australianDateTime.toString().replaceAll("Z", ''));
}

DateTime getAuDateTime() {
  // final detroit = tz.getLocation('Australia/Sydney');
  // final localizedDt = tz.TZDateTime.from(DateTime.now(), detroit);
  // return localizedDt;


  final DateTime now = DateTime.now();
  final DateTime utc = now.toUtc();
  final DateTime australianDateTime = utc.add(const Duration(hours: 10));
  return DateTime.parse(australianDateTime.toString().replaceAll("Z", ''));

}

String getSystemTime() {
  var now = getAuDateTime();
  return '${twoDigit(now.hour)}:${twoDigit(now.minute)}:${twoDigit(now.second)}';
  // return "${(now.hour % 12 == 0 ? 12 : now.hour % 12).toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}${now.hour >= 12 ? " PM" : " AM"}";
}

String getShiftStartEndDuration(DateTime startTime, bool isAlreadyStarted) {

  final DateTime start = startTime;
  var now = getAuDateTime();

  Duration duration;
  if (isAlreadyStarted) {
    duration = now.difference(start);
  } else {
    duration = start.difference(now);
  }


  // final Duration duration = start.difference(now);
  final int hours = duration.inHours;
  final int minutes = duration.inMinutes - (hours * 60);
  final int seconds = duration.inSeconds - (hours * 60 * 60) - (minutes * 60);
  if (isAlreadyStarted) {
    return 'You Started working ${twoDigit(hours.abs())}:${twoDigit(minutes.abs())}:${twoDigit(seconds.abs())} ago';
  } else if (duration.isNegative) {
    return 'Work Started ${twoDigit(hours.abs())}:${twoDigit(minutes.abs())}:${twoDigit(seconds.abs())} ago';
  }
  return 'Starts in ${twoDigit(hours.abs())}:${twoDigit(minutes.abs())}:${twoDigit(seconds.abs())}';
  // return 'Starts in ${twoDigit(hours)}:${twoDigit(minutes)}:${twoDigit(seconds)}';
}
String twoDigit(int num) {
  return (num >= 10) ? '$num' : '0$num';
}

String formatDate(String? date) {
  if (date == null) return '';
  // format d/m/y
  final DateTime dateTime = DateTime.parse(date);
  return '${twoDigit(dateTime.day)}-${twoDigit(dateTime.month)}-${dateTime.year}';
}

String getDurationInHours(String? start, String? end) {
  if (start == null || end == null) return '0';
  final Duration duration =
  DateTime.parse(end).difference(DateTime.parse(start));
  final int hours = duration.inHours;
  final int minutes = duration.inMinutes - (hours * 60);
  return '${twoDigit(hours)}:${twoDigit(minutes)}';
}

String dateTimeToTime(DateTime dateTime) {
  return '${twoDigit(dateTime.hour)}:${twoDigit(dateTime.minute)}';
}

String get12HourTime(String? date) {
  if (date == null) return '';
  final DateTime dateTime = DateTime.parse(date);
  // 24 hour format
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

DateTime getDateTimeFormat(String? date) {
  if (date == null) return DateTime.now();
  final DateTime dateTime = DateTime.parse(date);
  // 24 hour format
  return dateTime;
}

String getDayAndDate(String? date) {
  if (date == null) return '';
  DateTime dateTime = DateTime.parse(date);
  return '${getDay(dateTime.weekday)}, ${dateTime.day.toString()} ${getMonth(dateTime.month)} ${dateTime.year.toString()}';
}

String getDay(int day) {
  // 15 Sep
  switch (day) {
    case 1:
      return "Mon";
    case 2:
      return "Tue";
    case 3:
      return "Wed";
    case 4:
      return "Thu";
    case 5:
      return "Fri";
    case 6:
      return "Sat";
    case 7:
      return "Sun";
    default:
      return "";
  }
}

String getMonth(int month) {
  switch (month) {
    case 1:
      return "Jan";
    case 2:
      return "Feb";
    case 3:
      return "Mar";
    case 4:
      return "Apr";
    case 5:
      return "May";
    case 6:
      return "Jun";
    case 7:
      return "Jul";
    case 8:
      return "Aug";
    case 9:
      return "Sep";
    case 10:
      return "Oct";
    case 11:
      return "Nov";
    case 12:
      return "Dec";
    default:
      return "";
  }
}

String ucWords(String str) {
  // make first latter of each word capital
  return str
      .split(" ")
      .map((word) =>
  word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word)
      .join(" ");
}

void navigateTo({
  required BuildContext context,
  required String routeName,
  bool removePrevious = false,
  bool isReplace = false,
  Object? arguments,
  bool clear = false,
}) {
  // clear all previous routes
  if (clear) {
    //  clear all previous routes
    // Navigator.of(context).popUntil((route) => false);
    Navigator.of(context).pushNamed(
      routeName,
      arguments: arguments,
    );
  } else if (removePrevious) {
    // remove previous route
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      ModalRoute.withName(routeName),
      arguments: arguments,
    );
  } else if (isReplace) {
    // replace current route
    Navigator.of(context).pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  } else {
    // push new route
    Navigator.of(context).pushNamed(
      routeName,
      arguments: arguments,
    );
  }
}


void delay(int second) async {
  await Future.delayed(Duration(seconds: second));
}

// dynamic number of parameters

void printMessage(message) {
  // if development mode then print message
  print("******************************");
  print(message);
  print("******************************");
}

void showSnackBar({
  required BuildContext context,
  required String message,
  Color color = Colors.green,
  String status = "success",
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: getColor(status),
    ),
  );
}



Color getColor(String status) {
  switch (status) {
    case "success":
      return Colors.green;
    case "error":
      return Colors.red;
    case "warning":
      return Colors.orange;
    default:
      return Colors.green;
  }
}



// String calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//   // calculate distance between two points
//   final double distanceInMeters = Geolocator.distanceBetween(
//     lat1,
//     lon1,
//     lat2,
//     lon2,
//   );
//
//   if (distanceInMeters < 1000) {
//     return '${distanceInMeters.toStringAsFixed(0)} m';
//   } else {
//     return '${(distanceInMeters * 0.000621371).toStringAsFixed(1)} Miles';
//   }
// }

// Future<Map<String, dynamic>> getLocation() async {
//   try {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return {"lat": "0", "long": "0"};
//       }
//     }
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     return {
//       "lat": position.latitude.toString(),
//       "long": position.longitude.toString(),
//     };
//   } catch (e) {
//     printMessage(e);
//     return {"lat": "0", "long": "0"};
//   }
//   // check permission
// }
