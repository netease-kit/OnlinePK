// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_pk/anchor/anchor_sub_widget/beauty_setting_view.dart';
import 'package:livekit_pk/anchor/anchor_sub_widget/filter_setting_view.dart';
import 'package:livekit_pk/anchor/beauty_cache.dart';
import 'package:livekit_pk/anchor/start_live_arguments.dart';
import 'package:livekit_pk/base/lifecycle_base_state.dart';
import 'package:livekit_pk/nav/nav_utils.dart';
import 'package:livekit_pk/nav/router_name.dart';
import 'package:livekit_pk/utils/dialog_utils.dart';
import 'package:livekit_pk/utils/loading.dart';
import 'package:livekit_pk/utils/toast_utils.dart';
import 'package:livekit_pk/values/asset_name.dart';
import 'package:livekit_pk/values/colors.dart';
import 'package:livekit_pk/values/strings.dart';
import 'package:livekit_pk/widgets/live_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:netease_roomkit/netease_roomkit.dart';

import 'package:livekit_pk/anchor/anchor_sub_widget/live_info_view.dart';

class StartLivePageRoute extends StatefulWidget {
  const StartLivePageRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StartLivePageRouteState();
  }
}

class _StartLivePageRouteState extends LifecycleBaseState<StartLivePageRoute> {
  static const _tag = '_StartLivePageRouteState';
  NERtcVideoRenderer? renderer;
  NEPreviewRoomContext? _previewRoomContext;
  bool _isNotStartLiveYet = true;

  bool _isBackCamera = false;

  @override
  void initState() {
    super.initState();
    bool isAllGranted = true;
    _requestPermissions().then((value) {
      value.forEach((key, value) {
        if(value.isDenied || value.isPermanentlyDenied){
          Alog.e(tag: _tag, content: '${key.toString()} is denied');
          isAllGranted = false;
        }
      });
      if(isAllGranted){
        _startPreview();
      }else {
        NavUtils.pop(context, arguments: StartLiveArguments(StartLiveResult.noPermission));
      }
    });
  }

  Future<Map<Permission, PermissionStatus>> _requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.microphone,
        Permission.camera,
      ].request();
      return statuses;
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.camera,
      ].request();
      return statuses;
    }
  }

  void _startPreview() {
    NELiveKit.instance.mediaController.previewRoom().then((value) {
      initVideoView().then((value2) {
        _previewRoomContext = value.data;
        _previewRoomContext?.previewController.startBeauty().then((value) {
          _previewRoomContext?.previewController.enableBeauty(true).then((value) {
            BeautyCache().resetBeauty();
            BeautyCache().resetFilter();
            _previewRoomContext?.previewController.startPreview();
          });
        });
      });
    });
  }

  String? _cover;
  String? _topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              renderer == null ? Container() : NERtcVideoView(renderer!, fitType: NERtcVideoViewFitType.cover,),
              Positioned(
                left: 10,
                right: 10,
                bottom: 20,
                child: buildBottomView(),
              ),
              Positioned(
                  left: 10,
                  top: 100,
                  right: 10,
                  child: StartLiveInfoView(
                    onInfoChanged: (String? cover, String? topic) {
                      _cover = cover;
                      _topic = topic;
                    },
                  )),
              Positioned(
                  height: 24,
                  width: 24,
                  top: 10 +MediaQuery.of(context).padding.top ,
                  right: 20,
                  child: GestureDetector(
                    onTap: (){
                      _previewRoomContext?.previewController.switchCamera().then((value) => _isBackCamera = !_isBackCamera);
                    },
                    child: Image.asset(AssetName.iconCameraSwitch)

                    ,
                  )),
            ],
          ),
        ));
  }

  Future<void> initVideoView() async {
    renderer = await VideoRendererFactory.createVideoRenderer("");
    await renderer!.attachToLocalVideo();
    if (Platform.isAndroid) {
      renderer!.setMirror(true);
    }
    setState(() {});
  }

  Widget buildBottomView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        buildLiveTip(),
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: buildToolButtons(),
        ),
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: buildStartLiveButton(),
        ),
      ],
    );
  }

  void _startLive() async {
    LoadingUtil.showLoading();
    if (TextUtils.isNotEmpty(_topic) && TextUtils.isNotEmpty(_cover)) {
      _previewRoomContext?.previewController.stopPreview();
      NELiveKit.instance.stopLive();
      NELiveKit.instance.startLive(_topic!, NELiveRoomType.pkLiveEx, _cover!).then((value) {
        LoadingUtil.cancelLoading();
        if (value.isSuccess()) {
          _isNotStartLiveYet = false;
          NavUtils.popAndPushNamed(context, RouterName.anchorLivePageRoute,arguments:{'detail':value.data!, 'camera':_isBackCamera});
        } else {
          // start live failed
          _previewRoomContext?.previewController.startPreview();
          ToastUtils.showToast(context, 'start live failed, ${value.msg}');
        }
      });
    } else {
      ToastUtils.showToast(context, 'topic and cover should not be empty');
    }
  }

  @override
  void dispose() {
    LoadingUtil.cancelLoading();
    if (_isBackCamera) {
      NELiveKit.instance.mediaController.switchCamera().then((value) {
        renderer?.dispose();
        if(_isNotStartLiveYet){
          _previewRoomContext?.previewController.stopPreview();
        }
      });
    } else {
      renderer?.dispose();
      if (_isNotStartLiveYet) {
        _previewRoomContext?.previewController.stopPreview();
      }
    }
    super.dispose();
  }

  buildStartLiveButton() {
    return GestureDetector(
      onTap: () {
        _startLive();
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.only(left: 16, right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(colors: [
            AppColors.color_ff3d8dff,
            AppColors.color_ff204cff,
          ]),
        ),
        alignment: Alignment.center,
        child: const Text(
          Strings.startLive,
          style: TextStyle(color: AppColors.white, fontSize: 16, decoration: TextDecoration.none),
        ),
      ),
    );
  }

  buildLiveTip() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.5),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: const Image(image: AssetImage(AssetName.liveTip), height: 16, width: 16,),
          ),
          const Expanded(
            child: Text(Strings.startLiveTip,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                )),
          )
        ],
      )
    );
  }

  buildToolButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GestureDetector(
          child: LiveCircleButton(AssetName.liveBeauty, Strings.beautySetting),
          onTap: () => onOpenBeauty(),
        ),
        GestureDetector(
          child: LiveCircleButton(AssetName.liveFilter, Strings.filterSetting),
          onTap: () => onOpenFilter(),
        )

      ],
    );
  }

  onOpenBeauty() {
    DialogUtils.showChildNavigatorPopup(context, const BeautySettingView());
  }

  onOpenFilter() {
    DialogUtils.showChildNavigatorPopup(context, const FilterSettingView());
  }
}
