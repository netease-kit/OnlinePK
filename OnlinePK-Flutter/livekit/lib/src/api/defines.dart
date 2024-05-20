// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_livekit;

/// live status
enum NELiveStatus {
  /// idle
  idle,

  /// in living
  living,

  /// living end
  end,
}

/// room type
enum NELiveRoomType {
  /// invalid
  invalid,

  /// pk live
  pkLive,

  /// audio room
  multiAudio,

  /// KTV
  ktv,

  /// pk live ex
  pkLiveEx,
}

class NELiveRole {
  static const audience = NERoomBuiltinRole.OBSERVER;
  static const audienceOnSeat = 'audience';
  static const anchor = 'host';
}
