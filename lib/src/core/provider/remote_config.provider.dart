
import 'dart:io';

import 'package:kiosk/src/core/data/datasources/local/device_info.datasource.dart';
import 'package:kiosk/src/core/provider/base.provider.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
class RemoteConfigProvider extends BaseProvider {
  FirebaseRemoteConfig? _remoteConfig;

  FirebaseRemoteConfig? get remoteConfig => _remoteConfig;
  set remoteConfig(FirebaseRemoteConfig? config) {
    _remoteConfig = config;
  }

  Future<bool> checkIfConnectionChangeAvailable() {
    var info =  DeviceInfo();
    var condition = false;
    try {
      return info.getUserAgent().then((value) async {
        bool updated = await _remoteConfig?.fetchAndActivate() ?? false;
        if (Platform.isAndroid) {
          condition = _remoteConfig?.getString('flavour') == "dev"
              && _remoteConfig?.getString('android_version_code') == info.mobileAppVersionCode;
        } else {
          condition = _remoteConfig?.getString('flavour') == "dev"
              && _remoteConfig?.getString('ios_version_code') == info.mobileAppVersionCode;
        }
        print(condition);
        return condition;
      });
    } catch (e) {
      return Future.value(false);
    }
  }

}