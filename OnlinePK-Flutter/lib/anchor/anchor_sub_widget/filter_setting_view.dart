// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livekit_pk/anchor/beauty_cache.dart';
import 'package:livekit_pk/values/asset_name.dart';
import 'package:livekit_pk/values/colors.dart';
import 'package:livekit_pk/values/strings.dart';
import 'package:livekit_pk/widgets/filter_button.dart';
import 'package:livekit_pk/widgets/slider_widget.dart';
import 'package:path_provider/path_provider.dart';

class FilterSettingView extends StatefulWidget {
  final tapCallBack;

  const FilterSettingView({Key? key, this.tapCallBack}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FilterSettingState();
  }
}

class _FilterSettingState extends State<FilterSettingView> {
  final Radius _radius = const Radius.circular(8);

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
              side: const BorderSide(color: AppColors.global_bg),
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
                setState(() {
                  BeautyCache().resetFilter();
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildBeautySettingWidget() {
    return Column(children: [
      Container(
        height: 46,
        alignment: Alignment.center,
        child: SliderWidget(
            title: Strings.beautySaturation,
            onChange: (value) {
              BeautyCache().filterValue = value;
            },
            level: BeautyCache().filterValue,
            isShowClose: false),
      ),
      Container(
        height: 8,
      ),
      SizedBox(
        height: 46,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: BeautyCache().filters.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Container(
                    alignment: Alignment.center,
                    width: 70,
                    height: 70,
                    child: FilterButton(
                        AssetName.iconBeautyOriginal, Strings.filterOriginal,
                        () {
                      setState(() {
                        BeautyCache().removeBeautyFilter();
                      });
                    }, false));
              } else {
                var model = BeautyCache().filters[index - 1];
                return Container(
                    alignment: Alignment.center,
                    width: 70,
                    height: 70,
                    child: FilterButton(model.icon, model.name, () {
                      BeautyCache().removeBeautyFilter();
                      setState(() {
                        model.isSelected = true;
                      });
                    }, model.isSelected));
              }
            }),
      )
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
}
