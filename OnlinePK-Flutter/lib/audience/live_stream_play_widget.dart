// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:math';
import 'dart:ui';
// import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:livekit_sample/audience/audience_log.dart';
import 'package:neliveplayer_core/neliveplayer.dart';
import 'package:netease_livekit/netease_livekit.dart';

final GlobalKey<_LiveStreamPlayWidgetState> liveStreamPlayWidgetKey =
    GlobalKey();

class LiveStreamPlayWidget extends StatefulWidget {
  final NELiveDetail liveDetail;
  final VoidCallback? playNormal;
  final VoidCallback? playError;

  const LiveStreamPlayWidget({
    Key? key,
    required this.liveDetail,
    required this.playNormal,
    required this.playError,
  }) : super(key: key);

  @override
  _LiveStreamPlayWidgetState createState() => _LiveStreamPlayWidgetState();
}

class _LiveStreamPlayWidgetState extends State<LiveStreamPlayWidget> {
  static const _tag = '_LiveStreamPlayWidgetState';
  NELivePlayer? player;

  // final FijkPlayer player = FijkPlayer();
  double videoWidth = 0;
  double videoHeight = 0;

  late NELiveCallback _callback;

  //single anchor live stream layout
  final int signalHostLiveWidth = 720;
  final int signalHostLiveHeight = 1280;
  Size _playerSize = const Size(720, 1280);

  //页面开始渲染的时间戳
  int pageBeginTimeMillis = 0;

  // 首屏渲染时间
  int cost = 0;

  // 当前是否已经收到首帧画面
  bool isPlaying = false;

  _LiveStreamPlayWidgetState();

  void reset() {
    // player.reset();
    player?.release();
  }

  //关闭播放主播的流
  void isClose(bool isClose) {
    AudienceLog.log("isClose=$isClose");
    if (isClose) {
      setState(() {
        player?.stop();
        reset();
      });
    } else {
      reconnect();
    }
  }

  void reconnect() {
    reset();
    final pullRtmpUrl = widget.liveDetail.live?.liveInfo?.pullRtmpUrl;
    if (TextUtils.isNotEmpty(pullRtmpUrl)) {
      player?.setPlayerUrl(pullRtmpUrl!);
      player?.setShouldAutoplay(true);
    } else {
      AudienceLog.log('pullRtmpUrl is empty');
    }
  }

  @override
  void initState() {
    pageBeginTimeMillis = currentTimeMillis();
    AudienceLog.log('initState');
    if (Platform.isIOS) {
      //todo ios neliveplayer
      // player.setOption(FijkOption.playerCategory, "videotoolbox", 0);
    }
    super.initState();
    _callback = NELiveCallback();
    NELiveKit.instance.addEventCallback(_callback);

    NELivePlayer.create(
      onPreparedListener: () {
        AudienceLog.log('listener onPrepared');
        player?.start();
      },
      onFirstAudioDisplayListener: () {
        AudienceLog.log('listener onFirstAudioDisplay');
      },
      onFirstVideoDisplayListener: () {
        AudienceLog.log('listener onFirstVideoDisplay');
        cost = currentTimeMillis() - pageBeginTimeMillis;
        AudienceLog.log("video render cost:" + cost.toString());
        isPlaying = true;
        refreshUI();
      },
      onLoadStateChangeListener: (type, extra) {
        AudienceLog.log(
            'listener onLoadStateChange type = $type extra = $extra');
      },
      onVideoSizeChangedListener: (width, height) {
        AudienceLog.log(
            'listener onVideoSizeChanged width = $width height = $height');
        _playerSize = Size(width.toDouble(), height.toDouble());
        setState(() {});
        changeVideoState();
      },
      onErrorListener: (what, extra) {
        AudienceLog.log('listener onError what = $what extra = $extra');
        if (mounted) {
          setState(() {
            widget.playError?.call();
          });
        }
      },
    ).then((value) {
      setState(() {
        player = value;
      });
      player?.setBufferStrategy(PlayerBufferStrategy.nelpFluent);
      // // 设置硬解码
      // player?.setHardwareDecoder(true);
      final pullRtmpUrl = widget.liveDetail.live?.liveInfo?.pullRtmpUrl;
      if (TextUtils.isNotEmpty(pullRtmpUrl)) {
        var config = NEAutoRetryConfig(count: 3, delayDefault: 10 * 1000);
        player?.setAutoRetryConfig(config);
        player?.setPlayerUrl(pullRtmpUrl!);
        player?.setShouldAutoplay(true);
        player?.prepareAsync();
      } else {
        AudienceLog.log("pullRtmpUrl is empty");
      }
    });

    //   player.addListener(() {
    //     Alog.d(tag: _tag, content: 'listener $videoWidth $videoHeight');
    //     AudienceLog.log(_tag + "player.state:${player.state}");
    //     if (player.state == FijkState.error) {
    //       if (mounted) {
    //         setState(() {
    //           widget.playError?.call();
    //         });
    //       }
    //     } else {
    //       widget.playNormal?.call();
    //     }
    //     changeVideoState();
    //   });
  }

