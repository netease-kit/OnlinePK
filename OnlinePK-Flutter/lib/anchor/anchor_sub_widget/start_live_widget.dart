// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/config/app_config.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_sample/base/lifecycle_base_state.dart';
import 'package:livekit_sample/utils/dialog_utils.dart';
import 'package:livekit_sample/utils/loading.dart';
import 'package:livekit_sample/utils/toast_utils.dart';
import 'package:livekit_sample/values/asset_name.dart';
import 'package:livekit_sample/values/colors.dart';
import 'package:livekit_sample/values/strings.dart';
import 'package:livekit_sample/widgets/live_button.dart';
import 'package:livekit_sample/anchor/anchor_sub_widget/live_info_view.dart';
import 'faceunity/faceunity_beauty_setting_view.dart';
import 'faceunity/faceunity_filter_setting_view.dart';

class StartLiveArguments {
  StartLiveResult result;
  StartLiveArguments(this.result);
}

enum StartLiveResult {
  noPermission,
}

class StartLiveWidget extends StatefulWidget {
  final Function(NELiveDetail? live)? onCreateLiveOK;

  const StartLiveWidget({Key? key, this.onCreateLiveOK}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StartLiveWidgetState();
  }
}

class _StartLiveWidgetState extends LifecycleBaseState<StartLiveWidget> {
  String? _cover;
  String? _topic;
  bool _isFrontCamera = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
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
            top: 10 + MediaQuery.of(context).padding.top,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(AssetName.iconBack),
            ),
          ),
          Positioned(
            height: 24,
            width: 24,
            top: 10 + MediaQuery.of(context).padding.top,
            right: 20,
            child: GestureDetector(
              onTap: () {
                NELiveKit.instance.mediaController.previewRoom().then((value) {
                  _isFrontCamera = !_isFrontCamera;
                  value.data?.previewController.switchCamera();
                });
              },
              child: Image.asset(AssetName.iconCameraSwitch),
            ),
          ),
        ],
      ),
    );
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
      NELiveKit.instance
          .startLive(NEStartLiveParams(liveTopic: _topic!, liveType: NELiveRoomType.pkLiveEx, configId: AppConfig().configId, cover: _cover!, isFrontCamera: _isFrontCamera))
          .then((value) {
        LoadingUtil.hideLoading();
        if (value.isSuccess()) {
          if (widget.onCreateLiveOK != null) {
            widget.onCreateLiveOK!(value.data);
          }
        } else {
          // start live failed
          LoadingUtil.hideLoading();
          ToastUtils.showToast(context, 'start live failed, ${value.msg}');
          Navigator.pop(context);
        }
      });
    } else {
      LoadingUtil.hideLoading();
      ToastUtils.showToast(context, 'topic and cover should not be empty');
    }
  }

  @override
  void dispose() {
    LoadingUtil.hideLoading();
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
            AppColors.colorFf3d8dff,
            AppColors.colorFf204cff,
          ]),
        ),
        alignment: Alignment.center,
        child: const Text(
          Strings.startLiveRoom,
          style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              decoration: TextDecoration.none),
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
              child: const Image(
                image: AssetImage(AssetName.liveTip),
                height: 16,
                width: 16,
              ),
            ),
            const Expanded(
              child: Text(Strings.startLiveTip,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  )),
            )
          ],
        ));
  }

  buildToolButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GestureDetector(
          child: const LiveCircleButton(
              AssetName.liveBeauty, Strings.beautySetting),
          onTap: () => onOpenBeauty(),
        ),
        GestureDetector(
          child: const LiveCircleButton(
              AssetName.liveFilter, Strings.filterSetting),
          onTap: () => onOpenFilter(),
        )
      ],
    );
  }

  onOpenBeauty() {
    DialogUtils.showChildNavigatorPopup(
        context, const FaceUnityBeautySettingView());
  }

  onOpenFilter() {
    DialogUtils.showChildNavigatorPopup(
        context, const FaceUnityFilterSettingView());
  }
}
