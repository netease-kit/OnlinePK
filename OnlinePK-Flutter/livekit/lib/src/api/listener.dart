// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

typedef MessagesReceivedCallback = void Function(List<NERoomTextMessage> messages);
typedef PKInvitedCallback = void Function(NELivePKAnchor actionAnchor);
typedef PKCanceledCallback = void Function(NELivePKAnchor actionAnchor);
typedef PKRejectedCallback = void Function(NELivePKAnchor actionAnchor);
typedef PKAcceptedCallback = void Function(NELivePKAnchor actionAnchor);
typedef PKTimeoutCallback = void Function(NELivePKAnchor actionAnchor);
typedef PKStartCallback = void Function(int pkStartTime, int pkCountDown, NELivePKAnchor self, NELivePKAnchor peer);
typedef PKPunishmentStartCallback = void Function(int pkPenaltyCountDown, int selfRewards, int peerRewards);
typedef PKEndedCallback = void Function(int reason, int pkEndTime, String senderUserUuid, String userName, int selfRewards, int peerRewards, bool countDownEnd);
typedef RewardReceivedCallback = void Function(String rewarderUserUuid, String? rewarderUserName, int giftId, NELiveAnchorReward anchorReward, NELiveAnchorReward otherAnchorReward);
typedef LiveEndedCallback = void Function(int reason);
typedef LoginKickOutCallback = void Function();
typedef MembersJoinCallback = void Function(List<NERoomMember> members);
typedef MembersLeaveCallback = void Function(List<NERoomMember> members);
typedef PushStartCallback = void Function();

class NELiveCallback {

  /// chatroom messages received
  final MessagesReceivedCallback? messagesReceived;
  /// pk invite received
  final PKInvitedCallback? pKInvited;
  /// pk invite canceled
  final PKCanceledCallback? pKCanceled;
  /// pk invite rejected
  final PKRejectedCallback? pKRejected;
  /// pk invite accepted
  final PKAcceptedCallback? pKAccepted;
  /// pk timeout
  final PKTimeoutCallback? pKTimeout;
  /// pk start
  final PKStartCallback? pkStart;
  /// pk punishment start
  final PKPunishmentStartCallback? pkPunishmentStart;
  /// pk ended
  final PKEndedCallback? pkEnded;
  /// reward received
  final RewardReceivedCallback? rewardReceived;
  /// live ended
  final LiveEndedCallback? liveEnded;
  /// client kick out
  final LoginKickOutCallback? loginKickOut;
  /// members join live
  final MembersJoinCallback? membersJoin;
  /// members leave live
  final MembersLeaveCallback? membersLeave;
  /// live push start
  final PushStartCallback? pushStart;

  NELiveCallback({
    this.messagesReceived,
    this.pKInvited,
    this.pKCanceled,
    this.pKRejected,
    this.pKAccepted,
    this.pKTimeout,
    this.pkStart,
    this.pkPunishmentStart,
    this.pkEnded,
    this.rewardReceived,
    this.liveEnded,
    this.loginKickOut,
    this.membersJoin,
    this.membersLeave,
    this.pushStart,
  });
}