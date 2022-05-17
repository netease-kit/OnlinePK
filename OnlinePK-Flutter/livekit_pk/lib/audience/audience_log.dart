// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:yunxin_alog/yunxin_alog.dart';

class AudienceLog{
  static void log(String msg){
      Alog.d(tag: "[AudienceLog]:", content: msg);
  }
}