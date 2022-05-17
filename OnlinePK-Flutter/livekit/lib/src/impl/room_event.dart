// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

class _NELiveRoomEvent extends NERoomEventCallback {
  late NERoomEventCallback audienceRoomEvent;
  late NERoomEventCallback anchorRoomEvent;

  /// as invitee to join peer room
  late NERoomEventCallback peerRoomEvent;

  _NELiveRoomEvent() {
    audienceRoomEvent = NERoomEventCallback(
      memberJoinChatroom: _memberJoinChatroom,
      memberLeaveRoom: _memberLeaveRoom,
      memberLeaveChatroom: _audienceMembersLeaveChatroom,
      roomEnd: _audienceRoomEnd,
      chatroomMessagesReceived: _audienceChatroomMessagesReceived,
    );

    anchorRoomEvent = NERoomEventCallback(
      memberJoinChatroom: _memberJoinChatroom,
      memberLeaveRoom: _memberLeaveRoom,
      chatroomMessagesReceived: _anchorChatroomMessagesReceived,
      memberJoinRtcChannel: _anchorMemberJoinRtcChannel,
      roomEnd: _anchorRoomEnd,
      rtcChannelError: _anchorRtcChannelError,
      rtcAudioOutputDeviceChanged: _rtcAudioOutputDeviceChanged,
    );

    peerRoomEvent = NERoomEventCallback(
      roomEnd: _peerRoomEnd,
    );
  }

  _memberJoinChatroom(List<NERoomMember> members) {
    NELiveKit.instance._notifyMembersJoin(members);
  }

  _memberLeaveRoom(List<NERoomMember> members) {
    NELiveKit.instance._notifyMembersLeave(members);
  }

  _audienceMembersLeaveChatroom(List<NERoomMember> members) {}

  _audienceRoomEnd(NERoomEndReason reason) {
    NELiveKit.instance._resetLive(shouldNotify: true,reason:reason.index);
  }

  _anchorRoomEnd(NERoomEndReason reason) {
    NELiveKit.instance._resetLive(shouldNotify: true, reason: reason.index);
  }

  _peerRoomEnd(NERoomEndReason reason) {
    NELiveKit.instance._resetPK(shouldNotify: true);
  }

  _anchorRtcChannelError(int error) {
    NELiveKit.instance._resetLive(shouldNotify: true, reason: error);
  }

  _audienceChatroomMessagesReceived(List<NERoomMessage> messages) {
    _chatroomMessagesReceived(messages, false);
  }

  _anchorChatroomMessagesReceived(List<NERoomMessage> messages) {
    _chatroomMessagesReceived(messages, true);
  }

  _rtcAudioOutputDeviceChanged(NEAudioOutputDevice device){
    NELiveKit.instance.audioOutputDevice = device;
  }

  _anchorMemberJoinRtcChannel(List<NERoomMember> members) {
    for (var m in members) {
      if (m.uuid == NELiveKit.instance.userUuid) {
        // self joined
        NELiveKit.instance._startLivePush();
        break;
      }
    }
    // members join RTC, check if start pk message is received before
    _postPKStart();
  }

  _chatroomMessagesReceived(List<NERoomMessage> messages, bool isAnchor) {
    var textMessages = List<NERoomTextMessage>.empty(growable: true);
    for (var message in messages) {
      switch (message.messageType) {
        case NERoomMessageType.kCustom:
          {
            var customMessage = message as NERoomCustomMessage;
            var attach = customMessage.attachStr;
            _dealPKMessage(attach, isAnchor);
          }
          break;
        case NERoomMessageType.kText:
          {
            var textMessage = message as NERoomTextMessage;
            textMessages.add(textMessage);
          }
          break;
      }
    }
    if (textMessages.isNotEmpty) {
      NELiveKit.instance._notifyMessagesReceived(textMessages);
    }
  }

  _NEPKStartMessage? _pkStartMessage;

