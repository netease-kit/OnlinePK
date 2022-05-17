// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

class _NELiveHttpRepository {
  static var manager = _HttpExecutor();

  static late String appKey;

  static String _path(String subPath, String module, String version) {
    return '/scene/apps/$appKey/$module/$version/$subPath';
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/live/v1/createLive HTTP/1.1
  static Future<NEResult<_NECreateLiveResponse>> startLive(int configId,
      NELiveRoomType liveType, String liveTopic, String cover) async {
    var body = {
      'configId': configId,
      'liveType': liveType.index,
      'liveTopic': liveTopic,
      'cover': cover,
    };
    var ret = await manager._post(_path('createLive', 'ent/live', 'v1'), body);
    var response = _NECreateLiveResponse.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/live/v1/destroyLive HTTP/1.1
  static Future<VoidResult> stopLive(int liveRecordId) async {
    var body = {'liveRecordId': liveRecordId};
    var ret =
        await manager._post(_path('destroyLive', 'ent/live', 'v1'), body);
    return NEResult(code: ret.code, msg: ret.msg);
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/live/v1/info HTTP/1.1
  static Future<NEResult<_NELiveInfoResponse>> fetchLiveInfo(
      int liveRecordId) async {
    var body = {'liveRecordId': liveRecordId};
    var ret = await manager._post(_path('info', 'ent/live', 'v1'), body);
    var response = _NELiveInfoResponse.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/live/v1/list HTTP/1.1
  static Future<NEResult<_NELiveListResponse>> fetchLiveList(int pageNum,
      int pageSize, NELiveStatus liveStatus, NELiveRoomType liveType) async {
    var body = {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'liveStatus': liveStatus.index,
      'liveType': liveType.index,
    };
    var ret = await manager._post(_path('list', 'ent/live', 'v1'), body);
    var response = _NELiveListResponse.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/pk/v1/inviteControl HTTP/1.1
  /// action 1 邀请，2 同意，3 取消，4 拒绝
  static Future<NEResult<_NEPKControlResponse>> inviteControl(
      String? pkId,
      _NELivePKAction action,
      String? targetAccountId,
      NELivePKRule? rule) async {
    var body = {
      'pkId': pkId,
      'action': action.index,
      'anchorUserUuid': targetAccountId,
      "rule": rule?.toJson(),
    };
    var ret =
        await manager._post(_path('inviteControl', 'ent/pk', 'v1'), body);
    var response = _NEPKControlResponse.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/pk/v1/info HTTP/1.1
  static Future<NEResult<_NEPKInfoResponse>> fetchPKInfo(
      int liveRecordId) async {
    var body = {'liveRecordId': liveRecordId};
    var ret = await manager._post(_path('info', 'ent/pk', 'v1'), body);
    var response = _NEPKInfoResponse.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/pk/v1/end HTTP/1.1
  static Future<VoidResult> stopPK(String pkId) async {
    var body = {'pkId': pkId};
    var ret = await manager._post(_path('end', 'ent/pk', 'v1'), body);
    return NEResult(code: ret.code, msg: ret.msg);
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/live/v1/reward HTTP/1.1
  static Future<VoidResult> reward(
      int liveRecordId, int giftId, String? pkId) async {
    var body = {
      'liveRecordId': liveRecordId,
      'giftId': giftId,
      'pkId': pkId,
    };
    var ret = await manager._post(_path('reward', 'ent/live', 'v1'), body);
    return NEResult(code: ret.code, msg: ret.msg);
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/pk/v1/rewardTop HTTP/1.1
  static Future<NEResult<_NEPKInfoRewardTop>> fetchRewardTopList(
      int liveRecordId, String pkId) async {
    var body = {
      'liveRecordId': liveRecordId,
      'pkId': pkId,
    };
    var ret = await manager._post(_path('rewardTop', 'ent/pk', 'v1'), body);
    var response = _NEPKInfoRewardTop.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }
}
