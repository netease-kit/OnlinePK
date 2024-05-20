// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:livekit_sample/config/app_config.dart';
import 'package:livekit_sample/utils/live_log.dart';

class Servers {
  final connectTimeout = 30000;
  final receiveTimeout = 15000;

  String get baseUrl {
    return AppConfig().liveKitUrl;
  }
}

var servers = Servers();
