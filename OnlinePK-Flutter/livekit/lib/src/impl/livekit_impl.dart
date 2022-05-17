// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

/// SDK current mode
enum _NELiveMode {
  /// anchor mode
  anchor,

  /// audience mode
  audience,
}


/// PK action
enum _NELivePKAction {
  /// invalid
  invalid,

  /// invite
  invite,

  /// accept
  accept,

  /// reject
  reject,

  /// cancel
  cancel,

  /// timeout
  timeout,
}

class _NEAnchorLiveInfo {
  _NECreateLiveResponse? liveDetail;
  _NEPKStartAnchor? peer;
  NERoomContext? liveRoom;
  NERoomContext? peerRoom;
}

class _NEAudienceLiveInfo {
  NELiveDetail? liveDetail;
  NERoomContext? liveRoom;
}

class _NELiveKitImpl extends NELiveKit with _AloggerMixin {
  @override
  bool get isPKing => (_pkStatus == NELivePKStatus.pking ||
      _pkStatus == NELivePKStatus.punishing);

  NELivePKStatus _pkStatus = NELivePKStatus.idle;

  @override
  NELivePKStatus get pkStatus => _pkStatus;

  String? _pkId;

  @override
  String? get pkId => _pkId;

  bool _isInviter = false;

  @override
  bool get isInviter => _isInviter;

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
  List<NERoomMember>? get members {
    List<NERoomMember>? _members;
    commonLogger.i('members->_mode:$_mode');
    if (_mode == _NELiveMode.audience) {
      var remoteMembers=_audienceLiveInfo.liveRoom?.remoteMembers;
      if(remoteMembers!=null){
        remoteMembers.forEach((element) {
          commonLogger.i("members->uuid:${element.uuid},name:${element.name},isInChatroom:${element.isInChatroom}");
        });
        _members = remoteMembers
            .where((element) => element.isInChatroom)
            .toList();
        commonLogger.i('members->_audienceLiveInfo.liveRoom?.remoteMembers.length:${_audienceLiveInfo.liveRoom?.remoteMembers.length}');
      }
      var localMember = _audienceLiveInfo.liveRoom?.localMember;
      if (localMember != null) {
        _members?.add(localMember);
      }
      commonLogger.i('members->localMember:$localMember');
    } else if (_mode == _NELiveMode.anchor) {
      var remoteMembers=_anchorLiveInfo.liveRoom?.remoteMembers;
      if(remoteMembers!=null){
        remoteMembers.forEach((element) {
          commonLogger.i("members->uuid:${element.uuid},name:${element.name},isInChatroom:${element.isInChatroom}");
        });
        _members = remoteMembers
            .where((element) => element.isInChatroom)
            .toList();
        commonLogger.i('members->_anchorLiveInfo.liveRoom?.remoteMembers.length:${_anchorLiveInfo.liveRoom?.remoteMembers.length}');
      }
      var localMember = _anchorLiveInfo.liveRoom?.localMember;
      if (localMember != null) {
        _members?.add(localMember);
      }
      commonLogger.i('members->localMember:$localMember');
    }
    if(_members!=null){
      commonLogger.i('members->_members.length:${_members.length}');
      _members.forEach((element) {
        commonLogger.i("members->uuid:${element.uuid},name:${element.name}");
      });
    }
    return _members;
  }

  @override
  Future<bool> get isLoggedIn => NERoomKit.instance.authService.isLoggedIn;

  String? _userUuid;

  @override
  String? get userUuid => _userUuid;

  @override
  final mediaController = _NELiveMediaControllerImpl();

  bool _isDebug = true;

  _NELiveMode _mode = _NELiveMode.audience;

  final _anchorLiveInfo = _NEAnchorLiveInfo();

  final _audienceLiveInfo = _NEAudienceLiveInfo();

  final _roomEvent = _NELiveRoomEvent();

  final _pushService = _NELivePushService();

