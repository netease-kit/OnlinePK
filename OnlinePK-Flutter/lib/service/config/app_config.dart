// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

import '../../base/device_manager.dart';
import '../../base/global_preferences.dart';
import '../../base/timeutil.dart';

class Flavor {
  static const String public = 'public';
  static const String mail = 'mail';
}

class AppConfig {
  factory AppConfig() => _instance ??= AppConfig._internal();

  static AppConfig? _instance;

  AppConfig._internal();

  String appKey='your appKey';

  late int onlineScope = 3;

  late int testScope = 8;

  late int sgScope = 3;

  late int onlineParentScope = 5;

  late int testParentScope = 3;

  late int sgParentScope = 5;

  late String versionName;

  late String versionCode;

  /// build time
  String time=TimeUtil.getTimeFormatMillisecond();

  static var _debugMode = false;

  String get getAppKey {
    return appKey;
  }

  String get getLoginBaseUrl {
    return 'https://yiyong-user-center.netease.im';
  }

  String get getLiveBaseUrl {
    return 'http://yiyong-ne-live.netease.im';
  }

  String get getLiveKitUrl {
    return 'https://roomkit-sg.netease.im';
  }


  int get getScope {
    return sgScope;
  }

  int get getParentScope {
    return sgParentScope;
  }

  bool get isPublicFlavor {
    return true;
  }

  bool get isMailFlavor {
    return false;
  }

  static bool get isInDebugMode {
    return _debugMode;
  }

  Future init() async {
    _debugMode = await GlobalPreferences().meetingDebug == true;
    await DeviceManager().init();
    await loadPackageInfo();
    return Future.value();
  }

  Future<void> loadPackageInfo() async {
    var info = await PackageInfo.fromPlatform();
    versionCode = info.buildNumber;
    versionName = info.version;
  }

  static Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId
    };
  }
  static Map<String, dynamic> readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}
