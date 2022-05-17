// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livekit_pk/values/asset_name.dart';
import 'package:livekit_pk/values/colors.dart';
import 'package:livekit_pk/values/strings.dart';
import 'package:livekit_pk/widgets/slider_widget.dart';

import '../beauty_cache.dart';

class BeautySettingView extends StatefulWidget {
  final tapCallBack;

  const BeautySettingView({Key? key, this.tapCallBack}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BeautySettingState();
  }
}

class _BeautySettingState extends State<BeautySettingView> {
  final Radius _radius = const Radius.circular(8);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 286,
      decoration:
      BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: _radius, topRight: _radius)),
      child: buildContentView(),
    );
  }

  Widget title() {
    return Container(
      height: 48,
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.global_bg),
              borderRadius: BorderRadius.only(topLeft: _radius, topRight: _radius))),
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
              constraints: const BoxConstraints(minWidth: 40.0, minHeight: 48.0),
              child: const Image(
                image: AssetImage(AssetName.liveReset),
                width: 20,
                height: 20,
              ),
              onPressed: () {
                setState(() {
                  BeautyCache().resetBeauty();
                });
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
        Container(
          height: 46,
          alignment: Alignment.center,
          child: SliderWidget(
              title: Strings.beautyWhite,
              onChange: (value) {
                BeautyCache().whiteningValue = value;
              },
              level: BeautyCache().whiteningValue,
              isShowClose: false),
        ),
        Container(
          height: 46,
          alignment: Alignment.center,
          child: SliderWidget(
              title: Strings.beautySkin,
              onChange: (value) {
                BeautyCache().peelingValue = value;
              },
              level: BeautyCache().peelingValue,
              isShowClose: false),
        ),
        Container(
          height: 46,
          alignment: Alignment.center,
          child: SliderWidget(
              title: Strings.beautyFace,
              onChange: (value) {
                BeautyCache().thinFaceValue = value;
              },
              level: BeautyCache().thinFaceValue,
              isShowClose: false),
        ),
        Container(
          height: 46,
          alignment: Alignment.center,
          child: SliderWidget(
              title: Strings.beautyEye,
              onChange: (value) {
                BeautyCache().bigEyeValue = value;
              },
              level: BeautyCache().bigEyeValue,
              isShowClose: false),
        ),
      ],
    );
  }

  //build Content
  Widget buildContentView() {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        title(),
        Container(height: 8,),
        Material(
          color: Colors.white,
          child: buildBeautySettingWidget(),
        )
      ],
    );
  }
}
