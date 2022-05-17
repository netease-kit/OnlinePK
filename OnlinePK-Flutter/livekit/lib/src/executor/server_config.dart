// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

class ServersConfig {
  static final String _serverUrl = 'https://yiyong-xedu-v2-test.netease.im';

  int get connectTimeout => 30000;

  int get receiveTimeout => 10000;

  static final ServersConfig _instance = ServersConfig._();

  ServersConfig._();

  factory ServersConfig() => _instance;

  bool _serverUrlTouched = false;

  String? _privateServerUrl;

  set serverUrl(String url) {
    assert(
    !_serverUrlTouched, 'Cannot set server url after it has been touched');
    if (_privateServerUrl == null && TextUtils.isNotEmpty(url)) {
      _privateServerUrl = url;
      assert((){
        print('set custom server url: $url');
        return true;
      }());
      // Alog.i(
      //     tag: 'ServersConfig', moduleName: _moduleName, content: 'set custom server url: $url');
    }
  }

  String get baseUrl {
    assert(() {
      _serverUrlTouched = true;
      return true;
    }());
    var baseUrl = TextUtils.isNotEmpty(_privateServerUrl)
        ? _privateServerUrl
        : _serverUrl;
    return baseUrl!;
  }

  String? userUuid;
  String? token;
  String? deviceId;
}