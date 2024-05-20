// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:examle/strings.dart';
import 'package:examle/widget/slider_widget.dart';
import 'package:nertc_faceunity/nertc_faceunity.dart';
import 'package:flutter/material.dart';
import 'package:nertc_core/nertc_core.dart';
import 'colors.dart';
import 'config.dart';

class CallPage extends StatefulWidget {
  final String cid;
  final int uid;

  CallPage({Key? key, required this.cid, required this.uid});

  @override
  _CallPageState createState() {
    return _CallPageState();
  }
}

class _CallPageState extends State<CallPage>
    with NERtcChannelEventCallback, NERtcDeviceEventCallback {
  var _engine = NERtcEngine.instance;
  var _beautyEngine = NERtcFaceUnityEngine();
  List<_UserSession> _remoteSessions = [];
  _UserSession _localSession = _UserSession();
  var _faceUnityParams = NEFaceUnityParams();
  var _currentFilterNameKeyIndex = 0;
  @override
  void initState() {
    super.initState();
    _initRtcEngine();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('channelName:${widget.cid}'),
        ),
        body: buildCallingWidget(context),
      ),
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(true);
      },
    );
  }

  Widget buildCallingWidget(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(child: buildVideoViews(context)),
      _selectItem(),
    ]);
  }

  Widget _selectItem() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                _topBeautyTitle(),
                Spacer(),
                _topBeautyRightTitle(),
              ],
            ),
          ),
          Center(
            child: Container(
              height: 60,
              child: ListView.builder(
                  itemCount: filterNames.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildFilterName(index);
                  }),
            ),
          ),
          _buildBeautyItem(
              beautyType: Strings.filterLevel,
              level: _faceUnityParams.filterLevel,
              max: 1,
              onChange: (value) => {
                    _beautyEngine.setFilterLevel(value),
                    _faceUnityParams.filterLevel = value
                  }),
          _buildBeautyItem(
              beautyType: Strings.colorLevel,
              level: _faceUnityParams.colorLevel,
              max: 2,
              onChange: (value) => {
                    _beautyEngine.setColorLevel(value),
                    _faceUnityParams.colorLevel = value
                  }),
          _buildBeautyItem(
              beautyType: Strings.blurLevel,
              level: _faceUnityParams.blurLevel,
              max: 6,
              onChange: (value) => {
                    _beautyEngine.setBlurLevel(value),
                    _faceUnityParams.blurLevel = value
                  }),
          _buildBeautyItem(
              beautyType: Strings.eyeEnlarging,
              level: _faceUnityParams.eyeBright,
              max: 1,
              onChange: (value) => {
                    _beautyEngine.setEyeEnlarging(value),
                    _faceUnityParams.eyeBright = value
                  }),
          _buildBeautyItem(
              beautyType: Strings.cheekThinning,
              level: _faceUnityParams.cheekThinning,
              max: 1,
              onChange: (value) => {
                    _beautyEngine.setCheekThinning(value),
                    _faceUnityParams.cheekThinning = value
                  }),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget _topBeautyTitle() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 8),
      child: Align(
          alignment: Alignment.center,
          child: Text(
            Strings.beauty,
            style: TextStyle(
                color: UIColors.black_333333,
                fontSize: 16,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold),
          )),
    );
  }

  Widget _topBeautyRightTitle() {
    return GestureDetector(
      onTap: () {
        _faceUnityParams = NEFaceUnityParams();
        _currentFilterNameKeyIndex = 0;
        _beautyEngine.setMultiFUParams(_faceUnityParams);
        setState(() {});
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 8, right: 8),
        child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              Strings.resetBeauty,
              style: TextStyle(
                  color: UIColors.black_333333,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold),
            )),
      ),
    );
  }

  Widget _buildBeautyItem({
    required String beautyType,
    required double level,
    required double max,
    required Function(double value) onChange,
  }) {
    return Center(
      child: SliderWidget(
        beautyType: beautyType,
        onChange: onChange,
        level: level,
        max: max,
      ),
    );
  }

  Widget buildVideoViews(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 9 / 16,
            crossAxisSpacing: 2.0,
            mainAxisSpacing: 2.0),
        itemCount: _remoteSessions.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return buildVideoView(context, _localSession);
          } else {
            return buildVideoView(context, _remoteSessions[index - 1]);
          }
        });
  }

  Widget buildVideoView(BuildContext context, _UserSession session) {
    return Container(
      child: Stack(
        children: [
          session.renderer != null
              ? NERtcVideoView(
                  renderer: session.renderer!,
                )
              : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${session.uid}',
                style: TextStyle(color: Colors.red),
              )
            ],
          )
        ],
      ),
    );
  }

  void _initRtcEngine() async {
    _localSession.uid = widget.uid;
    NERtcOptions options = NERtcOptions(videoCaptureObserverEnabled: true);
    _engine
        .create(
            appKey: Config.APP_KEY,
            channelEventCallback: this,
            options: options)
        .then((value) =>
            _beautyEngine.create(beautyKey: Uint8List.fromList(Config.auth)))
        .then((value) => _initCallbacks())
        .then((value) => _initAudio())
        .then((value) => _initVideo())
        .then((value) => _initRenderer())
        .then((value) => _engine.joinChannel('', widget.cid, widget.uid));
  }

  Future<int?> _initCallbacks() async {
    _engine.deviceManager.setEventCallback(this);
    _engine.setEventCallback(this);
    return 0;
  }

  Future<int?> _initAudio() async {
    await _engine.enableLocalAudio(true);
    return _engine.setAudioProfile(
        NERtcAudioProfile.profileDefault, NERtcAudioScenario.scenarioDefault);
  }

  Future<int?> _initVideo() async {
    await _engine.enableLocalVideo(true);
    await _engine.enableDualStreamMode(true);
    NERtcVideoConfig config = NERtcVideoConfig();
    config.videoProfile = NERtcVideoProfile.hd720p;
    return _engine.setLocalVideoConfig(config);
  }

  Future<void> _initRenderer() async {
    _localSession.renderer =
        await NERtcVideoRendererFactory.createVideoRenderer();
    _localSession.renderer!.attachToLocalVideo();
    setState(() {});
  }

  void _releaseRtcEngine() {
    _engine.release();
    _beautyEngine.release();
  }

  void _leaveChannel() {
    _engine.enableLocalVideo(false);
    _engine.enableLocalAudio(false);
    _engine.stopVideoPreview();
    if (_localSession.renderer != null) {
      _localSession.renderer!.dispose();
      _localSession.renderer = null;
    }
    for (_UserSession session in _remoteSessions) {
      session.renderer?.dispose();
      session.renderer = null;
    }
    _engine.leaveChannel();
  }

  @override
  void dispose() {
    _leaveChannel();
    _releaseRtcEngine();
    super.dispose();
  }

  Future<void> setupVideoView(int uid, int maxProfile) async {
    NERtcVideoRenderer renderer =
        await NERtcVideoRendererFactory.createVideoRenderer();
    for (_UserSession session in _remoteSessions) {
      if (session.uid == uid) {
        session.renderer = renderer;
        session.renderer!.attachToRemoteVideo(uid);
        _engine.subscribeRemoteVideoStream(
            uid, NERtcRemoteVideoStreamType.high, true);
        break;
      }
    }
    setState(() {});
  }

  @override
  void onConnectionTypeChanged(int newConnectionType) {
    print('onConnectionTypeChanged->' + newConnectionType.toString());
  }

  @override
  void onDisconnect(int reason) {
    print('onDisconnect->' + reason.toString());
  }

  @override
  void onFirstAudioDataReceived(int uid) {
    print('onFirstAudioDataReceived->' + uid.toString());
  }

  @override
  void onFirstVideoDataReceived(int uid, int? streamType) {
    print('onFirstVideoDataReceived->' + uid.toString());
  }

  @override
  void onLeaveChannel(int result) {
    print('onLeaveChannel->' + result.toString());
  }

  @override
  void onUserAudioMute(int uid, bool muted) {
    print('onUserAudioMute->' + uid.toString() + ', ' + muted.toString());
  }

  @override
  void onUserAudioStart(int uid) {
    print('onUserAudioStart->' + uid.toString());
  }

  @override
  void onUserAudioStop(int uid) {
    print('onUserAudioStop->' + uid.toString());
  }

  @override
  void onUserJoined(int uid, NERtcUserJoinExtraInfo? joinExtraInfo) {
    print('onUserJoined->' + uid.toString());
    _UserSession session = _UserSession();
    session.uid = uid;
    _remoteSessions.add(session);
    setState(() {});
  }

  @override
  void onUserLeave(
      int uid, int reason, NERtcUserLeaveExtraInfo? leaveExtraInfo) {
    print('onUserLeave->' + uid.toString() + ', ' + reason.toString());
  }

  @override
  void onUserVideoMute(int uid, bool muted, int? streamType) {
    print('onUserVideoMute->' + uid.toString() + ', ' + muted.toString());
  }

  // @override
  // void onUserVideoProfileUpdate(int uid, int maxProfile) {
  //   print('onUserVideoProfileUpdate->' +
  //       uid.toString() +
  //       ', ' +
  //       maxProfile.toString());
  // }

  @override
  void onUserVideoStart(int uid, int maxProfile) {
    print('onUserVideoStart->' + uid.toString() + ', ' + maxProfile.toString());
    setupVideoView(uid, maxProfile);
  }

  Widget _buildFilterName(int index) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: RawMaterialButton(
        onPressed: () {
          _faceUnityParams.filterName = filterNames[index];
          _beautyEngine.setFilterName(_faceUnityParams.filterName);
          _currentFilterNameKeyIndex = index;
          setState(() {});
        },
        child: Text(filterNames[index]),
        // shape: CircleBorder(),
        // elevation: 1.0,
        fillColor:
            _currentFilterNameKeyIndex == index ? Colors.blue : Colors.grey,
      ),
    ));
  }

  @override
  void onAudioRecording(int code, String filePath) {
    // TODO: implement onAudioRecording
  }

  @override
  void onLocalPublishFallbackToAudioOnly(bool isFallback, int streamType) {
    // TODO: implement onLocalPublishFallbackToAudioOnly
  }

  @override
  void onMediaRelayReceiveEvent(int event, int code, String channelName) {
    // TODO: implement onMediaRelayReceiveEvent
  }

  @override
  void onMediaRelayStatesChange(int state, String channelName) {
    // TODO: implement onMediaRelayStatesChange
  }

  @override
  void onRemoteSubscribeFallbackToAudioOnly(
      int uid, bool isFallback, int streamType) {
    // TODO: implement onRemoteSubscribeFallbackToAudioOnly
  }

  @override
  void onJoinChannel(int result, int channelId, int elapsed, int uid) {
    // TODO: implement onJoinChannel
  }
}

class _UserSession {
  int? uid;
  NERtcVideoRenderer? renderer;
}