  @override
  Future<VoidResult> initialize(NELiveKitOptions options) {
    commonLogger.i('initialize appKey:${options.appKey}');
    var roomOptions =
        NERoomKitOptions(appKey: options.appKey, extras: options.extras);
    if (options.extras != null && options.extras!.isNotEmpty) {
      String? serverUrl = options.extras!['serverUrl'];
      if (serverUrl == 'test') {
        _isDebug = true;
      } else {
        _isDebug = false;
      }
      if(!TextUtils.isEmpty(serverUrl)) {
        ServersConfig().serverUrl = serverUrl!;
      }
    }
    ServersConfig().deviceId = const Uuid().v1();
    _NELiveHttpRepository.appKey = options.appKey;
    NERoomKit.instance.authService.onAuthStatusChanged.listen((event) {
      if (event == NEAuthEvent.kKickOut) {
        commonLogger.i('onAuthStatusChanged KickOut');
        for (var callback in _eventCallbacks) {
          callback.loginKickOut?.call();
          stopLive();
        }
      }
    });
    NERoomKit.instance.messageService.addMessageCallback(NEMessageCallback(
      onReceivePassThroughMessage: _onReceivePassThroughMessage,
    ));
    return NERoomKit.instance.initialize(roomOptions);
  }

  @override
  Future<VoidResult> login(String userUuid, String token) {
    commonLogger.i('login userUuid:$userUuid token:$token');
    _userUuid = userUuid;
    ServersConfig().token = token;
    ServersConfig().userUuid = userUuid;
    return NERoomKit.instance.authService.login(userUuid, token);
  }

  @override
  Future<VoidResult> logout() {
    commonLogger.i('logout');
    _userUuid = null;
    return NERoomKit.instance.authService.logout();
  }

  @override
  Future<NEResult<NELiveDetail?>> startLive(String liveTopic,
      NELiveRoomType liveType, String cover) async {
    commonLogger.i('startLive liveTopic:$liveTopic liveType:$liveType');
    var ret = await _NELiveHttpRepository.startLive(
        71, liveType, liveTopic, cover);
    if (ret.code != 0 ||
        ret.data == null ||
        TextUtils.isEmpty(ret.data?.live?.roomUuid)) {
      /// start live failed
      commonLogger.e('startLive failed code:${ret.code} msg:${ret.msg}');
      return NEResult(code: ret.code, msg: ret.msg);
    }
    var joinParams = NEJoinRoomParams(
        roomUuid: ret.data!.live!.roomUuid!, userName: nickname ?? userUuid!, role: 'host');
    var joinOptions = NEJoinRoomOptions();
    var joinRet =
        await NERoomKit.instance.roomService.joinRoom(joinParams, joinOptions);
    if (joinRet.code != 0 || joinRet.data == null) {
      /// join room failed
      commonLogger.e(
          'startLive joinRoom failed code:${joinRet.code} msg:${joinRet.msg}');
      return NEResult(code: joinRet.code, msg: joinRet.msg);
    }
    var context = joinRet.data!;
    context.addEventCallback(_roomEvent.anchorRoomEvent);
    var chatRet = await context.chatController.joinChatroom();
    if (chatRet.code != 0) {
      /// join chatroom failed, should leave room
      commonLogger.e(
          'startLive joinChatroom failed code:${chatRet.code} msg:${chatRet.msg}');
      var _ = await context.leaveRoom();
      return NEResult(code: chatRet.code, msg: chatRet.msg);
    } else {
      var liveInfo = await context.liveController.getLiveInfo();
      if (TextUtils.isEmpty(liveInfo.data?.pushUrl)) {
        /// push url not exist, should leave room
        commonLogger.e('startLive pushUrl is empty');
        var _ = await context.leaveRoom();
        return const NEResult(code: -1, msg: 'pushUrl not exist');
      } else {
        var rtcRet = await context.rtcController.joinRtcChannel();
        if (rtcRet.code != 0) {
          /// join rtc channel failed, should leave room
          commonLogger.e('startLive joinRtcChannel failed code:${rtcRet.code}');
          var _ = await context.leaveRoom();
          return NEResult(code: rtcRet.code, msg: 'join Rtc channel failed');
        } else {
          _mode = _NELiveMode.anchor;
          _anchorLiveInfo.liveDetail = ret.data;
          _anchorLiveInfo.liveRoom = context;
          return NEResult(
              code: 0, data: NELiveDetail._fromCreateLiveResponse(ret.data));
        }
      }
    }
  }

