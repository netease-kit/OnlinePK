// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:livekit_pk/service/auth/login_info.dart';
import 'package:livekit_pk/service/config/app_config.dart';
import 'package:livekit_pk/service/proto/app_http_proto.dart';

class LoginRegisterByCodeProto extends AppHttpProto<LoginInfo> {
  final String mobile;

  final String smsCode;

  LoginRegisterByCodeProto(this.mobile, this.smsCode);

  @override
  String path() {
    return '${AppConfig().loginBaseUrl}/userCenter/v1/auth/loginRegisterByCode';
  }

  @override
  LoginInfo result(Map map) {
    return LoginInfo.fromJson(map);
  }

  @override
  Map data() {
    return {'mobile': mobile, 'smsCode': smsCode};
  }

  @override
  bool checkLoginState() {
    return false;
  }
}
