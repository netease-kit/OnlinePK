// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:livekit_pk/service/config/app_config.dart';
import 'package:livekit_pk/utils/LiveLog.dart';

class Servers {

  static const onlineUrl = 'https://meeting-api.netease.im/';

  /// https://reg.163.com/agreement_mobile_ysbh_wap.shtml?v=20171127
  final privacy = 'https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml';

  final userProtocol = 'https://netease.im/meeting/clauses?serviceType=0';

  final connectTimeout = 30000;
  final receiveTimeout = 15000;

  String get baseUrl {
    return onlineUrl;
  }

  String get universalLink {
    return onlineUrl;
  }
}

var servers = Servers();
