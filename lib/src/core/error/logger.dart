import 'dart:developer' as developer;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart' as remoteConf;

import 'package:flutter/foundation.dart' show FlutterError, kDebugMode;

void cPrint(dynamic data, {String? errorIn, String? event}) {
  if (errorIn != null) {
    print(
        '****************************** error ******************************');
    developer.log('[Error]', time: DateTime.now(), error:data, name:errorIn);
    print(
        '****************************** error ******************************');
  } else if (data != null) {
    developer.log(data, time: DateTime.now(), );
  }
  if (event != null) {
    // logEvent(event);
  }
}

void logEvent(event) {

}

void logExceptionCrashlytics() {

}

Future<void> logInCrashlytics(String error, StackTrace? stackTrace, ) async {
  FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'a non-fatal error'
  );
}

void logSimpleMessageToCrashlytics(String key, var value) async {
  try {
    FirebaseCrashlytics.instance.setCustomKey(key, value);
  } catch (e) {
    print(e);
  }
}

void logCustomMessage(String message) {
  FirebaseCrashlytics.instance.log(message);
}

void setCrashlyticsUserIdentifier(String identifier) {
  FirebaseCrashlytics.instance.setUserIdentifier(identifier);
}

Future<void> activateCrashlytics() async {
  if (!kDebugMode) {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(true);
  } else {
    if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
      cPrint("Collection is enabled.");
    }
  }


  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Pass all uncaught errors from the framework to Crashlytics.
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
}


Future<remoteConf.FirebaseRemoteConfig> setupRemoteConfig() async {
  final remoteConf.FirebaseRemoteConfig remoteConfig = remoteConf.FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(remoteConf.RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(seconds: 1),
  ));
  await remoteConfig.setDefaults(<String, dynamic>{
    'flavour': 'dev',
    'android_version_code': "1",
    'ios_version_code': "1"
  });
  remoteConf.RemoteConfigValue(null, remoteConf.ValueSource.valueStatic);
  return remoteConfig;
}