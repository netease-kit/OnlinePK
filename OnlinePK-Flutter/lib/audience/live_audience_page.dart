// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:event_bus/event_bus.dart' as event;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livekit_pk/base/net_util.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_pk/audience/audience_log.dart';
import 'package:livekit_pk/audience/widget/physics.dart';
import 'package:livekit_pk/audience/single_audience_widget.dart';
import 'package:wakelock/wakelock.dart';
import 'package:netease_common/netease_common.dart';

import '../base/lifecycle_base_state.dart';
import '../utils/toast_utils.dart';
import '../values/strings.dart';

// audience page
class LiveAudiencePage extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const LiveAudiencePage({Key? key, required this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LiveAudiencePageState();
  }
}

class JoinRetEvent {
  final NEResult<String?> result;
  final int recordId;

  JoinRetEvent(this.result, this.recordId);
}

class _LiveAudiencePageState extends LifecycleBaseState<LiveAudiencePage>
    with WidgetsBindingObserver {
  late PageController _pageController;

  List<NELiveDetail> videoDataList = [];

  late NELiveDetail _liveItem;

  late List<NELiveDetail> _liveList;

  event.EventBus eventBus = event.EventBus();

  bool initRefresh = false;

  bool needWarnNoMore = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    AudienceLog.log("didChangeAppLifecycleState,state:" + state.name);
    if (state != AppLifecycleState.resumed) {}
  }

  @override
  void dispose() {
    AudienceLog.log("LiveAudiencePage dispose");
    NELiveKit.instance.leaveLive();
    WidgetsBinding.instance!.removeObserver(this);
    Wakelock.disable();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _liveItem = widget.arguments['item'] as NELiveDetail;
    _liveList = widget.arguments['liveList'] as List<NELiveDetail>;

    int initialPage = 0;
    for (var i = 0; i < _liveList.length; i++) {
      if (_liveItem.anchor?.userUuid == _liveList[i].anchor?.userUuid) {
        initialPage = i;
      }
    }

    /// join current live
    _joinLive(_liveItem);

    /// no more warn
    _pageController = PageController(initialPage: initialPage, keepPage: true);
    _pageController.addListener(() {
      handleNoMoreTips(_pageController.offset, _liveList.length);
    });

    videoDataList = _liveList;
    WidgetsBinding.instance!.addObserver(this);
  }

  _joinLive(NELiveDetail liveDetail) {
    NELiveKit.instance.leaveLive().then((value) {
      NELiveKit.instance.joinLive(liveDetail).then((value) {
        // joinRtc
        eventBus.fire(JoinRetEvent(value, liveDetail.live!.liveRecordId));
        setState(() {
          _scrollerEnable = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: NetUtil.globalNetWork == ConnectivityResult.none
          ? buildDialog()
          : buildBodyFunction(),
    );
  }

  Widget buildDialog() {
    return CupertinoAlertDialog(
      title: const Text('Network error'),
      content: const Text('Click sure to close the broadcast',
          textAlign: TextAlign.center),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text('Sure'),
          onPressed: () {
            Navigator.of(context).pop(); // close dialog
          },
        ),
      ],
    );
  }

  var _scrollerEnable = false;

  Widget buildBodyFunction() {
    if (videoDataList.length == 1) {
      return GestureDetector(
        onVerticalDragEnd: (details) =>
            ToastUtils.showToast(context, Strings.biz_live_no_more),
        child: SingleAudienceWidget(
          key: const Key('0'),
          liveDetail: liveOfIndex(0)!,
          eventBus: eventBus,
        ),
      );
    }

    return PageView.builder(
        physics: _scrollerEnable
            ? const QuickerScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: _onPageViewChange,
        scrollDirection: Axis.vertical,
        itemCount: videoDataList.length,
        itemBuilder: (context, i) {
          return SingleAudienceWidget(
            key: Key('$i'),
            liveDetail: liveOfIndex(i)!,
            eventBus: eventBus,
          );
        });
  }

  /// 获取指定index的player
  NELiveDetail? liveOfIndex(int index) {
    if (index < 0 || index > videoDataList.length - 1) {
      return null;
    }
    return videoDataList[index];
  }

  _onPageViewChange(int pageIndex) {
    setState(() {
      _scrollerEnable = false;
    });
    var live = liveOfIndex(pageIndex);
    if (live != null) {
      _joinLive(live);
    }
  }

  void handleNoMoreTips(double offset, int pageSize) {
    if (offset < 0 ||
        ((_pageController.page ?? 0) >= pageSize - 1 &&
            offset > (MediaQuery.of(context).size.height * (pageSize - 1)))) {
      if (needWarnNoMore) {
        ToastUtils.showToast(context, Strings.biz_live_no_more);
        needWarnNoMore = false;
      }
    } else {
      needWarnNoMore = true;
    }
  }
}
