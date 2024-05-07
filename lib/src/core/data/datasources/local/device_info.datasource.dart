import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:device_info/device_info.dart';
import 'package:kiosk/src/core/error/logger.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

class DeviceInfo {
  String deviceId = "";
  String name = "";
  String deviceVersion = "";
  String type = "";
  String apiVersion = "";
  String backendApiVersion = "v1";
  String mobileAppVersionCode = "1";
  String projectVersion = "1.0.1";
  String projectName = "Eazytask Kiosk";
  String packageName = "com.eazytask";

  String get userAgent =>
      Uri.encodeFull("$projectName $mobileAppVersionCode $projectVersion $packageName $backendApiVersion "
          "$type $apiVersion $name $deviceVersion $deviceId");

  void _readIosDeviceInfo(IosDeviceInfo data, PackageInfo info) {
    name = data.name;
    name = name.replaceAll(RegExp(r'[^\w\s]+'),'');
    deviceVersion = data.systemName;
    type = "IOS";
    apiVersion = data.systemVersion;
    mobileAppVersionCode = info.buildNumber;
    packageName = info.packageName;
    deviceId = data.identifierForVendor;
    deviceId = deviceId.replaceAll("-", " ");

  }

  Future<void> _readAndroidDeviceInfo(AndroidDeviceInfo data, PackageInfo info) async {
    name = data.brand;
    name = name.replaceAll(RegExp(r'[^\w\s]+'),'');
    deviceVersion = data.model;
    type = "Android";
    mobileAppVersionCode = info.buildNumber;
    packageName = info.packageName;
    apiVersion = data.version.sdkInt.toString();
    deviceId = await AdvertisingId.id() ?? "";
  }

  Future<void> _readProjectInfo() async {
    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      projectVersion = packageInfo.version;
    });
  }

  Future<String> getUserAgent() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    late PackageInfo info;
    await PackageInfo.fromPlatform().then((value) => info = value);
    try {
      if (Platform.isAndroid) {
        await deviceInfoPlugin.androidInfo
            .then((value) async => await _readAndroidDeviceInfo(value, info));
      } else if (Platform.isIOS) {
        await deviceInfoPlugin.iosInfo
            .then((value) => _readIosDeviceInfo(value, info));
      }
      await _readProjectInfo();
    } on PlatformException catch (e) {
      cPrint("Failed to get device info", errorIn: "PlatformException");
    }
    return userAgent;
  }
}
