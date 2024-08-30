// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_livekit;

/// SDK current mode
enum _NELiveMode {
  /// anchor mode
  anchor,

  /// audience mode
  audience,
}

/// audience live state
enum _NEAudienceLiveState {
  idle,
  joining,
  living,
  leaving,
}

class _NEAnchorLiveInfo {
  _NECreateLiveResponse? liveDetail;
  NERoomContext? liveRoom;
}

class _NEAudienceLiveInfo {
  _NEAudienceLiveState liveState = _NEAudienceLiveState.idle;
  NELiveDetail? liveDetail;
  NERoomContext? liveRoom;
  String? joiningRoomUuid;
}

class _NELiveKitImpl extends NELiveKit with _AloggerMixin {
  @override
  NELiveDetail? get liveDetail {
    if (_mode == _NELiveMode.audience) {
      return _audienceLiveInfo.liveDetail;
    } else if (_mode == _NELiveMode.anchor) {
      return NELiveDetail._fromCreateLiveResponse(_anchorLiveInfo.liveDetail);
    } else {
      return null;
    }
  }

  @override
  Future<bool> get isLoggedIn => NERoomKit.instance.authService.isLoggedIn;

  String? _userUuid;

  @override
  String? get userUuid => _userUuid;

  @override
  final mediaController = _NELiveMediaControllerImpl();

  _NELiveMode _mode = _NELiveMode.audience;

  final _anchorLiveInfo = _NEAnchorLiveInfo();

  final _audienceLiveInfo = _NEAudienceLiveInfo();

  final _roomEvent = _NELiveRoomEvent();

  final _pushService = _NELivePushService();

  bool _isFrontCamera = true;

  NERoomContext? roomContext;

  @override
  Future<VoidResult> initialize(NELiveKitOptions options) async {
    apiLogger.i('initialize appKey:${options.appKey}');
    var roomOptions = NERoomKitOptions(
        appKey: options.appKey,
        useAssetServerConfig: options.useAssetServerConfig,
        extras: options.extras);
    if (TextUtils.isNotEmpty(options.liveUrl)) {
      ServersConfig().serverUrl = options.liveUrl;
    }
    ServersConfig().appkey = options.appKey;
    ServersConfig().deviceId = const Uuid().v1();
    NERoomKit.instance.authService.onAuthEvent.listen((event) {
      if (event == NEAuthEvent.kKickOut) {
        commonLogger.i('onAuthStatusChanged KickOut');
        for (var callback in _eventCallbacks) {
          callback.loginKickOut?.call();
          stopLive();
        }
      }
    });
    NERoomKit.instance.messageChannelService
        .addMessageChannelCallback(NEMessageChannelCallback(
      onCustomMessageReceiveCallback: _onReceivePassThroughMessage,
    ));
    Future<VoidResult> initResult = NERoomKit.instance.initialize(roomOptions);
    initResult.then((value) {
      if (value.isSuccess()) {
        _initPreviewCallback();
      }
    });
    return initResult;
  }

