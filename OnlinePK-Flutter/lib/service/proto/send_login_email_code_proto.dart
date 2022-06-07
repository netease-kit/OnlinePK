// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:livekit_pk/service/auth/login_info.dart';
import 'package:livekit_pk/service/config/app_config.dart';
import 'package:livekit_pk/service/proto/app_http_proto.dart';

class SendLoginEmailCodeProto extends AppHttpProto<LoginInfo> {
  final String email;

  SendLoginEmailCodeProto(this.email);

  @override
  String path() {
    return '${AppConfig().loginBaseUrl}/userCenter/v1/auth/email/sendLoginEmailCode';
  }

  @override
  LoginInfo result(Map map) {
    return LoginInfo.fromJson(map);
  }

  @override
  Map data() {
    return {
      'email': email,
    };
  }

  @override
  bool checkLoginState() {
    return false;
  }
}
