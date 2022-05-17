// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'dart:math';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_pk/audience/audience_log.dart';
import 'package:yunxin_alog/yunxin_alog.dart';


GlobalKey<_LiveStreamPlayWidgetState> liveStreamPlayWidgetKey = GlobalKey();

enum PKState { pk, single, pkPrepare }

class LiveStreamPlayWidget extends StatefulWidget {

  VideoPKStateController pkStateController;
  NELiveDetail liveDetail;
  VoidCallback? playNormal;
  VoidCallback? playError;

  LiveStreamPlayWidget({
    Key? key,
    required this.liveDetail,
    required this.pkStateController,
    required this.playNormal,
    required this.playError,
  }) : super(key: key);

  @override
  _LiveStreamPlayWidgetState createState() => _LiveStreamPlayWidgetState();
}

class _LiveStreamPlayWidgetState extends State<LiveStreamPlayWidget> {
  static const _tag = '_LiveStreamPlayWidgetState';
  final FijkPlayer player = FijkPlayer();
  double videoWidth = 0;
  double videoHeight = 0;

  late NELiveCallback _callback;
  PKState _pkState = PKState.single;

  //single anchor live stream layout
  final int signalHostLiveWidth = 720;
  final int signalHostLiveHeight = 1280;

  //pk live stream layout
  final int pkLiveWidth = 360;
  final int pkLiveHeight = 640;

  bool _isPK = false;

  _LiveStreamPlayWidgetState();

  void reset() {
    player.reset();
  }

  void reconnect() {
    reset();
    player.setDataSource(widget.liveDetail.live!.liveInfo!.rtmpPullUrl!, autoPlay: true);
  }


  @override
  void initState() {
    player.setDataSource(widget.liveDetail.live!.liveInfo!.rtmpPullUrl!, autoPlay: true);
    super.initState();
    widget.pkStateController.switchPK = switchPK;
    widget.pkStateController.switchPkEnd = switchPkEnd;
    _callback = NELiveCallback(
        pkStart: (int pkStartTime, int pkCountDown, NELivePKAnchor self,
            NELivePKAnchor peer) {
          _pkState = PKState.pkPrepare;
          refreshUI();
        }
    );
    NELiveKit.instance.addEventCallback(_callback);
    player.addListener(() {
      Alog.d(tag: _tag, content: 'listener $videoWidth $videoHeight');
      AudienceLog.log("player.state:${player.state}");
        if(player.state==FijkState.error){
            if(mounted){
              setState(() {
                  widget.playError?.call();
              });
            }
        }else{
          widget.playNormal?.call();
        }
      changeVideoState();
    });
  }

  void changeVideoState() {
    Size? size = player.value.size;
    bool sizeChanged = false;
    if (size != null && videoWidth != size.width) {
      videoWidth = size.width;
      sizeChanged = true;
    }
    if (size != null && videoHeight != size.height) {
      videoHeight = size.height;
      sizeChanged = true;
    }
    if (sizeChanged) {
      onVideoSizeChanged(videoWidth, videoHeight);
    }
  }

  void switchPK() {
    Alog.d(tag: _tag, content: 'switchPK');
    _isPK = true;
    onVideoSizeChanged(videoWidth, videoHeight);
  }
  void switchPkEnd() {
    Alog.d(tag: _tag, content: 'switchPkEnd');
    _isPK = false;
    onVideoSizeChanged(videoWidth, videoHeight);
  }

  void onVideoSizeChanged(double videoWidth, double videoHeight) {
    Alog.d(tag: _tag, content: 'onVideoSizeChanged $videoWidth $videoHeight');
    if (isPkSize(videoWidth, videoHeight)) {
      _pkState = PKState.pk;
      refreshUI();
    }
    if (isSingleAnchorSize(videoWidth, videoHeight)) {
      if (_isPK) {
        _pkState = PKState.pkPrepare;
      } else {
        _pkState = PKState.single;
      }
      refreshUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: getPlayerView(),
      ),
    );
  }

  void refreshUI() {
    if(mounted) {
      setState(() {});
    }
  }

  Widget getPlayerView() {
    if(player.value.prepared) {
      final Size? size = player.value.size;
      if(size == null) {
        AudienceLog.log("getPlayerView size == null");
        return Container();
      }
      double viewWidth = 0;
      double viewHeight = 0;
      Alog.d(tag: _tag, content: '_pkState $_pkState');
      var videoWidth = size.width;
      var videoHeight = size.height;
      double scale = 1;
      switch(_pkState) {
        case PKState.single:
          viewWidth = MediaQuery.of(context).size.width;
          viewHeight = MediaQuery.of(context).size.height;
          var sx = viewWidth / videoWidth;
          var sy = viewHeight / videoHeight;
          scale = max(sx, sy);
          break;
        case PKState.pkPrepare:
          viewWidth = MediaQuery.of(context).size.width / 2;
          viewHeight = MediaQuery.of(context).size.height / 2;
          var sx = viewWidth / videoWidth;
          scale = sx;
          break;
        case PKState.pk:
          viewWidth = MediaQuery.of(context).size.width;
          viewHeight = MediaQuery.of(context).size.height / 2;
          var sx = viewWidth / videoWidth;
          scale = sx;
          break;
      }
      double _height = 64 + MediaQuery.of(context).padding.top;
      return
        Container(
          padding: EdgeInsets.only(top: _pkState == PKState.single ? 0 :_height),
          color: Colors.black,
          child: ClipRect(
              child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  alignment: Alignment.topLeft,
                  child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                          width: videoWidth * scale,
                          height: videoHeight * scale,
                          child: FijkView(player:player)
                      )
                  )
              )
          ),
        );

    } else {
      AudienceLog.log("getPlayerView empty");
      return Container(
        color: Colors.black,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    NELiveKit.instance.removeEventCallback(_callback);
    reset();
  }

  bool isPkSize(double videoWidth, double videoHeight) {
    if (videoWidth == 0 || videoHeight == 0) {
      return false;
    }
    return videoWidth / videoHeight == pkLiveWidth * 2 / pkLiveHeight;
  }

  bool isSingleAnchorSize(double videoWidth, double videoHeight) {
    if (videoWidth == 0 || videoHeight == 0) {
      return false;
    }
    return videoWidth / videoHeight ==
        signalHostLiveWidth / signalHostLiveHeight;
  }
}

class VideoPKStateController {
  VoidCallback? switchPK;
  VoidCallback? switchPkEnd;

  void dispose() {
    switchPK = null;
    switchPkEnd = null;
  }
}

