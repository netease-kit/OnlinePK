// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:livekit_pk/service/auth/login_info.dart';
import 'package:livekit_pk/service/config/app_config.dart';
import 'package:livekit_pk/service/proto/app_http_proto.dart';

class LoginByEmailProto extends AppHttpProto<LoginInfo> {
  final String email;

  final String password;

  LoginByEmailProto(this.email, this.password);

  @override
  String path() {
    return '${AppConfig().getLoginBaseUrl}/userCenter/v1/auth/email/login';
  }

  @override
  LoginInfo result(Map map) {
    return LoginInfo.fromJson(map);
  }

  @override
  Map data() {
    return {'email': email, 'password': password};
  }

  @override
  bool checkLoginState() {
    return false;
  }
}
