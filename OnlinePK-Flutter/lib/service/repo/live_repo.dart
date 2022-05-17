// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:livekit_pk/service/app_service.dart';

import '../response/result.dart';
import 'i_repo.dart';

class LiveRepo extends IRepo {
  LiveRepo._internal();

  static final LiveRepo _singleton = LiveRepo._internal();

  factory LiveRepo() => _singleton;

  /// get random topic
  Future<Result<String?>> getTopic() {
    return AppService().getTopic();
  }

  /// get random cover
  Future<Result<String?>> getCover() {
    return AppService().getCover();
  }
}