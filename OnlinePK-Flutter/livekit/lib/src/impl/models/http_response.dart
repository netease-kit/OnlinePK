// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_livekit;

/// 主播信息
class _NECreateLiveAnchor {
  /// 用户编号
  String? userUuid;

  /// 昵称
  String? userName;

  /// 头像地址
  String? icon;
  int? rtcUid;

  _NECreateLiveAnchor.fromJson(Map? json) {
    userUuid = json?['userUuid'] as String?;
    userName = json?['userName'] as String?;
    icon = json?['icon'] as String?;
    rtcUid = json?['rtcUid'] as int?;
  }
}

/// 直播信息
class _NECreateLiveLive {
  /// 房间号
  String? roomUuid;

  /// 创建人账号
  String? userUuid;

  /// 创建人账号
  int? chatRoomId;

  /// 直播类型
  int? liveType;

  /// 直播记录是否有效 1: 有效 -1 无效
  int? status;

  /// 直播状态，0.未开始，1.直播中，2.PK中 3. 惩罚中  4.连麦中  5.等待PK中  6.直播结束
  int? live;

  /// 直播主题
  String? liveTopic;

  /// 背景图地址
  String? cover;

  /// 打赏总额
  int? rewardTotal;

  /// 观众人数
  int? audienceCount;

  int? liveRecordId;
  String? appId;
  Map<String, dynamic>? liveConfig;
  String? createTime;
  String? updateTime;

  String? pkId;

  _NECreateLiveLive.fromJson(Map? json) {
    roomUuid = json?['roomUuid'] as String?;
    userUuid = json?['userUuid'] as String?;
    chatRoomId = json?['chatRoomId'] as int?;
    liveType = json?['liveType'] as int?;
    status = json?['status'] as int?;
    live = json?['live'] as int?;
    liveTopic = json?['liveTopic'] as String?;
    cover = json?['cover'] as String?;
    rewardTotal = json?['rewardTotal'] as int?;
    audienceCount = json?['audienceCount'] as int?;
    liveRecordId = json?['liveRecordId'] as int?;
    appId = json?['appId'] as String?;
    liveConfig = json?['externalLiveConfig'] as Map<String, dynamic>?;
    createTime = json?['createTime'] as String?;
    updateTime = json?['updateTime'] as String?;
    pkId = json?['pkId'] as String?;
  }
}

class _NECreateLiveResponse {
  _NECreateLiveAnchor? anchor;
  _NECreateLiveLive? live;

  _NECreateLiveResponse.fromJson(Map? json) {
    anchor = _NECreateLiveAnchor.fromJson(json?['anchor'] as Map?);
    live = _NECreateLiveLive.fromJson(json?['live'] as Map?);
  }
}

/// 直播信息
class _NELiveInfoResponse {
  _NECreateLiveAnchor? anchor;
  _NECreateLiveLive? live;

  _NELiveInfoResponse.fromJson(Map? json) {
    anchor = _NECreateLiveAnchor.fromJson(json?['anchor'] as Map?);
    live = _NECreateLiveLive.fromJson(json?['live'] as Map?);
  }
}

/// 直播信息
class _NELiveListResponse {
  int? pageNum;
  int? pageSize;
  int? size;
  int? startRow;
  int? endRow;
  int? pages;
  int? prePage;
  int? nextPage;
  bool? isFirstPage;
  bool? isLastPage;
  bool? hasPreviousPage;
  bool? hasNextPage;
  int? navigatePages;
  List<int>? navigatepageNums;
  int? navigateFirstPage;
  int? navigateLastPage;
  int? total;
  List<_NELiveInfoResponse>? list;

  _NELiveListResponse.fromJson(Map? json) {
    pageNum = json?['pageNum'] as int?;
    pageSize = json?['pageSize'] as int?;
    size = json?['size'] as int?;
    startRow = json?['startRow'] as int?;
    endRow = json?['endRow'] as int?;
    pages = json?['pages'] as int?;
    prePage = json?['prePage'] as int?;
    nextPage = json?['nextPage'] as int?;
    navigatePages = json?['navigatePages'] as int?;
    navigateFirstPage = json?['navigateFirstPage'] as int?;
    navigateLastPage = json?['navigateLastPage'] as int?;
    total = json?['total'] as int?;
    isFirstPage = json?['isFirstPage'] as bool?;
    isLastPage = json?['isLastPage'] as bool?;
    hasPreviousPage = json?['hasPreviousPage'] as bool?;
    hasNextPage = json?['hasNextPage'] as bool?;
    navigatepageNums = (json?['navigatepageNums'] as List<dynamic>?)
        ?.map((e) => e as int)
        .toList();
    list = (json?['list'] as List<dynamic>?)
        ?.map((e) => _NELiveInfoResponse.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

/// 创建房间所需的主题与背景图片
class _NELiveDefaultInfoResponse {
  /// 房间主题
  String? topic;

  /// 默认背景图
  String? livePicture;

  /// 可选背景图列表
  List<String>? defaultPictures;

  _NELiveDefaultInfoResponse.fromJson(Map? json) {
    topic = json?['topic'] as String?;
    livePicture = json?['livePicture'] as String?;
    defaultPictures = (json?['defaultPictures'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();
  }
}
