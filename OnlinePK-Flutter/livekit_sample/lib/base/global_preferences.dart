// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import '../utils/sp_util.dart';

class GlobalPreferences extends Preferences {
  static const String keyLoginInfo = "loginInfo";
  static const String keyDeviceId = "deviceId";

  GlobalPreferences._internal();

  static final GlobalPreferences _singleton = GlobalPreferences._internal();

  factory GlobalPreferences() => _singleton;

  Future<void> setDeviceId(String deviceId) async {
    setSp(keyDeviceId, deviceId);
  }

  Future<String?> get deviceId async {
    return getSp(keyDeviceId);
  }

  Future<void> setLoginInfo(String value) async {
    setSp(keyLoginInfo, value);
  }

  Future<String?> get loginInfo async {
    return getSp(keyLoginInfo);
  }
}
