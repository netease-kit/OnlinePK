// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_pk/service/config/app_config.dart';
import 'package:livekit_pk/service/proto/app_http_proto.dart';

class RandomCoverProto extends AppHttpProto<String> {
  RandomCoverProto();

  @override
  String path() {
    return '${AppConfig().liveBaseUrl}/v1/room/getRandomLivePic';
  }

  @override
  String? result(Map map) {
    return map['data'];
  }

  @override
  Map<String, dynamic>? header() {
    return {'lang': 'en'};
  }

  @override
  Map? data() {
    return {'accountId': NELiveKit.instance.userUuid ?? ''};
  }

  @override
  bool checkLoginState() {
    return false;
  }
}
