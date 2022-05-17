// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:livekit_pk/service/auth/login_info.dart';
import 'package:livekit_pk/service/base_service.dart';
import 'package:livekit_pk/service/proto/login_by_email_proto.dart';
import 'package:livekit_pk/service/proto/random_cover_proto.dart';
import 'package:livekit_pk/service/proto/random_topic_proto.dart';
import 'package:livekit_pk/service/proto/register_by_email_proto.dart';
import 'package:livekit_pk/service/proto/send_login_email_code_proto.dart';
import 'package:livekit_pk/service/proto/send_login_sms_code_proto.dart';
import 'package:livekit_pk/service/proto/login_register_by_code_proto.dart';
import 'package:livekit_pk/service/response/model/login_response.dart';
import 'package:livekit_pk/service/response/result.dart';
import 'proto/login_proto.dart';

/// http service
class AppService extends BaseService {
  AppService._internal();

  static final AppService _singleton = AppService._internal();

  factory AppService() => _singleton;

  Future<Result<void>> getAuthCode(String mobile) {
    return execute(SendLoginSmsCodeProto(mobile));
  }

  Future<Result<LoginInfo>> loginByAuthCode(String mobile, String authCode) {
    return execute(LoginRegisterByCodeProto(mobile, authCode));
  }

  Future<Result<LoginInfo>> loginByEmail(String email, String password) {
    return execute(LoginByEmailProto(email, password));
  }

  Future<Result<LoginInfo>> registerByEmail(String email, String password, String checkPassword, String emailCode) {
    return execute(RegisterByEmailProto(email, password, checkPassword, emailCode));
  }

  Future<Result<LoginInfo>> sendLoginEmailCode(String email) {
    return execute(SendLoginEmailCodeProto(email));
  }

  Future<Result<LoginInfo>> login(LoginProto loginProto) {
    return execute(loginProto);
  }

  /// get random topic
  Future<Result<String?>> getTopic() {
    return execute(RandomTopicProto());
  }

  /// get random cover
  Future<Result<String?>> getCover() {
    return execute(RandomCoverProto());
  }
}