  void changeVideoState() {
    Size size = _playerSize;
    AudienceLog.log(
        _tag + "changeVideoState,width:${size.width},height:${size.height}");
    bool sizeChanged = false;
    if (videoWidth != size.width) {
      videoWidth = size.width;
      sizeChanged = true;
    }
    if (videoHeight != size.height) {
      videoHeight = size.height;
      sizeChanged = true;
    }
    AudienceLog.log(_tag + "changeVideoState,sizeChanged:$sizeChanged");
    if (sizeChanged) {
      onVideoSizeChanged(videoWidth, videoHeight);
    }
  }

  void onVideoSizeChanged(double videoWidth, double videoHeight) {
    AudienceLog.log('onVideoSizeChanged $videoWidth $videoHeight');
    if (isSingleAnchorSize(videoWidth, videoHeight)) {
      AudienceLog.log(
          "canvas:PKState.single,time:" + currentTimeMillis().toString());
      refreshUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            getPlayerView(),
            _buildLoadingWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return AnimatedOpacity(
      opacity: isPlaying ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: Image(
              image: NetworkImage(widget.liveDetail.anchor?.icon ?? ''),
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Opacity(
                  opacity: 0.3,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void refreshUI() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget getPlayerView() {
    if (player == null) {
      AudienceLog.log("playId == null");
      return Container();
    } else {
      final Size size = _playerSize;
      // if (size == null) {
      //   AudienceLog.log("getPlayerView size == null");
      //   return Container();
      // }
      double viewWidth = 0;
      double viewHeight = 0;
      var videoWidth = size.width;
      var videoHeight = size.height;
      AudienceLog.log('videoWidth: $videoWidth ,videoHeight: $videoHeight');
      double scale = 1;
      viewWidth = MediaQuery.of(context).size.width;
      viewHeight = MediaQuery.of(context).size.height;
      var sx = viewWidth / videoWidth;
      var sy = viewHeight / videoHeight;
      scale = max(sx, sy);
      return Container(
        padding: const EdgeInsets.only(top: 0),
        color: Colors.black,
        child: Stack(
          children: [
            ClipRect(
                child: OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    alignment: Alignment.center,
                    child: FittedBox(
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        child: SizedBox(
                            width: videoWidth * scale,
                            height: videoHeight * scale,
                            child: NELivePlayerView(player: player!))))),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    NELiveKit.instance.removeEventCallback(_callback);
    reset();
  }

  bool isSingleAnchorSize(double videoWidth, double videoHeight) {
    if (videoWidth == 0 || videoHeight == 0) {
      return false;
    }
    return videoWidth / videoHeight ==
        signalHostLiveWidth / signalHostLiveHeight;
  }

  int currentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}
