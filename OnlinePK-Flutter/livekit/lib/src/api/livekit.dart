// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_livekit;

/// LiveKit
abstract class NELiveKit {
  static final _instance = _NELiveKitImpl();

  /// LiveKit single instance
  static _NELiveKitImpl get instance => _instance;

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
  Future<NEResult<NELiveDetail?>> startLive(String liveTopic,
      NELiveRoomType liveType, String cover, bool isFrontCamera);

  ///
  /// update live
  Future<VoidResult> updateLive(List<String> uuid);

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
  /// fetch chatroom members
  /// [queryType] queryType
  /// [limit] limit
  Future<NEResult<List<NEChatroomMember>>> fetchChatroomMembers(
      NEChatroomMemberQueryType queryType,
      int limit,
      String? lastMemberAccount);

  ///
  /// reward anchor
  /// [giftId] gift ID
  ///
  Future<VoidResult> reward(int giftId);

  ///
  /// 获取默认开播信息，比如头像与房间名
  ///
  Future<NEResult<NELiveDefaultInfo?>> getDefaultLiveInfo();

  ///
  /// audience join live
  /// [liveDetail] live info
  ///
  Future<NEResult<String?>> joinLive(NELiveDetail liveDetail);

  /// leave live
  Future<VoidResult> leaveLive();

  /// upload log file
  Future<VoidResult> uploadLog();

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

  ///
  /// get local member
  ///
  NERoomMember? get localMember;
}
