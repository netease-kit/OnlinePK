// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_livekit;

typedef MessagesReceivedCallback = void Function(
    List<NERoomChatTextMessage> messages);
typedef RewardReceivedCallback = void Function(
    NELiveBatchRewardMessage message);
typedef LiveEndedCallback = void Function(int reason);
typedef LoginKickOutCallback = void Function();
typedef MembersJoinCallback = void Function(List<NERoomMember> members);
typedef MembersLeaveCallback = void Function(List<NERoomMember> members);
typedef MembersJoinChatroomCallback = void Function(List<NERoomMember> members);
typedef MembersLeaveChatroomCallback = void Function(
    List<NERoomMember> members);
typedef PushStartCallback = void Function();
typedef RtcLastmileQualityCallback = void Function(
    NERoomRtcNetworkStatusType status);
typedef RtcLastmileProbeResultCallback = void Function(
    NERoomRtcLastmileProbeResult result);

typedef MemberVideoMuteChangedCallback = void Function(
    NERoomMember member, bool mute, NERoomMember? operateBy);

typedef MembersJoinRtcCallback = void Function(List<NERoomMember> members);
typedef MemberLeaveRtcCallback = void Function(List<NERoomMember> members);

class NELiveCallback {
  ///加入Rtc
  final MembersJoinRtcCallback? membersJoinRtc;

  /// 成员离开RTC频道回调
  final MemberLeaveRtcCallback? memberLeaveRtc;

  /// 额外增加  监听拉流的状态
  final MemberVideoMuteChangedCallback? memberVideoMuteChanged;

  /// chatroom messages received
  final MessagesReceivedCallback? messagesReceived;

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

  /// members leave live
  final MembersJoinChatroomCallback? membersJoinChatroom;

  /// members leave live
  final MembersLeaveChatroomCallback? membersLeaveChatroom;

  /// live push start
  final PushStartCallback? pushStart;

  /// 报告本地用户的网络质量。
  final RtcLastmileQualityCallback? rtcLastmileQuality;

  /// 报告通话前网络上下行 last mile 质量。
  final RtcLastmileProbeResultCallback? rtcLastmileProbeResult;

  NELiveCallback({
    this.messagesReceived,
    this.rewardReceived,
    this.liveEnded,
    this.loginKickOut,
    this.membersJoin,
    this.membersLeave,
    this.membersJoinChatroom,
    this.membersLeaveChatroom,
    this.pushStart,
    this.rtcLastmileQuality,
    this.rtcLastmileProbeResult,
    this.memberVideoMuteChanged,
    this.membersJoinRtc,
    this.memberLeaveRtc,
  });
}