  void _initPreviewCallback() async {
    var ret = await NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions());
    ret.nonNullData.addEventCallback(NEPreviewRoomEventCallback(
      rtcLastmileQuality: (status) {
        for (var callback in _eventCallbacks) {
          callback.rtcLastmileQuality?.call(status);
        }
      },
      rtcLastmileProbeResult: (result) {
        for (var callback in _eventCallbacks) {
          callback.rtcLastmileProbeResult?.call(result);
        }
      },
    ));
  }

  @override
  Future<VoidResult> login(String userUuid, String token) {
    apiLogger.i('login userUuid:$userUuid token:$token');
    _userUuid = userUuid;
    ServersConfig().token = token;
    ServersConfig().userUuid = userUuid;
    return NERoomKit.instance.authService.login(userUuid, token);
  }

  @override
  Future<VoidResult> logout() {
    apiLogger.i('logout');
    _userUuid = null;
    return NERoomKit.instance.authService.logout();
  }

  @override
  Future<NEResult<NELiveDetail?>> startLive(NEStartLiveParams startLiveParams) async {
    apiLogger.i('startLive liveTopic:${startLiveParams.liveTopic} liveType:${startLiveParams.liveType}');
    _isFrontCamera = startLiveParams.isFrontCamera;
    var ret = await _NELiveHttpRepository.startLive(
        startLiveParams.configId, startLiveParams.liveType, startLiveParams.liveTopic, startLiveParams.cover);
    if (!ret.isSuccess() ||
        ret.data == null ||
        TextUtils.isEmpty(ret.data?.live?.roomUuid)) {
      /// start live failed
      commonLogger.e('startLive failed code:${ret.code} msg:${ret.msg}');
      return NEResult(code: ret.code, msg: ret.msg);
    }
    int? liveRecordId = ret.data?.live?.liveRecordId;
    if (liveRecordId == null) {
      commonLogger.e('startLive joinRoom failed liveRecordId is null');
      if (liveRecordId != null) {
        _NELiveHttpRepository.stopLive(liveRecordId);
      }
      _resetStartLiveInfo();
      return NEResult(
          code: -1, msg: 'startLive joinRoom failed liveRecordId is null');
    }
    _anchorLiveInfo.liveDetail = ret.data;
    var joinParams = NEJoinRoomParams(
        roomUuid: ret.data!.live!.roomUuid!,
        userName: nickname ?? userUuid!,
        role: 'host');
    var joinOptions = NEJoinRoomOptions(enableMyAudioDeviceOnJoinRtc: true);
    var joinRet =
        await NERoomKit.instance.roomService.joinRoom(joinParams, joinOptions);
    if (joinRet.code != 0 || joinRet.data == null) {
      /// join room failed
      commonLogger.e(
          'startLive joinRoom failed code:${joinRet.code} msg:${joinRet.msg}');
      _NELiveHttpRepository.stopLive(liveRecordId);
      _resetStartLiveInfo();
      return NEResult(code: joinRet.code, msg: joinRet.msg);
    }

    var context = joinRet.data!;
    var joinedRet = await _NELiveHttpRepository.joinedLive(liveRecordId);
    if (!joinedRet.isSuccess()) {
      /// joined live failed
      commonLogger
          .e('joinedLive failed code:${joinedRet.code} msg:${joinedRet.msg}');
      var _ = await context.leaveRoom();
      _NELiveHttpRepository.stopLive(liveRecordId);
      _resetStartLiveInfo();
      return NEResult(code: joinRet.code, msg: joinRet.msg);
    }

    roomContext = context;
    _roomEvent.isFrontCamera = startLiveParams.isFrontCamera;
    context.addEventCallback(_roomEvent.anchorRoomEvent);

    _mode = _NELiveMode.anchor;
    _anchorLiveInfo.liveRoom = context;

    var completer = Completer<NEResult<NELiveDetail?>>();
    var chatTask = context.chatController.joinChatroom();
    var liveInfoTask = context.liveController.getLiveInfo();
    var rtcTask = context.rtcController.joinRtcChannel();
    var seatTask = context.seatController.submitSeatRequest(1, true);

    Future.wait([chatTask, liveInfoTask, rtcTask, seatTask])
        .then((results) async {
      var chatRet = results[0];
      var liveInfo = results[1] as NEResult<NERoomLiveInfo?>;
      var rtcRet = results[2];
      var seatRet = results[3];

      if (chatRet.code != 0) {
        /// join chatroom failed, should leave room
        commonLogger.e(
            'startLive joinChatroom failed code:${chatRet.code} msg:${chatRet.msg}');
        var _ = await context.leaveRoom();
        _NELiveHttpRepository.stopLive(liveRecordId);
        _resetStartLiveInfo();
        completer.complete(NEResult(code: chatRet.code, msg: chatRet.msg));
      } else if (TextUtils.isEmpty(liveInfo.data?.pushUrl)) {
        /// push url not exist, should leave room
        commonLogger.e('startLive pushUrl is empty, 请联系云信商务开通直播功能');
        var _ = await context.leaveRoom();
        _NELiveHttpRepository.stopLive(liveRecordId);
        _resetStartLiveInfo();
        completer.complete(
            const NEResult(code: -1, msg: 'pushUrl is empty，请联系云信商务开通直播功能'));
      } else if (rtcRet.code != 0) {
        /// join rtc channel failed, should leave room
        commonLogger.e('startLive joinRtcChannel failed code:${rtcRet.code}');
        var _ = await context.leaveRoom();
        _NELiveHttpRepository.stopLive(liveRecordId);
        _resetStartLiveInfo();
        completer.complete(
            NEResult(code: rtcRet.code, msg: 'join Rtc channel failed'));
      } else if (seatRet.code != 0) {
        /// submit seat request failed, should leave room
        commonLogger
            .e('startLive submitSeatRequest failed code:${seatRet.code}');
        var _ = await context.leaveRoom();
        _NELiveHttpRepository.stopLive(liveRecordId);
        _resetStartLiveInfo();
        completer.complete(
            NEResult(code: seatRet.code, msg: 'submit seat request failed'));
      } else {
        completer.complete(NEResult(
            code: 0, data: NELiveDetail._fromCreateLiveResponse(ret.data)));
      }
    }).catchError((error) async {
      commonLogger.e('startLive failed with error: $error');
      var _ = await context.leaveRoom();
      completer.complete(
          NEResult(code: -1, msg: 'startLive failed with error: $error'));
    });

    return completer.future;
  }

  _resetStartLiveInfo() {
    _mode = _NELiveMode.audience;
    _anchorLiveInfo.liveDetail = null;
    _anchorLiveInfo.liveRoom = null;
  }

  _startLivePush() async {
    commonLogger.i('startLivePush');
    var context = _anchorLiveInfo.liveRoom;
    var liveInfo = await context?.liveController.getLiveInfo();
    var pushUrl = liveInfo?.data?.pushUrl;
    commonLogger.i(
        'startLivePush pushUrl:$pushUrl pullUrl:${liveInfo?.data?.rtmpPullUrl}');
    if (context != null && TextUtils.isNotEmpty(pushUrl)) {
      context.rtcController.unmuteMyAudio();
      await context.rtcController.unmuteMyVideo();
      if (!_isFrontCamera) {
        context.rtcController
            .switchCameraWithPosition(NERoomCameraPosition.kBack);
      }
      var taskRet = await _pushService.startLivePush(context, pushUrl!);
      if (taskRet.code != 0) {
        commonLogger.e('startLivePush failed, code:${taskRet.code}');
        _resetLive(shouldNotify: true, reason: taskRet.code);
      } else {
        for (var callback in _eventCallbacks) {
          callback.pushStart?.call();
        }
      }
    } else {
      commonLogger.e('startLivePush failed, params error');
      _resetLive(shouldNotify: true);
    }
  }

  @override
  Future<VoidResult> updateLive(List<String> uuids) async {
    apiLogger.i('updateLive uuids:$uuids');
    return _pushService.updatePush(_anchorLiveInfo.liveRoom!, uuids);
  }

  @override
  Future<VoidResult> stopLive() async {
    apiLogger.i('stopLive');
    if (_mode != _NELiveMode.anchor) {
      commonLogger.e('stopLive mode is not anchor');
      return const NEResult(code: -1, msg: 'not supported now');
    }
    if (_anchorLiveInfo.liveDetail?.live?.roomUuid != null) {
      await NERoomKit.instance.roomService
          .cancelJoinRoom(_anchorLiveInfo.liveDetail!.live!.roomUuid!);
    }
    var liveRecordId = _anchorLiveInfo.liveDetail?.live?.liveRecordId;
    if (liveRecordId == null || liveRecordId == 0) {
      commonLogger.e('stopLive liveRecordId not exist');
      return const NEResult(code: -1, msg: 'liveRecordId not exist');
    }
    var _ = await _resetLive();
    var ret = await _NELiveHttpRepository.stopLive(liveRecordId);
    return NEResult(code: ret.code, msg: ret.msg);
  }

  @override
  Future<NEResult<NELiveDetail>> fetchLiveInfo(int liveRecordId) async {
    apiLogger.i('fetchLiveInfo liveRecordId:$liveRecordId');
    var ret = await _NELiveHttpRepository.fetchLiveInfo(liveRecordId);
    return NEResult(
        code: ret.code,
        msg: ret.msg,
        data: NELiveDetail._fromLiveInfoResponse(ret.data));
  }

  @override
  Future<NEResult<NELiveList?>> fetchLiveList(int pageNum, int pageSize,
      NELiveStatus liveStatus, NELiveRoomType liveType) async {
    apiLogger.i(
        'fetchLiveList pageNum:$pageNum pageSize:$pageSize liveStatus:$liveStatus liveType:$liveType');
    var ret = await _NELiveHttpRepository.fetchLiveList(
        pageNum, pageSize, liveStatus, liveType);
    return NEResult(
        code: ret.code,
        msg: ret.msg,
        data: NELiveList._fromLiveListResponse(ret.data));
  }

  @override
  Future<VoidResult> sendTextMessage(String message) async {
    apiLogger.i('sendTextMessage message:$message');
    if (_mode == _NELiveMode.anchor && _anchorLiveInfo.liveRoom != null) {
      return _anchorLiveInfo.liveRoom!.chatController
          .sendBroadcastTextMessage(message);
    } else if (_mode == _NELiveMode.audience &&
        _audienceLiveInfo.liveRoom != null) {
      return _audienceLiveInfo.liveRoom!.chatController
          .sendBroadcastTextMessage(message);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'other error'));
    }
  }

  @override
  Future<NEResult<List<NEChatroomMember>>> fetchChatroomMembers(
      NEChatroomMemberQueryType queryType,
      int limit,
      String? lastMemberAccount) {
    apiLogger.i('fetchChatRoomMembers queryType:$queryType, limit:$limit');
    if (_mode == _NELiveMode.anchor && _anchorLiveInfo.liveRoom != null) {
      return _anchorLiveInfo.liveRoom!.chatController
          .fetchChatroomMembers(queryType, limit, lastMemberAccount);
    } else if (_mode == _NELiveMode.audience &&
        _audienceLiveInfo.liveRoom != null) {
      return _audienceLiveInfo.liveRoom!.chatController
          .fetchChatroomMembers(queryType, limit, lastMemberAccount);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'other error'));
    }
  }

  @override
  Future<VoidResult> reward(int giftId) async {
    apiLogger.i('reward giftId:$giftId');
    if (_mode != _NELiveMode.audience) {
      commonLogger.e('reward mode is not audience');
      return Future.value(const NEResult(code: -1, msg: 'not supported now'));
    }
    var liveRecordId = _audienceLiveInfo.liveDetail?.live?.liveRecordId;
    if (liveRecordId == null || liveRecordId == 0) {
      commonLogger.e('reward liveRecordId not exist');
      return Future.value(
          const NEResult(code: -1, msg: 'liveRecordId not exist'));
    }
    var anchorUuid = _audienceLiveInfo.liveDetail?.live?.userUuid;
    if (anchorUuid == null || anchorUuid.isEmpty) {
      commonLogger.e('reward anchorUuid not exist');
      return Future.value(
          const NEResult(code: -1, msg: 'anchorUuid not exist'));
    }
    return _NELiveHttpRepository.reward(liveRecordId, giftId, 1, [anchorUuid]);
  }

  @override
  Future<NEResult<NELiveDefaultInfo?>> getDefaultLiveInfo() async {
    apiLogger.i('getDefaultLiveInfo');
    var ret = await _NELiveHttpRepository.getDefaultLiveInfo();
    return NEResult(
        code: ret.code,
        msg: ret.msg,
        data: NELiveDefaultInfo._fromLiveDefaultInfoResponse(ret.data));
  }

  @override
  Future<NEResult<String?>> joinLive(NELiveDetail liveDetail) async {
    apiLogger.i('joinLive liveRecordId:${liveDetail.live?.liveRecordId}');
    if (TextUtils.isEmpty(liveDetail.live?.roomUuid)) {
      commonLogger.e('joinLive roomUuid not exist');
      return Future.value(const NEResult(code: -1, msg: 'roomUuid not exist'));
    }
    var liveRecordId = liveDetail.live?.liveRecordId;
    if (liveRecordId == null || liveRecordId == 0) {
      commonLogger.e('joinLive liveRecordId not exist');
      return Future.value(
          const NEResult(code: -1, msg: 'liveRecordId not exist'));
    }

    _audienceLiveInfo.liveState = _NEAudienceLiveState.joining;
    _audienceLiveInfo.joiningRoomUuid = liveDetail.live?.roomUuid;
    var joinParams = NEJoinRoomParams(
        roomUuid: liveDetail.live!.roomUuid!,
        userName: nickname ?? userUuid!,
        role: NERoomBuiltinRole.OBSERVER);
    var options = NEJoinRoomOptions();
    var ret =
        await NERoomKit.instance.roomService.joinRoom(joinParams, options);
    _audienceLiveInfo.joiningRoomUuid = null;
    if (ret.code != 0 || ret.data == null) {
      commonLogger
          .e('joinLive joinRoom failed code:${ret.code} msg:${ret.msg}');
      return NEResult(code: ret.code, msg: ret.msg);
    }

    /// join room succeed, should join chatroom
    var context = ret.data!;
    roomContext = context;
    commonLogger.i('joinLive joinRoom complete');
    var checkRet = await _checkLiveState(context);
    if (checkRet.code != 0) {
      return NEResult(code: checkRet.code, msg: checkRet.msg);
    }

    var chatRet = await context.chatController.joinChatroom();
    if (chatRet.code != 0) {
      /// join chatroom failed
      commonLogger.e(
          'joinLive joinChatroom failed code:${chatRet.code} msg:${chatRet.msg}');
      var _ = await context.leaveRoom();
      return NEResult(code: chatRet.code, msg: chatRet.msg);
    }

    commonLogger.i('joinLive joinChatroom complete');
    checkRet = await _checkLiveState(context);
    if (checkRet.code != 0) {
      return NEResult(code: checkRet.code, msg: checkRet.msg);
    }

    var liveInfo = await context.liveController.getLiveInfo();
    if (TextUtils.isEmpty(liveInfo.data?.rtmpPullUrl)) {
      /// pull url not exist, should leave room
      commonLogger.e('joinLive rtmpPullUrl is empty');
      var _ = await context.leaveRoom();
      return const NEResult(code: -1, msg: 'rtmpPullUrl not exist');
    }

    commonLogger.i('joinLive getLiveInfo complete');
    checkRet = await _checkLiveState(context);
    if (checkRet.code != 0) {
      return NEResult(code: checkRet.code, msg: checkRet.msg);
    }

    _audienceLiveInfo.liveState = _NEAudienceLiveState.living;
    _audienceLiveInfo.liveDetail = liveDetail;
    _audienceLiveInfo.liveRoom = context;
    context.addEventCallback(_roomEvent.audienceRoomEvent);
    _mode = _NELiveMode.audience;
    return NEResult(
        code: ret.code, msg: ret.msg, data: liveInfo.data?.rtmpPullUrl);
  }

  Future<VoidResult> _checkLiveState(NERoomContext context) async {
    /// when join room complete, already called leaveLive yet
    if (_audienceLiveInfo.liveState == _NEAudienceLiveState.idle ||
        _audienceLiveInfo.liveState == _NEAudienceLiveState.leaving) {
      commonLogger
          .e('joinLive when join room complete, already called leaveLive yet');
      var _ = await context.leaveRoom();
      _audienceLiveInfo.liveState = _NEAudienceLiveState.idle;
      return const NEResult(code: -1, msg: 'left live');
    }
    return const NEResult(code: 0);
  }

  @override
  Future<VoidResult> leaveLive() async {
    apiLogger.i('leaveLive');
    if (_mode != _NELiveMode.audience) {
      commonLogger.e('leaveLive mode is not audience');
      return Future.value(const NEResult(code: -1, msg: 'not supported now'));
    }
    if (_audienceLiveInfo.joiningRoomUuid != null) {
      await NERoomKit.instance.roomService
          .cancelJoinRoom(_audienceLiveInfo.joiningRoomUuid!);
    }
    var room = _audienceLiveInfo.liveRoom;
    if (room == null) {
      commonLogger.e('leaveLive not in live');
      if (_audienceLiveInfo.liveState == _NEAudienceLiveState.joining) {
        commonLogger.e('leaveLive when joining');
        _audienceLiveInfo.liveState = _NEAudienceLiveState.leaving;
      }
      return Future.value(const NEResult(code: -1, msg: 'not in live'));
    }
    var ret = await _resetLive();
    commonLogger.e('leaveLive complete');
    return NEResult(code: ret.code, msg: ret.msg);
  }

  @override
  Future<VoidResult> uploadLog() {
    apiLogger.i('uploadLog');
    return NERoomKit.instance.uploadLog();
  }

  final _eventCallbacks = <NELiveCallback>{};

  @override
  void addEventCallback(NELiveCallback callback) {
    apiLogger.i('addEventCallback');
    _eventCallbacks.add(callback);
  }

  @override
  void removeEventCallback(NELiveCallback callback) {
    apiLogger.i('removeEventCallback');
    _eventCallbacks.remove(callback);
  }

  /// do operations when live ended
  Future<VoidResult> _resetLive(
      {bool shouldNotify = false, int reason = 1}) async {
    commonLogger.i('resetLive');
    if (_mode == _NELiveMode.audience) {
      if (_audienceLiveInfo.liveRoom != null) {
        _audienceLiveInfo.liveRoom
            ?.removeEventCallback(_roomEvent.audienceRoomEvent);
        _audienceLiveInfo.liveState = _NEAudienceLiveState.leaving;
        await _audienceLiveInfo.liveRoom?.chatController.leaveChatroom();
        _audienceLiveInfo.liveRoom?.leaveRoom();
      } else if (TextUtils.isNotEmpty(
          _audienceLiveInfo.liveDetail?.live?.roomUuid)) {
        await NERoomKit.instance.roomService
            .cancelJoinRoom(_audienceLiveInfo.liveDetail!.live!.roomUuid!);
      }
      _audienceLiveInfo.liveState = _NEAudienceLiveState.idle;
      _audienceLiveInfo.liveRoom = null;
      _audienceLiveInfo.liveDetail = null;
    } else if (_mode == _NELiveMode.anchor) {
      var context = _anchorLiveInfo.liveRoom;
      if (context != null) {
        context.removeEventCallback(_roomEvent.anchorRoomEvent);
        mediaController.stopAllEffects();
        mediaController.stopAudioMixing();
        await _pushService.stopLivePush(context);
        _anchorLiveInfo.liveRoom?.endRoom(true);
        // await context.leaveRoom();
        _anchorLiveInfo.liveDetail = null;
        _anchorLiveInfo.liveRoom = null;
      } else if (TextUtils.isNotEmpty(
          _anchorLiveInfo.liveDetail?.live?.roomUuid)) {
        await NERoomKit.instance.roomService
            .cancelJoinRoom(_anchorLiveInfo.liveDetail!.live!.roomUuid!);
      }
    }
    roomContext = null;
    if (shouldNotify) {
      for (var callback in _eventCallbacks) {
        callback.liveEnded?.call(reason);
      }
    }
    return Future.value(const NEResult(code: 0));
  }

  _onReceivePassThroughMessage(NECustomMessage message) {
    commonLogger.i('onReceivePassThroughMessage data:${message.data}');
  }

  _notifyMessagesReceived(List<NERoomChatTextMessage> messages) {
    for (var callback in _eventCallbacks) {
      callback.messagesReceived?.call(messages);
    }
  }

  _notifyRewardReceived(_NELiveBatchRewardMessage message) {
    commonLogger.i('notifyRewardReceived');
    for (var callback in _eventCallbacks) {
      callback.rewardReceived
          ?.call(NELiveBatchRewardMessage._fromMessage(message));
    }
  }

  _notifyMembersJoinRoom(List<NERoomMember> members) {
    commonLogger.i('notifyMembersJoinRoom');
    for (var callback in _eventCallbacks) {
      callback.membersJoin?.call(members);
    }
  }

  _notifyMembersLeaveRoom(List<NERoomMember> members) {
    commonLogger.i('notifyMembersLeaveRoom');
    for (var callback in _eventCallbacks) {
      callback.membersLeave?.call(members);
    }
  }

  _notifyMembersJoinChatroom(List<NERoomMember> members) {
    commonLogger.i('notifyMembersJoinChatroom');
    for (var callback in _eventCallbacks) {
      callback.membersJoinChatroom?.call(members);
    }
  }

  _notifyMembersLeaveChatroom(List<NERoomMember> members) {
    commonLogger.i('notifyMembersLeaveChatroom');
    for (var callback in _eventCallbacks) {
      callback.membersLeaveChatroom?.call(members);
    }
  }

  _notifyMemberVideoMuteChanged(
      NERoomMember member, bool mute, NERoomMember? operateBy) {
    commonLogger.i('notifyMemberVideoMuteChanged ${member.uuid} $mute');
    for (var callback in _eventCallbacks) {
      callback.memberVideoMuteChanged?.call(member, mute, operateBy);
    }
  }

  _notifyMembersJoinRtc(List<NERoomMember> members) {
    commonLogger.i('notifyMembersJoinRtc');
    for (var callback in _eventCallbacks) {
      callback.membersJoinRtc?.call(members);
    }
  }

  _notifyMembersLeaveRtc(List<NERoomMember> members) {
    commonLogger.i('notifyMembersLeave');
    for (var callback in _eventCallbacks) {
      callback.memberLeaveRtc?.call(members);
    }
  }

  _notifyRoleChanged(
      NERoomMember member, NERoomRole oldRole, NERoomRole newRole) {
    commonLogger.i('memberRoleChanged ${member.uuid} $oldRole $newRole');
    //如果是自己的角色有变化
    if (_isSelf(member.uuid)) {
      // 如果普通观众切换成麦上观众，加入RTC
      if (newRole.name == NELiveRole.audienceOnSeat) {
        roomContext?.rtcController.joinRtcChannel().then((result) {
          if (result.isSuccess()) {
            commonLogger.i('join RTC success');
          } else {
            commonLogger
                .i('join RTC error code ${result.code},msg:${result.msg}');
          }
        });
      } else if (newRole.name == NELiveRole.audience) {}
    }
  }

  bool _isSelf(String uuid) {
    return uuid == NELiveKit.instance.userUuid;
  }

  bool _isAnchor(String uuid) {
    return uuid == NELiveKit.instance.liveDetail?.anchor?.userUuid;
  }

  @override
  NERoomMember? get localMember => roomContext?.localMember;
}

class NEStartLiveParams {
  final String liveTopic;
  final NELiveRoomType liveType;
  final int configId;
  final String cover;
  final bool isFrontCamera;

  NEStartLiveParams({
    required this.liveTopic,
    required this.liveType,
    required this.configId,
    required this.cover,
    required this.isFrontCamera,
  });

  @override
  String toString() {
    return 'NEStartLiveParams{liveTopic: $liveTopic, liveType: $liveType, configId: $configId, cover: $cover, isFrontCamera: $isFrontCamera}';
  }
}
