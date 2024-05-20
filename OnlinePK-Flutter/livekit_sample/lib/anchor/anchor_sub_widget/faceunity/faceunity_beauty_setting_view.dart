// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/anchor/anchor_sub_widget/faceunity/slider_widget.dart';
import 'package:livekit_sample/values/asset_name.dart';
import 'package:livekit_sample/values/colors.dart';
import 'package:livekit_sample/values/strings.dart';

import 'faceunity_beauty_cache.dart';

class FaceUnityBeautySettingView extends StatefulWidget {
  final Function? tapCallBack;

  const FaceUnityBeautySettingView({Key? key, this.tapCallBack})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BeautySettingState();
  }
}

class _BeautySettingState extends State<FaceUnityBeautySettingView> {
  final Radius _radius = const Radius.circular(8);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 286,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: _radius, topRight: _radius)),
      child: buildContentView(),
    );
  }

  Widget title() {
    return Container(
      height: 48,
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.globalBg),
              borderRadius:
                  BorderRadius.only(topLeft: _radius, topRight: _radius))),
      child: Stack(
        children: <Widget>[
          const Align(
            alignment: Alignment.center,
            child: Text(
              Strings.beautySetting,
              style: TextStyle(
                  color: AppColors.black_333333,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  decoration: TextDecoration.none),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: RawMaterialButton(
              constraints:
                  const BoxConstraints(minWidth: 40.0, minHeight: 48.0),
              child: const Image(
                image: AssetImage(AssetName.liveReset),
                width: 20,
                height: 20,
              ),
              onPressed: () {
                FaceUnityBeautyCache().resetBeauty();
                setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildBeautySettingWidget() {
    return Column(
      children: [
        _buildBeautyItem(
            beautyType: Strings.colorLevel,
            level: FaceUnityBeautyCache().whiteningValue,
            max: 2,
            onChange: (value) =>
                {FaceUnityBeautyCache().whiteningValue = value}),
        _buildBeautyItem(
            beautyType: Strings.blurLevel,
            level: FaceUnityBeautyCache().peelingValue,
            max: 6,
            onChange: (value) => {FaceUnityBeautyCache().peelingValue = value}),
        _buildBeautyItem(
            beautyType: Strings.eyeEnlarging,
            level: FaceUnityBeautyCache().bigEyeValue,
            max: 1,
            onChange: (value) => {FaceUnityBeautyCache().bigEyeValue = value}),
        _buildBeautyItem(
            beautyType: Strings.cheekThinning,
            level: FaceUnityBeautyCache().thinFaceValue,
            max: 1,
            onChange: (value) =>
                {FaceUnityBeautyCache().thinFaceValue = value}),
      ],
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

  //build Content
  Widget buildContentView() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        title(),
        Container(
          height: 8,
        ),
        Material(
          color: Colors.white,
          child: buildBeautySettingWidget(),
        )
      ],
    );
  }
}
