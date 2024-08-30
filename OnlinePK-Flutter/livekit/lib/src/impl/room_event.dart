// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_livekit;

class _NELiveRoomEvent extends NERoomEventCallback with _AloggerMixin {
  late NERoomEventCallback audienceRoomEvent;
  late NERoomEventCallback anchorRoomEvent;
  bool isFrontCamera = true;

  _NELiveRoomEvent() {
    audienceRoomEvent = NERoomEventCallback(
      roomEnd: _audienceRoomEnd,
      chatroomMessagesReceived: _audienceChatroomMessagesReceived,
      memberVideoMuteChanged: _memberVideoMuteChanged,

      ///监听拉流的状态
      memberJoinRtcChannel: _anchorMemberJoinRtcChannel,
      memberLeaveRtcChannel: _anchorMemberLeaveRtcChannel,
      memberRoleChanged: _audienceRoleChanged,
    );

    anchorRoomEvent = NERoomEventCallback(
      chatroomMessagesReceived: _anchorChatroomMessagesReceived,
      memberJoinRtcChannel: _anchorMemberJoinRtcChannel,
      roomEnd: _anchorRoomEnd,
      rtcChannelError: _anchorRtcChannelError,
      rtcAudioOutputDeviceChanged: _rtcAudioOutputDeviceChanged,
      memberJoinRoom: _memberJoinRoom,
      memberLeaveRoom: _memberLeaveRoom,
      memberJoinChatroom: _memberJoinChatroom,
      memberLeaveChatroom: _memberLeaveChatroom,
    );
  }

  _memberVideoMuteChanged(
      NERoomMember member, bool mute, NERoomMember? operateBy) {
    NELiveKit.instance._notifyMemberVideoMuteChanged(member, mute, operateBy);
  }

  _memberJoinRoom(List<NERoomMember> members) {
    NELiveKit.instance._notifyMembersJoinRoom(members);
  }

  _memberLeaveRoom(List<NERoomMember> members) {
    NELiveKit.instance._notifyMembersLeaveRoom(members);
  }

  _memberJoinChatroom(List<NERoomMember> members) {
    NELiveKit.instance._notifyMembersJoinChatroom(members);
  }

  _memberLeaveChatroom(List<NERoomMember> members) {
    NELiveKit.instance._notifyMembersLeaveChatroom(members);
  }

  _audienceRoomEnd(NERoomEndReason reason) {
    NELiveKit.instance._resetLive(shouldNotify: true, reason: reason.index);
  }

  _anchorRoomEnd(NERoomEndReason reason) {
    NELiveKit.instance._resetLive(shouldNotify: true, reason: reason.index);
  }

  _anchorRtcChannelError(String? channel, int code) {
    NELiveKit.instance._resetLive(shouldNotify: true, reason: code);
  }

  _audienceChatroomMessagesReceived(List<NERoomChatMessage> messages) {
    _chatroomMessagesReceived(messages, false);
  }

  _anchorChatroomMessagesReceived(List<NERoomChatMessage> messages) {
    _chatroomMessagesReceived(messages, true);
  }

  _rtcAudioOutputDeviceChanged(NEAudioOutputDevice device) {
    NELiveKit.instance.audioOutputDevice = device;
  }

  _anchorMemberLeaveRtcChannel(List<NERoomMember> members) {
    NELiveKit.instance._notifyMembersLeaveRtc(members);
  }

  _anchorMemberJoinRtcChannel(List<NERoomMember> members) {
    for (var m in members) {
      if (m.role.name == "host") {
        if (m.uuid == NELiveKit.instance.userUuid) {
          // self joined
          NELiveKit.instance._startLivePush();
          break;
        }
      }
    }
    NELiveKit.instance._notifyMembersJoinRtc(members);
    commonLogger.i('DEBUG: anchorMemberJoinRtcChannel');
  }

  _chatroomMessagesReceived(List<NERoomChatMessage> messages, bool isAnchor) {
    var textMessages = List<NERoomChatTextMessage>.empty(growable: true);
    for (var message in messages) {
      commonLogger.i('_chatroomMessagesReceived message=$message');
      switch (message.messageType) {
        case NERoomChatMessageType.kCustom:
          {
            var customMessage = message as NERoomChatCustomMessage;
            var attach = customMessage.attachStr;
            _dealMessage(attach, isAnchor);
          }
          break;
        case NERoomChatMessageType.kText:
          {
            var textMessage = message as NERoomChatTextMessage;
            textMessages.add(textMessage);
          }
          break;
        case NERoomChatMessageType.kNotification:
          {
            var notfiMessage = message as NERoomChatNotificationMessage;
            _dealNotificationMessage(notfiMessage);
          }
          break;
        default:
          break;
      }
    }
    if (textMessages.isNotEmpty) {
      NELiveKit.instance._notifyMessagesReceived(textMessages);
    }
  }

  _dealMessage(String content, bool isAnchor) {
    var map = json.decode(content);
    if (map is Map) {
      var data = map['data'] as Map?;
      var type = map['type'] as int?;
      if (type == 1005 && data != null) {
        /// reward
        var obj = _NELiveBatchRewardMessage._fromMap(data);
        NELiveKit.instance._notifyRewardReceived(obj);
      }
    }
  }

  _dealNotificationMessage(NERoomChatNotificationMessage message) {
    if (message.members != null) {
      if (message.eventType == NERoomChatEventType.kEnter) {
        NELiveKit.instance._notifyMembersJoinChatroom(message.members!);
      } else if (message.eventType == NERoomChatEventType.kExit) {
        NELiveKit.instance._notifyMembersLeaveChatroom(message.members!);
      }
    }
  }

  _audienceRoleChanged(
      NERoomMember member, NERoomRole oldRole, NERoomRole newRole) {
    NELiveKit.instance._notifyRoleChanged(member, oldRole, newRole);
  }
}
