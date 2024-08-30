// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_livekit/netease_livekit.dart';

class LiveUtils {
  static bool isSelf(String uuid) {
    return uuid == NELiveKit.instance.userUuid;
  }

  static bool isAnchor(String uuid) {
    return uuid == NELiveKit.instance.liveDetail?.anchor?.userUuid;
  }
}
