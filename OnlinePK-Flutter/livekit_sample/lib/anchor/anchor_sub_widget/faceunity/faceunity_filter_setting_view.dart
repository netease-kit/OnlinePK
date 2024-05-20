// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/anchor/anchor_sub_widget/faceunity/faceunity_beauty_cache.dart';
import 'package:livekit_sample/anchor/anchor_sub_widget/faceunity/slider_widget.dart';

import 'package:livekit_sample/values/asset_name.dart';
import 'package:livekit_sample/values/colors.dart';
import 'package:livekit_sample/values/strings.dart';
import 'package:nertc_faceunity/nertc_faceunity.dart';

class FaceUnityFilterSettingView extends StatefulWidget {
  final Function? tapCallBack;

  const FaceUnityFilterSettingView({Key? key, this.tapCallBack})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FilterSettingState();
  }
}

class _FilterSettingState extends State<FaceUnityFilterSettingView> {
  final Radius _radius = const Radius.circular(8);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
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
              Strings.filterSetting,
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
                FaceUnityBeautyCache().resetFilter();
                setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildBeautySettingWidget() {
    return Column(children: [
      Center(
        child: SizedBox(
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
          level: FaceUnityBeautyCache().currentFilterLevel,
          max: 1,
          onChange: (value) =>
              {FaceUnityBeautyCache().currentFilterLevel = value}),
    ]);
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

  Widget _buildFilterName(int index) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: RawMaterialButton(
        onPressed: () {
          FaceUnityBeautyCache().currentFilterValue = index;
          setState(() {});
        },
        child: Text(filterNames[index]),
        // shape: CircleBorder(),
        // elevation: 1.0,
        fillColor: FaceUnityBeautyCache().currentFilterValue == index
            ? Colors.blue
            : Colors.grey,
      ),
    ));
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
}
