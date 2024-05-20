// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:livekit_sample/service/auth/login_info.dart';
import 'package:livekit_sample/service/auth/nemo_account.dart';
import 'package:livekit_sample/service/base_service.dart';
import 'package:livekit_sample/service/proto/login_by_nemo_proto.dart';
import 'package:livekit_sample/service/response/result.dart';
import 'proto/login_proto.dart';

/// http service
class AppService extends BaseService {
  AppService._internal();

  static final AppService _singleton = AppService._internal();

  factory AppService() => _singleton;

  Future<Result<NemoAccount>> loginByNemo() {
    return execute(LoginByNemoProto());
  }

  Future<Result<LoginInfo>> login(LoginProto loginProto) {
    return execute(loginProto);
  }
}
