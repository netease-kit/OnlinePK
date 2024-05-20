// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_livekit;

class _NELiveBatchRewardMessage {
  String? senderUserUuid;
  int? sendTime;
  String? userName;
  String? userUuid;
  int? giftId;
  int? giftCount;
  List<_NELiveBatchSeatUserReward>? seatUserReward;
  List<_NELiveBatchSeatUserRewardee>? targets;

  _NELiveBatchRewardMessage._fromMap(Map? map) {
    senderUserUuid = map?['senderUserUuid'] as String?;
    sendTime = map?['sendTime'] as int?;
    userName = map?['userName'] as String?;
    userUuid = map?['userUuid'] as String?;
    giftId = map?['giftId'] as int?;
    giftCount = map?['giftCount'] as int?;
    seatUserReward = (map?['seatUserReward'] as List<dynamic>?)
        ?.map((e) =>
            _NELiveBatchSeatUserReward._fromMap(Map<String, dynamic>.from(e)))
        .toList();
    targets = (map?['targets'] as List<dynamic>?)
        ?.map((e) =>
            _NELiveBatchSeatUserRewardee._fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class _NELiveBatchSeatUserReward {
  int? seatIndex;
  String? userUuid;
  String? userName;
  int? rewardTotal;
  String? icon;

  _NELiveBatchSeatUserReward._fromMap(Map? map) {
    seatIndex = map?['seatIndex'] as int?;
    userUuid = map?['userUuid'] as String?;
    userName = map?['userName'] as String?;
    rewardTotal = map?['rewardTotal'] as int?;
    icon = map?['icon'] as String?;
  }
}

class _NELiveBatchSeatUserRewardee {
  String? userUuid;
  String? userName;
  String? icon;

  _NELiveBatchSeatUserRewardee._fromMap(Map? map) {
    userUuid = map?['userUuid'] as String?;
    userName = map?['userName'] as String?;
    icon = map?['icon'] as String?;
  }
}
