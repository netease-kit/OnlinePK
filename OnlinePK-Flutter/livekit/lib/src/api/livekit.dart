// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

/// LiveKit
abstract class NELiveKit {
  static final _instance = _NELiveKitImpl();

  /// LiveKit single instance
  static _NELiveKitImpl get instance => _instance;

  /// include pking and punishing
  bool get isPKing;

  /// current pk status
  NELivePKStatus get pkStatus;

  /// current pk ID
  String? get pkId;

  /// is inviter in pk
  bool get isInviter;

  /// members in current live
  List<NERoomMember>? get members;

  /// live detail
  NELiveDetail? get liveDetail;

  /// is logged in
  Future<bool> get isLoggedIn;

  /// current userUuid
  String? get userUuid;

  /// nickname
  String? nickname;

  NEAudioOutputDevice? audioOutputDevice;

  /// media controller to control audio video and devices
  NELiveMediaController get mediaController;

  ///
  /// initialize SDK
  /// [options] initialize options
  ///
  Future<VoidResult> initialize(NELiveKitOptions options);

  ///
  /// login account
  /// [userUuid] userUuid
  /// [token]  token
  ///
  Future<VoidResult> login(String userUuid, String token);

  /// logout account
  Future<VoidResult> logout();

  ///
  /// start live
  /// [liveTopic] topic
  /// [liveType]  type
  /// [cover]  cover
  ///
  Future<NEResult<NELiveDetail?>> startLive(
      String liveTopic, NELiveRoomType liveType, String cover);

  /// stop live
  Future<VoidResult> stopLive();

  ///
  /// fetch live info
  /// [liveRecordId] live ID
  ///
  Future<NEResult<NELiveDetail?>> fetchLiveInfo(int liveRecordId);

  ///
  /// fetch live list
  /// [pageNum] page number
  /// [pageSize] page size
  /// [liveStatus] live status
  /// [liveType] live type
  ///
  Future<NEResult<NELiveList?>> fetchLiveList(int pageNum, int pageSize,
      NELiveStatus liveStatus, NELiveRoomType liveType);

  ///
  /// send text message to chatroom
  /// [message] message content
  ///
  Future<VoidResult> sendTextMessage(String message);

  ///
  /// fetch pk info
  /// [liveRecordId] live ID
  ///
  Future<NEResult<NELivePKDetail?>> fetchPKInfo(int liveRecordId);

  ///
  /// invite anchor to PK
  /// [targetAccountId] peer userUuid
  /// [rule] pk rule
  ///
  Future<VoidResult> invitePK(String targetAccountId, NELivePKRule rule);

  /// cancel pk invite
  Future<VoidResult> cancelPKInvite();

  /// reject pk invite
  Future<VoidResult> rejectPK();

  /// accept pk invite
  Future<VoidResult> acceptPK();

  /// stop pk
  Future<VoidResult> stopPK();

  ///
  /// fetch reward top list
  /// [liveRecordId] live ID
  /// [pkId] PK ID
  ///
  Future<NEResult<NELivePKRewardTop?>> fetchRewardTopList(
      int liveRecordId, String pkId);

  ///
  /// fetch chatroom members
  /// [queryType] queryType
  /// [limit] limit
  Future<NEResult<List<NEChatRoomMember>>> fetchChatRoomMembers(
      NEChatroomMemberQueryType queryType, int limit);

  ///
  /// reward anchor
  /// [giftId] gift ID
  ///
  Future<VoidResult> reward(int giftId);

  ///
  /// audience join live
  /// [liveDetail] live info
  ///
  Future<NEResult<String?>> joinLive(NELiveDetail liveDetail);

  /// leave live
  Future<VoidResult> leaveLive();

  ///
  /// add listener
  /// [callback] callback
  ///
  void addEventCallback(NELiveCallback callback);

  ///
  /// remove listener
  /// [callback] callback
  ///
  void removeEventCallback(NELiveCallback callback);
}
