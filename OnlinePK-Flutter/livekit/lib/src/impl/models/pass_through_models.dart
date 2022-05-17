// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

class _NEActionAnchor {
  /// 直播编号
  int? liveRecordId;
  /// 房间 uid
  String? roomUuid;
  /// 用户编号
  String? userUuid;
  String? userName;
  String? icon;
  int? rewardTotal;
  /// 房间号
  String? channelName;
  /// 房间校验码
  String? checkSum;

  _NEActionAnchor._fromJson(Map json) {
    liveRecordId = json['liveRecordId'] as int?;
    rewardTotal = json['rewardTotal'] as int?;
    roomUuid = json['roomUuid'] as String?;
    userUuid = json['userUuid'] as String?;
    userName = json['userName'] as String?;
    icon = json['icon'] as String?;
    channelName = json['channelName'] as String?;
    checkSum = json['checkSum'] as String?;
  }
}

class _NETargetAnchor {
  int? rtcUid;
  String? checkSum;
  String? roomUuid;
  String? userName;
  String? userUuid;
  String? icon;

  _NETargetAnchor._fromJson(Map json) {
    rtcUid = json['rtcUid'] as int?;
    checkSum = json['checkSum'] as String?;
    roomUuid = json['roomUuid'] as String?;
    userUuid = json['userUuid'] as String?;
    userName = json['userName'] as String?;
    icon = json['icon'] as String?;
  }
}

class _NEAVRoom {
  String? rtcCid;
  String? channelName;

  _NEAVRoom._fromJson(Map json) {
    rtcCid = json['rtcCid'] as String?;
    channelName = json['channelName'] as String?;
  }
}

class _NEPKControlNotification {
  int? subCmd;
  int? type;
  String? senderUserUuid;
  int? sendTime;
  int? action;
  String? pkId;
  int? reason;
  _NEActionAnchor? actionAnchor;
  _NETargetAnchor? targetAnchor;
  _NEAVRoom? avRoom;

  _NEPKControlNotification._fromJson(Map json) {
    subCmd = json['subCmd'] as int?;
    type = json['type'] as int?;
    senderUserUuid = json['senderUserUuid'] as String?;
    sendTime = json['sendTime'] as int?;
    action = json['action'] as int?;
    pkId = json['pkId'] as String?;
    reason = json['reason'] as int?;
    var actionA = json['actionAnchor'] as Map?;
    if (actionA != null) {
      actionAnchor = _NEActionAnchor._fromJson(actionA);
    }
    var targetA = json['targetAnchor'] as Map?;
    if (targetA != null) {
      targetAnchor = _NETargetAnchor._fromJson(targetA);
    }
    var room = json['avRoom'] as Map?;
    if (room != null) {
      avRoom = _NEAVRoom._fromJson(room);
    }
  }
}