  _startLivePush() async {
    commonLogger.i('startLivePush');
    var context = _anchorLiveInfo.liveRoom;
    var liveInfo = await context?.liveController.getLiveInfo();
    var pushUrl = liveInfo?.data?.pushUrl;
    if (context != null && TextUtils.isNotEmpty(pushUrl)) {
      context.rtcController.unmuteMyAudio();
      await context.rtcController.unmuteMyVideo();
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
  Future<VoidResult> stopLive() async {
    commonLogger.i('stopLive');
    if (_mode != _NELiveMode.anchor) {
      commonLogger.e('stopLive mode is not anchor');
      return const NEResult(code: -1, msg: 'not supported now');
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
    commonLogger.i('fetchLiveInfo liveRecordId:$liveRecordId');
    var ret = await _NELiveHttpRepository.fetchLiveInfo(liveRecordId);
    return NEResult(
        code: ret.code,
        msg: ret.msg,
        data: NELiveDetail._fromLiveInfoResponse(ret.data));
  }

  @override
  Future<NEResult<NELiveList?>> fetchLiveList(int pageNum, int pageSize,
      NELiveStatus liveStatus, NELiveRoomType liveType) async {
    commonLogger.i(
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
    commonLogger.i('sendTextMessage message:$message');
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
  Future<NEResult<NELivePKDetail?>> fetchPKInfo(int liveRecordId) async {
    commonLogger.i('fetchPKInfo liveRecordId:$liveRecordId');
    var ret = await _NELiveHttpRepository.fetchPKInfo(liveRecordId);
    return Future.value(NEResult(
        code: 0, msg: ret.msg, data: NELivePKDetail._fromResponse(ret.data)));
  }

  @override
  Future<VoidResult> invitePK(String targetAccountId, NELivePKRule rule) async {
    commonLogger.i('invitePK targetAccountId:$targetAccountId');
    if (_mode != _NELiveMode.anchor) {
      commonLogger.e('invitePK mode is not anchor');
      return const NEResult(code: -1, msg: 'not supported now');
    }
    if (_pkStatus != NELivePKStatus.idle) {
      commonLogger.e('invitePK pkStatus i not idle');
      return const NEResult(
          code: -1, msg: 'can not invite PK for status reason');
    }
    _pkStatus = NELivePKStatus.inviting;
    _isInviter = true;
    var ret = await _NELiveHttpRepository.inviteControl(
        null, _NELivePKAction.invite, targetAccountId, rule);
    if (ret.code == 0) {
      _pkId = ret.data?.pkId;
    } else {
      if (_pkStatus == NELivePKStatus.inviting) {
        _pkStatus = NELivePKStatus.idle;
      }
    }
    return NEResult(code: ret.code, msg: ret.msg);
  }

  @override
  Future<VoidResult> cancelPKInvite() async {
    commonLogger.i('cancelPKInvite');
    if (_mode != _NELiveMode.anchor) {
      commonLogger.e('cancelPKInvite mode is not anchor');
      return const NEResult(code: -1, msg: 'not supported now');
    }
    if (TextUtils.isEmpty(_pkId) || _pkStatus != NELivePKStatus.inviting) {
      commonLogger
          .e('cancelPKInvite pkId is empty or pkStatus is not inviting');
      return const NEResult(
          code: -1, msg: 'can not cancel invite for status reason');
    }
    var ret = await _NELiveHttpRepository.inviteControl(
        _pkId, _NELivePKAction.cancel, null, null);
    var _ = await _resetPK();
    return NEResult(code: ret.code, msg: ret.msg);
  }

  @override
  Future<VoidResult> rejectPK() async {
    commonLogger.i('rejectPK');
    if (_mode != _NELiveMode.anchor) {
      commonLogger.e('rejectPK mode is not anchor');
      return const NEResult(code: -1, msg: 'not supported now');
    }
    if (TextUtils.isEmpty(_pkId) || _pkStatus != NELivePKStatus.invited) {
      commonLogger.e('rejectPK pkId is empty or pkStatus is not invited');
      return const NEResult(
          code: -1, msg: 'can not reject invite for status reason');
    }
    var ret = await _NELiveHttpRepository.inviteControl(
        _pkId, _NELivePKAction.reject, null, null);
    var _ = await _resetPK();
    return NEResult(code: ret.code, msg: ret.msg);
  }

  @override
  Future<VoidResult> acceptPK() async {
    commonLogger.i('acceptPK');
    if (_mode != _NELiveMode.anchor) {
      commonLogger.e('acceptPK mode is not anchor');
      return const NEResult(code: -1, msg: 'not supported now');
    }
    var ret = await _NELiveHttpRepository.inviteControl(
        pkId, _NELivePKAction.accept, null, null);
    var roomUuid = ret.data?.roomUuid;
    if (ret.code != 0 || TextUtils.isEmpty(roomUuid)) {
      commonLogger.e('acceptPK roomUuid not exist');
      return NEResult(code: ret.code, msg: ret.msg);
    }
    var params = NEJoinRoomParams(
        roomUuid: roomUuid!, userName: nickname ?? _userUuid!, role: 'invited_host');
    var joinRet = await NERoomKit.instance.roomService
        .joinRoom(params, NEJoinRoomOptions());
    var context = joinRet.data;
    if (joinRet.code != 0 || context == null) {
      commonLogger.e(
          'acceptPK joinRoom failed code:${joinRet.code} msg:${joinRet.msg}');
      return NEResult(code: joinRet.code, msg: joinRet.msg);
    }
    _anchorLiveInfo.peerRoom = context;
    _anchorLiveInfo.peerRoom?.addEventCallback(_roomEvent.peerRoomEvent);
    var rtcRet = await context.rtcController.startRtcChannelMediaRelay();
    if (rtcRet.code != 0) {
      commonLogger.e(
          'acceptPK startRtcChannelMediaRelay failed code:${rtcRet.code} msg:${rtcRet.msg}');

      /// startRtcChannelMediaRelay failed, should leave room
      var _ = await context.leaveRoom();
      _anchorLiveInfo.peerRoom?.removeEventCallback(_roomEvent.peerRoomEvent);
      _anchorLiveInfo.peerRoom = null;
      return NEResult(code: rtcRet.code, msg: rtcRet.msg);
    }
    return NEResult(code: rtcRet.code, msg: rtcRet.msg);
  }

  @override
  Future<VoidResult> stopPK() async {
    commonLogger.i('stopPK');
    if (_mode != _NELiveMode.anchor) {
      commonLogger.e('stopPK mode is not anchor');
      return const NEResult(code: -1, msg: 'not supported now');
    }
    if (TextUtils.isEmpty(_pkId) || !isPKing) {
      commonLogger.e('stopPK not in pk');
      return const NEResult(code: -1, msg: 'not in pk');
    }
    var ret = await _NELiveHttpRepository.stopPK(_pkId!);
    var _ = await _resetPK();
    return NEResult(code: ret.code, msg: ret.msg);
  }

  @override
  Future<NEResult<NELivePKRewardTop?>> fetchRewardTopList(
      int liveRecordId, String pkId) async {
    commonLogger.i('fetchRewardTopList liveRecordId:$liveRecordId pkId:$pkId');
    var ret =
        await _NELiveHttpRepository.fetchRewardTopList(liveRecordId, pkId);
    return NEResult(
        code: ret.code,
        msg: ret.msg,
        data: NELivePKRewardTop._fromPKInfoRewardTop(ret.data));
  }

  @override
  Future<NEResult<List<NEChatRoomMember>>> fetchChatRoomMembers(NEChatroomMemberQueryType queryType, int limit) {
    commonLogger.i('fetchChatRoomMembers queryType:$queryType, limit:$limit');
    if (_mode == _NELiveMode.anchor && _anchorLiveInfo.liveRoom != null) {
      return _anchorLiveInfo.liveRoom!.chatController
          .fetchChatRoomMembers(queryType, limit);
    } else if (_mode == _NELiveMode.audience &&
        _audienceLiveInfo.liveRoom != null) {
      return _audienceLiveInfo.liveRoom!.chatController
          .fetchChatRoomMembers(queryType, limit);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'other error'));
    }
  }

  @override
  Future<VoidResult> reward(int giftId) async {
    commonLogger.i('reward giftId:$giftId');
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
    return _NELiveHttpRepository.reward(
        liveRecordId, giftId, isPKing ? _pkId : null);
  }

  @override
  Future<NEResult<String?>> joinLive(NELiveDetail liveDetail) async {
    commonLogger.i('joinLive liveRecordId:${liveDetail.live?.liveRecordId}');
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
    var joinParams = NEJoinRoomParams(
        roomUuid: liveDetail.live!.roomUuid!, userName: nickname ?? userUuid!, role: 'audience');
    var options = NEJoinRoomOptions();
    var ret =
        await NERoomKit.instance.roomService.joinRoom(joinParams, options);
    if (ret.code != 0 || ret.data == null) {
      commonLogger
          .e('joinLive joinRoom failed code:${ret.code} msg:${ret.msg}');
      return NEResult(code: ret.code, msg: ret.msg);
    }

    /// join room succeed, should join chatroom
    var context = ret.data!;
    var chatRet = await context.chatController.joinChatroom();
    if (chatRet.code != 0) {
      /// join chatroom failed
      commonLogger.e(
          'joinLive joinChatroom failed code:${chatRet.code} msg:${chatRet.msg}');
      var _ = await context.leaveRoom();
      return NEResult(code: chatRet.code, msg: chatRet.msg);
    }
    var liveInfo = await context.liveController.getLiveInfo();
    if (TextUtils.isEmpty(liveInfo.data?.rtmpPullUrl)) {
      /// pull url not exist, should leave room
      commonLogger.e('joinLive rtmpPullUrl is empty');
      var _ = await context.leaveRoom();
      return const NEResult(code: -1, msg: 'rtmpPullUrl not exist');
    }

    /// fetch pk info when join live
    var pkRet = await fetchPKInfo(liveRecordId);
    if (TextUtils.isNotEmpty(pkRet.data?.pkId)) {
      _pkId = pkRet.data?.pkId;
    }
    if (pkRet.data?.state == NELivePKState.pking) {
      _pkStatus = NELivePKStatus.pking;
    } else if (pkRet.data?.state == NELivePKState.punishing) {
      _pkStatus = NELivePKStatus.punishing;
    }
    if (pkRet.data?.inviter?.userUuid == liveDetail.anchor?.userUuid) {
      _isInviter = true;
    } else {
      _isInviter = false;
    }
    _audienceLiveInfo.liveDetail = liveDetail;
    _audienceLiveInfo.liveRoom = context;
    commonLogger.i('joinLive pkId:$_pkId pkStatus:$_pkStatus');
    context.addEventCallback(_roomEvent.audienceRoomEvent);
    _mode = _NELiveMode.audience;
    return NEResult(
        code: ret.code, msg: ret.msg, data: liveInfo.data?.rtmpPullUrl);
  }

  @override
  Future<VoidResult> leaveLive() async {
    commonLogger.i('leaveLive');
    if (_mode != _NELiveMode.audience) {
      commonLogger.e('leaveLive mode is not audience');
      return Future.value(const NEResult(code: -1, msg: 'not supported now'));
    }
    var room = _audienceLiveInfo.liveRoom;
    if (room == null) {
      commonLogger.e('leaveLive not in live');
      return Future.value(const NEResult(code: -1, msg: 'not in live'));
    }
    var ret = await room.leaveRoom();
    var _ = await _resetLive();
    return NEResult(code: ret.code, msg: ret.msg);
  }

  final _eventCallbacks = <NELiveCallback>{};

  @override
  void addEventCallback(NELiveCallback callback) {
    commonLogger.i('addEventCallback');
    _eventCallbacks.add(callback);
  }

  @override
  void removeEventCallback(NELiveCallback callback) {
    commonLogger.i('addEventCallback');
    _eventCallbacks.remove(callback);
  }

  /// do operations when live ended
  Future<VoidResult> _resetLive(
      {bool shouldNotify = false, int reason = 1}) async {
    commonLogger.i('resetLive');
    var _ = await _resetPK();
    if (_mode == _NELiveMode.audience) {
      var _ = await _audienceLiveInfo.liveRoom?.leaveRoom();
      _audienceLiveInfo.liveRoom = null;
      _audienceLiveInfo.liveDetail = null;
    } else if (_mode == _NELiveMode.anchor) {
      var context = _anchorLiveInfo.liveRoom;
      if (context != null) {
        mediaController.stopAllEffects();
        mediaController.stopAudioMixing();
        var _ = await _pushService.stopLivePush(context);
        var end = await context.leaveRoom();
        _anchorLiveInfo.liveDetail = null;
        _anchorLiveInfo.liveRoom = null;
      }
    }
    if (shouldNotify) {
      for (var callback in _eventCallbacks) {
        callback.liveEnded?.call(reason);
      }
    }
    return Future.value(const NEResult(code: 0));
  }

  /// do operations when pk ended
  Future<VoidResult> _resetPK(
      {bool shouldNotify = false, bool shouldToSingle = false}) async {
    commonLogger.i('resetPK');
    _pkStatus = NELivePKStatus.idle;
    _pkId = null;
    if (_mode == _NELiveMode.anchor &&
        _anchorLiveInfo.peerRoom != null &&
        _anchorLiveInfo.liveRoom != null) {
      if (TextUtils.isNotEmpty(_anchorLiveInfo.peer?.userUuid)) {
        _anchorLiveInfo.liveRoom!.rtcController
            .subscribeRemoteVideoStream(_anchorLiveInfo.peer!.userUuid!, false);
      }
      var _ = await _anchorLiveInfo.peerRoom!.rtcController
          .stopRtcChannelMediaRelay();
      if (shouldToSingle) {
        _pushService.stopPKPush(_anchorLiveInfo.liveRoom!);
      }
      _anchorLiveInfo.peerRoom!.leaveRoom();
      _anchorLiveInfo.peerRoom!.removeEventCallback(_roomEvent.peerRoomEvent);
      _anchorLiveInfo.peerRoom = null;
      _anchorLiveInfo.peer = null;
    }
    return Future.value(const NEResult(code: 0));
  }

  // **************************************************************************

  _onReceivePassThroughMessage(NEPassThroughMessage message) {
    commonLogger.i('onReceivePassThroughMessage data:${message.data}');
    var body = message.data;
    var map = json.decode(body);
    if (map is Map) {
      var model = _NEPKControlNotification._fromJson(map);
      var subCmd = model.subCmd;
      var type = model.type;
      var action = model.action;
      if (subCmd == 2 && type == 2000 && action != null) {
        switch (_NELivePKAction.values[action]) {
          case _NELivePKAction.invite:
            _notifyPKInviteReceived(model);
            break;
          case _NELivePKAction.cancel:
            _notifyPKInviteCanceled(model);
            break;
          case _NELivePKAction.accept:
            _notifyPKInviteAccepted(model);
            break;
          case _NELivePKAction.reject:
            _notifyPKInviteRejected(model);
            break;
          case _NELivePKAction.timeout:
            _notifyPKInviteTimeout(model);
            break;
          default:
            break;
        }
      }
    }
  }

  _notifyMessagesReceived(List<NERoomTextMessage> messages) {
    for (var callback in _eventCallbacks) {
      callback.messagesReceived?.call(messages);
    }
  }

  _notifyPKInviteReceived(_NEPKControlNotification notification) {
    commonLogger.i('notifyPKInviteReceived');
    if (_mode == _NELiveMode.anchor && _pkStatus != NELivePKStatus.invited) {
      _pkStatus = NELivePKStatus.invited;
      _isInviter = false;
      _pkId = notification.pkId;
      for (var callback in _eventCallbacks) {
        callback.pKInvited
            ?.call(NELivePKAnchor._fromActionAnchor(notification.actionAnchor));
      }
    }
  }

  _notifyPKInviteCanceled(_NEPKControlNotification notification) {
    commonLogger.i('notifyPKInviteCanceled');
    if (_mode == _NELiveMode.anchor && _pkId == notification.pkId) {
      _resetPK().then((value) {
        for (var callback in _eventCallbacks) {
          callback.pKCanceled?.call(
              NELivePKAnchor._fromActionAnchor(notification.actionAnchor));
        }
      });
    }
  }

  _notifyPKInviteRejected(_NEPKControlNotification notification) {
    commonLogger.i('notifyPKInviteRejected');
    if (_mode == _NELiveMode.anchor && _pkId == notification.pkId) {
      _resetPK().then((value) {
        for (var callback in _eventCallbacks) {
          callback.pKRejected?.call(
              NELivePKAnchor._fromActionAnchor(notification.actionAnchor));
        }
      });
    }
  }

  _notifyPKInviteAccepted(_NEPKControlNotification notification) {
    commonLogger.i('notifyPKInviteAccepted');
    var roomUuid = notification.targetAnchor?.roomUuid;
    if (_mode == _NELiveMode.anchor &&
        _pkId == notification.pkId &&
        TextUtils.isNotEmpty(roomUuid)) {
      var params = NEJoinRoomParams(
          roomUuid: roomUuid!, userName: nickname ?? _userUuid!, role: 'invited_host');
      NERoomKit.instance.roomService
          .joinRoom(params, NEJoinRoomOptions())
          .then((value) {
        var context = value.data;
        if (value.code == 0 && context != null) {
          _anchorLiveInfo.peerRoom = context;
          _anchorLiveInfo.peerRoom!.addEventCallback(_roomEvent.peerRoomEvent);
          context.rtcController.startRtcChannelMediaRelay().then((value2) {
            if (value2.code != 0) {
              _anchorLiveInfo.peerRoom!
                  .removeEventCallback(_roomEvent.peerRoomEvent);
              _anchorLiveInfo.peerRoom = null;
            }
          });
        } else {
          commonLogger.e(
              'notifyPKInviteAccepted joinRoom failed code:${value.code} msg:${value.msg}');
        }
      });
      for (var callback in _eventCallbacks) {
        callback.pKAccepted
            ?.call(NELivePKAnchor._fromActionAnchor(notification.actionAnchor));
      }
    }
  }

  _notifyPKInviteTimeout(_NEPKControlNotification notification) {
    commonLogger.i('notifyPKInviteTimeout');
    if (_mode == _NELiveMode.anchor && _pkId == notification.pkId) {
      _resetPK().then((value) {
        for (var callback in _eventCallbacks) {
          callback.pKTimeout?.call(
              NELivePKAnchor._fromActionAnchor(notification.actionAnchor));
        }
      });
    }
  }

  _notifyPKStart(String pkId, int pkStartTime, int pkCountDown,
      _NEPKStartAnchor inviter, _NEPKStartAnchor invitee) {
    commonLogger.i('notifyPKStart pkId:$pkId');
    if (isPKing) {
      return;
    }
    if (_pkId == pkId && _mode == _NELiveMode.anchor) {
      _pkStatus = NELivePKStatus.pking;
      _anchorLiveInfo.peer = _isInviter ? invitee : inviter;
      var self = _isInviter ? inviter : invitee;
      if (_anchorLiveInfo.liveRoom != null &&
          TextUtils.isNotEmpty(_anchorLiveInfo.peer?.userUuid)) {
        _anchorLiveInfo.liveRoom!.rtcController
            .subscribeRemoteVideoStream(_anchorLiveInfo.peer!.userUuid!, true);
        _pushService.startPKPush(_anchorLiveInfo.liveRoom!);
      }
      for (var callback in _eventCallbacks) {
        callback.pkStart?.call(
            pkStartTime,
            pkCountDown,
            NELivePKAnchor._fromPKStartAnchor(self),
            NELivePKAnchor._fromPKStartAnchor(_anchorLiveInfo.peer));
      }
    } else if (_mode == _NELiveMode.audience) {
      _pkId = pkId;
      _pkStatus = NELivePKStatus.pking;
      _NEPKStartAnchor self, peer;
      if (inviter.userUuid == _audienceLiveInfo.liveDetail?.anchor?.userUuid) {
        self = inviter;
        peer = invitee;
        _isInviter = true;
      } else {
        self = invitee;
        peer = inviter;
        _isInviter = false;
      }
      for (var callback in _eventCallbacks) {
        callback.pkStart?.call(
            pkStartTime,
            pkCountDown,
            NELivePKAnchor._fromPKStartAnchor(self),
            NELivePKAnchor._fromPKStartAnchor(peer));
      }
    }
  }

  _notifyPKPunishingStart(
      String pkId,
      int pkPenaltyCountDown,
      int inviterRewards,
      int inviteeRewards,
      _NEPunishAnchor inviter,
      _NEPunishAnchor invitee) {
    commonLogger.i('notifyPKPunishingStart pkId:$pkId');
    if (_pkId == pkId) {
      _pkStatus = NELivePKStatus.punishing;
      for (var callback in _eventCallbacks) {
        callback.pkPunishmentStart?.call(
            pkPenaltyCountDown,
            _isInviter ? inviterRewards : inviteeRewards,
            _isInviter ? inviteeRewards : inviterRewards);
      }
    }
  }

  _notifyPKEnd(String pkId, int reason, String senderUserUuid, String userName, int pkEndTime, int
  inviterRewards,
      int inviteeRewards, bool countDownEnd) {
    commonLogger.i('notifyPKEnd pkId:$pkId');
    if (_pkId == pkId) {
      // keep self stream pushing
      _resetPK(shouldToSingle: true).then((value) {
        for (var callback in _eventCallbacks) {
          callback.pkEnded?.call(
              reason,
              pkEndTime,
              senderUserUuid,
              userName,
              _isInviter ? inviterRewards : inviteeRewards,
              _isInviter ? inviteeRewards : inviterRewards,
              countDownEnd);
        }
      });
    } else {
      for (var callback in _eventCallbacks) {
        callback.pkEnded?.call(
            reason,
            pkEndTime,
            senderUserUuid,
            userName,
            _isInviter ? inviterRewards : inviteeRewards,
            _isInviter ? inviteeRewards : inviterRewards,
            countDownEnd);
      }
    }
  }

  _notifyRewardReceived(
      String rewarderUserUuid,
      String? rewarderUserName,
      int giftId,
      _NEAnchorReward anchorReward,
      _NEAnchorReward otherAnchorReward) {
    commonLogger.i(
        'notifyRewardReceived rewarderUserUuid:$rewarderUserUuid rewarderUserName:$rewarderUserName giftId:$giftId');
    for (var callback in _eventCallbacks) {
      callback.rewardReceived?.call(
          rewarderUserUuid,
          rewarderUserName,
          giftId,
          NELiveAnchorReward._fromReward(anchorReward),
          NELiveAnchorReward._fromReward(otherAnchorReward));
    }
  }

  _notifyMembersJoin(List<NERoomMember> members) {
    commonLogger.i('notifyMembersJoin pkId:$pkId');
    for (var callback in _eventCallbacks) {
      callback.membersJoin?.call(members);
    }
  }

  _notifyMembersLeave(List<NERoomMember> members) {
    commonLogger.i('notifyMembersLeave pkId:$pkId');
    for (var callback in _eventCallbacks) {
      callback.membersLeave?.call(members);
    }
  }
}
