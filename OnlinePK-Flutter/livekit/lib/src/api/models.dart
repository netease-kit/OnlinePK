// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_livekit;

///
/// 提供初始化配置
/// [appKey] appKey
/// [useAssetServerConfig] 是否读取私有化配置文件，默认为false
/// [extras] 预留字段
///
class NELiveKitOptions {
  NELiveKitOptions({
    required this.appKey,
    this.useAssetServerConfig = false,
    Map<String, String>? extras,
    required this.liveUrl,
  }) : extras = extras != null ? Map.from(extras) : const {};

  /// appKey
  final String appKey;

  /// 是否解析 assets 目录下的私有化配置文件
  final bool useAssetServerConfig;

  /// extra params
  final Map<String, String>? extras;

  /// 直播业务接口host
  final String liveUrl;
}

class NELiveDetail {
  /// anchor info
  NEAnchorModel? anchor;

  /// live info
  NELiveModel? live;

  NELiveDetail._fromCreateLiveResponse(_NECreateLiveResponse? create) {
    anchor = NEAnchorModel._fromCreateLiveAnchor(create?.anchor);
    live = NELiveModel._fromCreateLive(create?.live);
  }

  NELiveDetail._fromLiveInfoResponse(_NELiveInfoResponse? info) {
    anchor = NEAnchorModel._fromCreateLiveAnchor(info?.anchor);
    live = NELiveModel._fromCreateLive(info?.live);
  }
}

/// 创建房间所需的主题与背景图片
class NELiveDefaultInfo {
  /// 房间主题
  String? topic;

  /// 默认背景图
  String? livePicture;

  /// 可选背景图列表
  List<String>? defaultPictures;

  NELiveDefaultInfo._fromLiveDefaultInfoResponse(
      _NELiveDefaultInfoResponse? info) {
    topic = info?.topic;
    livePicture = info?.livePicture;
    defaultPictures = info?.defaultPictures;
  }
}

/// anchor info
class NEAnchorModel {
  /// anchor userUuid
  String? userUuid;

  /// anchor nickname
  String? userName;

  /// anchor icon
  String? icon;

  NEAnchorModel._fromCreateLiveAnchor(_NECreateLiveAnchor? anchor) {
    userUuid = anchor?.userUuid;
    userName = anchor?.userName;
    icon = anchor?.icon;
  }
}

class NELiveModel {
  /// live roomUuid
  String? roomUuid;

  /// anchor userUuid
  String? userUuid;

  /// live ID
  int liveRecordId = 0;

  /// is live invalid, 1 for valid, -1 for invalid
  int status = 1;

  /// live topic
  String? liveTopic;

  /// live cover
  String? cover;

  /// reward total coins
  int rewardTotal = 0;

  /// live audience count
  int audienceCount = 0;

  /// live status
  NELiveStatus live = NELiveStatus.idle;

  /// live info
  NELiveExternalLiveConfig? liveInfo;

  NELiveModel._fromCreateLive(_NECreateLiveLive? live) {
    roomUuid = live?.roomUuid;
    userUuid = live?.userUuid;
    liveRecordId = live?.liveRecordId ?? 0;
    status = live?.status ?? 1;
    liveTopic = live?.liveTopic;
    cover = live?.cover;
    rewardTotal = live?.rewardTotal ?? 0;
    audienceCount = live?.audienceCount ?? 0;
    this.live = NELiveStatus.values[live?.live ?? 0];
    if (live?.liveConfig != null) {
      liveInfo = NELiveExternalLiveConfig(
          pushUrl: live?.liveConfig?['pushUrl'] as String?,
          pullHlsUrl: live?.liveConfig?['pullHlsUrl'] as String?,
          pullRtmpUrl: live?.liveConfig?['pullRtmpUrl'] as String?,
          pullHttpUrl: live?.liveConfig?['pullHttpUrl'] as String?);
    }
  }
}

class NELiveExternalLiveConfig {
  String? pushUrl;
  String? pullHlsUrl;
  String? pullRtmpUrl;
  String? pullHttpUrl;

  NELiveExternalLiveConfig(
      {this.pushUrl, this.pullHlsUrl, this.pullRtmpUrl, this.pullHttpUrl});
}

class NELiveList {
  /// total live count
  int total = 0;

  /// lives
  List<NELiveDetail>? list;

  /// current page
  int pageNum = 0;

  /// page size
  int pageSize = 0;

  /// has Next Page
  bool hasNextPage = false;

  NELiveList._fromLiveListResponse(_NELiveListResponse? list) {
    total = list?.total ?? 0;
    pageNum = list?.pageNum ?? 0;
    pageSize = list?.pageSize ?? 0;
    hasNextPage = list?.hasNextPage ?? false;
    this.list =
        list?.list?.map((e) => NELiveDetail._fromLiveInfoResponse(e)).toList();
  }
}

class NELiveBatchRewardMessage {
  String? senderUserUuid;
  int? sendTime;
  String? userName;
  String? userUuid;
  int? giftId;
  int? giftCount;
  List<NELiveBatchSeatUserReward>? seatUserReward;
  List<NELiveBatchSeatUserRewardee>? targets;

  NELiveBatchRewardMessage._fromMessage(_NELiveBatchRewardMessage? map) {
    senderUserUuid = map?.senderUserUuid;
    sendTime = map?.sendTime;
    userName = map?.userName;
    userUuid = map?.userUuid;
    giftId = map?.giftId;
    giftCount = map?.giftCount;
    seatUserReward = map?.seatUserReward
        ?.map((e) => NELiveBatchSeatUserReward._fromMessage(e))
        .toList();
    targets = map?.targets
        ?.map((e) => NELiveBatchSeatUserRewardee._fromMessage(e))
        .toList();
  }
}

class NELiveBatchSeatUserReward {
  int? seatIndex;
  String? userUuid;
  String? userName;
  int? rewardTotal;
  String? icon;

  NELiveBatchSeatUserReward._fromMessage(_NELiveBatchSeatUserReward? map) {
    seatIndex = map?.seatIndex;
    userUuid = map?.userUuid;
    userName = map?.userName;
    rewardTotal = map?.rewardTotal;
    icon = map?.icon;
  }
}

class NELiveBatchSeatUserRewardee {
  String? userUuid;
  String? userName;
  String? icon;

  NELiveBatchSeatUserRewardee._fromMessage(_NELiveBatchSeatUserRewardee? map) {
    userUuid = map?.userUuid;
    userName = map?.userName;
    icon = map?.icon;
  }
}
