// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_livekit;

class _NELiveHttpRepository {
  static var manager = _HttpExecutor();

  static String _path(String subPath) {
    return '/nemo/entertainmentLive/live/$subPath';
  }

  static Future<NEResult<_NECreateLiveResponse>> startLive(int configId,
      NELiveRoomType liveType, String liveTopic, String cover) async {
    var body = {
      'configId': configId,
      'liveType': liveType.index,
      'liveTopic': liveTopic,
      'cover': cover,
      'roomProfile': 1,
      'seatCount': 9,
      'seatApplyMode': 1,
    };
    var ret = await manager._post(_path('createLive'), body);
    var response = _NECreateLiveResponse.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }

  static Future<VoidResult> stopLive(int liveRecordId) async {
    var body = {'liveRecordId': liveRecordId};
    var ret = await manager._post(_path('destroyLive'), body);
    return NEResult(code: ret.code, msg: ret.msg);
  }

  static Future<NEResult<_NELiveInfoResponse>> fetchLiveInfo(
      int liveRecordId) async {
    var body = {'liveRecordId': liveRecordId};
    var ret = await manager._post(_path('info'), body);
    var response = _NELiveInfoResponse.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }

  static Future<NEResult<_NELiveListResponse>> fetchLiveList(int pageNum,
      int pageSize, NELiveStatus liveStatus, NELiveRoomType liveType) async {
    var body = {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'liveStatus': liveStatus.index,
      'liveType': liveType.index,
    };
    var ret = await manager._post(_path('list'), body);
    var response = _NELiveListResponse.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }

  static Future<VoidResult> reward(int liveRecordId, int giftId, int giftCount,
      List<String> userUuids) async {
    var body = {
      'liveRecordId': liveRecordId,
      'giftId': giftId,
      'giftCount': giftCount,
      'targets': userUuids
    };
    var ret = await manager._post(_path('batch/reward'), body);
    return NEResult(code: ret.code, msg: ret.msg);
  }

  static Future<NEResult<_NELiveDefaultInfoResponse>>
      getDefaultLiveInfo() async {
    var ret = await manager._get(_path('getDefaultLiveInfo'), null);
    var response = _NELiveDefaultInfoResponse.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }
}
