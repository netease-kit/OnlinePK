// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

/// PK status
enum NEEndPKStatus {
  /// invalid
  invalid,

  /// normal
  isNormal ,

  /// errorCase
  notNormal,

}

/// PK status
enum NELivePKStatus {
  /// idle
  idle,

  /// inviting
  inviting,

  /// invited
  invited,

  /// in pk
  pking,

  /// in punish
  punishing,
}

/// pk state from server, only used in [NELivePKDetail]
enum NELivePKState {
  /// inviting
  inviting,
  /// in pk
  pking,
  /// invite rejected
  rejected,
  /// invite canceled
  canceled,
  /// pk ended
  pKEnded,
  /// invite timeout
  timeout,
  /// invite accepted
  accepted,
  /// in punishing
  punishing,
}

/// live status
enum NELiveStatus {
  /// idle
  idle,

  /// in living
  living,

  /// in pk
  pking,

  /// in punish
  punishing,

  /// in connecting
  connected,

  /// inviting
  inviting,

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
