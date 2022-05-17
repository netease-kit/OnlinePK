// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

/// initialize options
class NELiveKitOptions {
  NELiveKitOptions({
    required this.appKey,
    Map<String, String>? extras,
  }) : extras = extras != null ? Map.from(extras) : const {};

  /// appKey
  final String appKey;

  /// extra params
  final Map<String, String>? extras;
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

  /// live type
  NELiveRoomType liveType = NELiveRoomType.pkLive;

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

  /// live pk ID
  String? pkId;

  /// live info
  NERoomLiveInfo? liveInfo;

  NELiveModel._fromCreateLive(_NECreateLiveLive? live) {
    roomUuid = live?.roomUuid;
    userUuid = live?.userUuid;
    liveRecordId = live?.liveRecordId ?? 0;
    liveType = NELiveRoomType.values[live?.liveType ?? 0];
    status = live?.status ?? 1;
    liveTopic = live?.liveTopic;
    cover = live?.cover;
    rewardTotal = live?.rewardTotal ?? 0;
    audienceCount = live?.audienceCount ?? 0;
    this.live = NELiveStatus.values[live?.live ?? 0];
    pkId = live?.pkId;
    if (live?.liveConfig != null) {
      Map<String, dynamic> m = json.decode(live!.liveConfig!) as Map<String, dynamic>;
      liveInfo = NERoomLiveInfo(
          title: 'title',
          pushUrl: m['pushUrl'] as String,
          httpPullUrl: m['pullHttpUrl'] as String,
          rtmpPullUrl: m['pullRtmpUrl'] as String,
          hlsPullUrl: m['pullHlsUrl'] as String);
    }
  }
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

class NEPKRewardDetail {
  /// anchor userUuid
  String? userUuid;

  /// anchor nickname
  String? userName;

  /// anchor icon
  String? icon;

  /// reward coin
  int rewardCoin = 0;

  NEPKRewardDetail._fromPKInfoRewardDetail(_NEPKInfoRewardDetail? detail) {
    userUuid = detail?.userUuid;
    userName = detail?.userName;
    icon = detail?.icon;
    rewardCoin = detail?.rewardCoin ?? 0;
  }
}

class NELivePKRewardTop {
  /// reward top
  List<NEPKRewardDetail>? rewardTop;

  /// reward total coins
  int rewardCoinTotal = 0;

  NELivePKRewardTop._fromPKInfoRewardTop(_NEPKInfoRewardTop? top) {
    rewardCoinTotal = top?.rewardCoinTotal ?? 0;
    rewardTop = top?.rewardTop
        ?.map((e) => NEPKRewardDetail._fromPKInfoRewardDetail(e))
        .toList();
  }
}

class NEPKRewardTop {
  List<NEPKRewardDetail>? rewardTop;
  int rewardCoinTotal = 0;

  List<String?>? get rewardIcons {
    return rewardTop?.map((e) => e.icon).toList();
  }

  NEPKRewardTop._fromRewardTop(_NEPKInfoRewardTop? rewardTop) {
    rewardCoinTotal = rewardTop?.rewardCoinTotal ?? 0;
    this.rewardTop = rewardTop?.rewardTop
        ?.map((e) => NEPKRewardDetail._fromPKInfoRewardDetail(e))
        .toList();
  }
}

class NELivePKDetail {
  /// pk ID
  String? pkId;

  NELivePKState state = NELivePKState.pKEnded;

  /// remaining time(s)
  int countDown = 0;

  /// pk start time
  int pkStartTime = 0;

  /// pk end time
  int pkEndTime = 0;

  /// pk inviter
  NELivePKAnchor? inviter;

  /// pk invitee
  NELivePKAnchor? invitee;

  /// inviter rewarded info
  NEPKRewardTop? inviterReward;

  /// invitee rewarded info
  NEPKRewardTop? inviteeReward;

  NELivePKDetail._fromResponse(_NEPKInfoResponse? info) {
    pkId = info?.pkId;
    state = NELivePKState.values[info?.state ?? 0];
    countDown = info?.countDown ?? 0;
    pkStartTime = info?.pkStartTime ?? 0;
    pkEndTime = info?.pkEndTime ?? 0;
    invitee = NELivePKAnchor._fromPKInfoInviter(info?.invitee);
    inviter = NELivePKAnchor._fromPKInfoInviter(info?.inviter);
    inviterReward = NEPKRewardTop._fromRewardTop(info?.inviterReward);
    inviteeReward = NEPKRewardTop._fromRewardTop(info?.inviteeReward);
  }
}

class NELivePKAnchor {
  String? userUuid;
  int rewardTotal = 0;
  String? userName;
  String? icon;

  /// 直播编号
  int liveRecordId = 0;

  NELivePKAnchor._fromPKStartAnchor(_NEPKStartAnchor? anchor) {
    userUuid = anchor?.userUuid;
    rewardTotal = anchor?.rewardTotal ?? 0;
    userName = anchor?.userName;
    icon = anchor?.icon;
  }

  NELivePKAnchor._fromActionAnchor(_NEActionAnchor? anchor) {
    userUuid = anchor?.userUuid;
    userName = anchor?.userName;
    rewardTotal = anchor?.rewardTotal ?? 0;
    icon = anchor?.icon;
    liveRecordId = anchor?.liveRecordId ?? 0;
  }

  NELivePKAnchor._fromPKInfoInviter(_NEPKInfoInviter? pkUser) {
    userName = pkUser?.userName;
    userUuid = pkUser?.userUuid;
    icon = pkUser?.icon;
    rewardTotal = pkUser?.rewardTotal ?? 0;
  }
}

class NELiveAnchorReward {
  String? userUuid;
  int pkRewardTotal = 0;
  int rewardTotal = 0;
  List<NELiveRewardTop>? pkRewardTop;

  List<String?>? get rewardIcons {
    return pkRewardTop?.map((e) => e.icon).toList();
  }

  NELiveAnchorReward._fromReward(_NEAnchorReward? reward) {
    userUuid = reward?.userUuid;
    pkRewardTotal = reward?.pkRewardTotal ?? 0;
    rewardTotal = reward?.rewardTotal ?? 0;
    pkRewardTop = reward?.pkRewardTop
        ?.map((e) => NELiveRewardTop._fromRewardTop(e))
        .toList();
  }
}

class NELiveRewardTop {
  String? userUuid;
  String? userName;
  String? icon;
  int rewardCoin = 0;

  NELiveRewardTop._fromRewardTop(_NEPkRewardTop? top) {
    userUuid = top?.userUuid;
    userName = top?.userName;
    icon = top?.icon;
    rewardCoin = top?.rewardCoin ?? 0;
  }
}

/// pk rule
class NELivePKRule {
  /// is control by system, 1 for true, 0 for false
  int? systemControl;

  /// PK game time
  int? pkGameTime;

  /// punishment time
  int? rewardsPunishmentsTime;

  /// tie time
  int? dogfallTime;
  
  /// pk invite timeout time 
  int? agreeTaskTime;

  Map toJson() {
    return {
      'systemControl': systemControl,
      'pkGameTime': pkGameTime,
      'rewardsPunishmentsTime': rewardsPunishmentsTime,
      'dogfallTime': dogfallTime,
      'agreeTaskTime': agreeTaskTime,
    };
  }
}
