// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:livekit_pk/service/config/app_config.dart';
import 'package:livekit_pk/service/proto/app_http_proto.dart';

class SendLoginSmsCodeProto extends AppHttpProto<void> {
  final String mobile;

  SendLoginSmsCodeProto(this.mobile);

  @override
  String path() {
    return '${AppConfig().getLoginBaseUrl}/userCenter/v1/auth/sendLoginSmsCode';
  }

  @override
  void result(Map map) {
    return null;
  }

  @override
  Map data() {
    return {'mobile': mobile};
  }

  @override
  bool checkLoginState() {
    return false;
  }
}