  _postPKStart() {
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null && _pkStartMessage != null) {
      var rtcMembers = List<String>.empty(growable: true);
      if (context.localMember.isInRtcChannel) {
        rtcMembers.add(context.localMember.uuid);
      }
      for (var member in context.remoteMembers) {
        if (member.isInRtcChannel) {
          rtcMembers.add(member.uuid);
        }
      }

      /// both anchor have joined rtc
      var inviteeId = _pkStartMessage!.invitee?.userUuid;
      var inviterId = _pkStartMessage!.inviter?.userUuid;
      if (rtcMembers.contains(inviterId) &&
          rtcMembers.contains(inviteeId) &&
          TextUtils.isNotEmpty(_pkStartMessage!.pkId) &&
          _pkStartMessage!.pkStartTime != null &&
          _pkStartMessage!.pkCountDown != null &&
          _pkStartMessage!.inviter != null &&
          _pkStartMessage!.invitee != null) {
        NELiveKit.instance._notifyPKStart(
            _pkStartMessage!.pkId!,
            _pkStartMessage!.pkStartTime!,
            _pkStartMessage!.pkCountDown!,
            _pkStartMessage!.inviter!,
            _pkStartMessage!.invitee!);
        _pkStartMessage = null;
      }
    }
  }

  _dealPKMessage(String content, bool isAnchor) {
    var map = json.decode(content);
    if (map is Map) {
      var subCmd = map['subCmd'] as int?;
      if (subCmd == 2) {
        var type = map['type'] as int?;
        switch (type) {
          case 2001:
            {
              /// pk start
              var obj = _NEPKStartMessage._fromMap(map);
              if (!isAnchor) {
                if (obj.pkId != null &&
                    obj.pkStartTime != null &&
                    obj.pkCountDown != null &&
                    obj.inviter != null &&
                    obj.invitee != null) {
                  NELiveKit.instance._notifyPKStart(obj.pkId!, obj.pkStartTime!,
                      obj.pkCountDown!, obj.inviter!, obj.invitee!);
                }
              } else {
                _pkStartMessage = obj;
                _postPKStart();
              }
            }
            break;
          case 2002:
            {
              /// punish
              var obj = _NEPKPunishMessage._fromMap(map);
              if (obj.pkId != null &&
                  obj.pkPenaltyCountDown != null &&
                  obj.inviter != null &&
                  obj.invitee != null &&
                  obj.inviteeRewards != null &&
                  obj.inviterRewards != null) {
                NELiveKit.instance._notifyPKPunishingStart(
                    obj.pkId!,
                    obj.pkPenaltyCountDown!,
                    obj.inviterRewards!,
                    obj.inviteeRewards!,
                    obj.inviter!,
                    obj.invitee!);
              }
            }
            break;
          case 2003:
            {
              /// pk end
              var obj = _NEPKStopMessage._fromMap(map);
              if (obj.pkId != null &&
                  obj.pkEndTime != null &&
                  obj.reason != null &&
                  obj.countDownEnd != null &&
                  obj.inviteeRewards != null &&
                  obj.inviterRewards != null &&
                  obj.senderUserUuid != null) {
                NELiveKit.instance._notifyPKEnd(
                    obj.pkId!,
                    obj.reason!,
                    obj.senderUserUuid!,
                    obj.userName!,
                    obj.pkEndTime!,
                    obj.inviterRewards!,
                    obj.inviteeRewards!,
                    obj.countDownEnd!);
              }
            }
            break;
          case 1001:
            {
              /// reward
              var obj = _NERewardMessage._fromMap(map);
              if (obj.rewarderUserUuid != null &&
                  obj.anchorReward != null &&
                  obj.otherAnchorReward != null &&
                  obj.giftId != null) {
                NELiveKit.instance._notifyRewardReceived(
                    obj.rewarderUserUuid!,
                    obj.rewarderUserName,
                    obj.giftId!,
                    obj.anchorReward!,
                    obj.otherAnchorReward!);
              }
            }
            break;
        }
      }
    }
  }
}
