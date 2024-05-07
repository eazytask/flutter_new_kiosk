
import 'dart:io';

import 'package:kiosk/src/core/error/exception.dart';





void throwWhenSocketException(SocketException e) {
  var exception = FailureException("Login failed, please try again!");
  if (e.osError != null) {
    if (Platform.isAndroid) {
      if (e.osError!.errorCode == 7) {
        throw InternetConnectionException("Please check your internet connection!");
      } else if (e.osError!.errorCode == 110) {
        throw TimeoutConnectionException("Failed to establish proper connection!");
      } else if (e.osError!.errorCode == 111) {
        throw InternetConnectionException("Failed to establish proper connection!");
      }
    } else {
      if (e.osError!.errorCode == 8) {
        throw InternetConnectionException("Please check your internet connection!");
      } else if (e.osError!.errorCode == 60) {
        throw TimeoutConnectionException("Failed to establish proper connection!");
      } else if (e.osError!.errorCode == 61) {
        throw TimeoutConnectionException("Failed to establish proper connection!");
      }
    }
  }
  throw exception;
}