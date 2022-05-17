// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

class _NEPKStartMessage {
  int? subCmd;
  int? type;
  String? pkId;
  String? senderUserUuid;
  int? sendTime;
  int? pkStartTime;
  int? pkCountDown;
  _NEPKStartAnchor? inviter;
  _NEPKStartAnchor? invitee;

  _NEPKStartMessage._fromMap(Map? map) {
    subCmd = map?['subCmd'] as int?;
    type = map?['type'] as int?;
    pkId = map?['pkId'] as String?;
    senderUserUuid = map?['senderUserUuid'] as String?;
    sendTime = map?['sendTime'] as int?;
    pkStartTime = map?['pkStartTime'] as int?;
    pkCountDown = map?['pkCountDown'] as int?;
    inviter = _NEPKStartAnchor._fromMap(map?['inviter'] as Map?);
    invitee = _NEPKStartAnchor._fromMap(map?['invitee'] as Map?);
  }
}

class _NEPKStartAnchor {
  String? roomUuid;
  String? userUuid;
  int? rewardTotal;
  int? rtcUid;
  String? userName;
  String? icon;

  _NEPKStartAnchor._fromMap(Map? map) {
    roomUuid = map?['roomUuid'] as String?;
    userUuid = map?['userUuid'] as String?;
    rewardTotal = map?['rewardTotal'] as int?;
    rtcUid = map?['rtcUid'] as int?;
    userName = map?['userName'] as String?;
    icon = map?['icon'] as String?;
  }
}

class _NEPKStopAnchor {
  String? roomUuid;
  String? userUuid;
  int? pkId;

  _NEPKStopAnchor._fromMap(Map? map) {
    roomUuid = map?['roomUuid'] as String?;
    userUuid = map?['userUuid'] as String?;
    pkId = map?['pkId'] as int?;
  }
}

class _NEPKStopMessage {
  int? subCmd;
  int? type;
  String? pkId;
  String? senderUserUuid;
  int? sendTime;
  String? userName;
  int? reason;
  int? pkStartTime;
  int? pkEndTime;
  int? inviterRewards;
  int? inviteeRewards;
  bool? countDownEnd;
  _NEPKStopAnchor? inviter; // 不带rewardTotal
  _NEPKStopAnchor? invitee; // 不带rewardTotal

  _NEPKStopMessage._fromMap(Map? map) {
    subCmd = map?['subCmd'] as int?;
    type = map?['type'] as int?;
    pkId = map?['pkId'] as String?;
    senderUserUuid = map?['senderUserUuid'] as String?;
    sendTime = map?['sendTime'] as int?;
    userName = map?['userName'] as String?;
    reason = map?['reason'] as int?;
    pkStartTime = map?['pkStartTime'] as int?;
    pkEndTime = map?['pkEndTime'] as int?;
    inviterRewards = map?['inviterRewards'] as int?;
    inviteeRewards = map?['inviteeRewards'] as int?;
    countDownEnd = map?['countDownEnd'] as bool?;
    inviter = _NEPKStopAnchor._fromMap(map?['inviter'] as Map?);
    invitee = _NEPKStopAnchor._fromMap(map?['invitee'] as Map?);
  }
}

class _NEPunishAnchor {
  String? roomUuid;
  String? userUuid;

  _NEPunishAnchor._fromMap(Map? map) {
    roomUuid = map?['roomUuid'] as String?;
    userUuid = map?['userUuid'] as String?;
  }
}

class _NEPKPunishMessage {
  int? subCmd;
  int? type;
  String? pkId;
  String? senderUserUuid;
  int? sendTime;
  int? pkStartTime;
  int? pkPenaltyCountDown;
  int? inviterRewards;
  int? inviteeRewards;
  _NEPunishAnchor? inviter;
  _NEPunishAnchor? invitee;

  _NEPKPunishMessage._fromMap(Map? map) {
    subCmd = map?['subCmd'] as int?;
    type = map?['type'] as int?;
    pkId = map?['pkId'] as String?;
    senderUserUuid = map?['senderUserUuid'] as String?;
    sendTime = map?['sendTime'] as int?;
    pkStartTime = map?['pkStartTime'] as int?;
    inviterRewards = map?['inviterRewards'] as int?;
    inviteeRewards = map?['inviteeRewards'] as int?;
    pkPenaltyCountDown = map?['pkPenaltyCountDown'] as int?;
    inviter = _NEPunishAnchor._fromMap(map?['inviter'] as Map?);
    invitee = _NEPunishAnchor._fromMap(map?['invitee'] as Map?);
  }
}

class _NEPkRewardTop {
  String? userUuid;
  String? userName;
  String? icon;
  int? rewardCoin;

  _NEPkRewardTop._fromMap(Map? map) {
    userName = map?['userName'] as String?;
    userUuid = map?['userUuid'] as String?;
    icon = map?['icon'] as String?;
    rewardCoin = map?['rewardCoin'] as int?;
  }
}

class _NEAnchorReward {
  String? userUuid;
  int? pkRewardTotal;
  int? rewardTotal;
  List<_NEPkRewardTop>? pkRewardTop;

  _NEAnchorReward._fromMap(Map? map) {
    userUuid = map?['userUuid'] as String?;
    pkRewardTotal = map?['pkRewardTotal'] as int?;
    rewardTotal = map?['rewardTotal'] as int?;
    pkRewardTop = (map?['pkRewardTop'] as List<dynamic>?)?.map((e) => _NEPkRewardTop._fromMap(Map<String, dynamic>.from(e))).toList();
  }
}

class _NERewardMessage {
  int? subCmd;
  int? type;
  String? senderUserUuid;
  int? sendTime;
  int? pkStartTime;
  String? rewarderUserUuid;
  String? rewarderUserName;
  int? giftId;
  int? memberTotal;
  _NEAnchorReward? anchorReward;
  _NEAnchorReward? otherAnchorReward;

  _NERewardMessage._fromMap(Map? map) {
    subCmd = map?['subCmd'] as int?;
    type = map?['type'] as int?;
    senderUserUuid = map?['senderUserUuid'] as String?;
    sendTime = map?['sendTime'] as int?;
    pkStartTime = map?['pkStartTime'] as int?;
    rewarderUserUuid = map?['rewarderUserUuid'] as String?;
    rewarderUserName = map?['rewarderUserName'] as String?;
    giftId = map?['giftId'] as int?;
    memberTotal = map?['memberTotal'] as int?;
    anchorReward = _NEAnchorReward._fromMap(map?['anchorReward'] as Map?);
    otherAnchorReward = _NEAnchorReward._fromMap(map?['otherAnchorReward'] as Map?);
  }
}