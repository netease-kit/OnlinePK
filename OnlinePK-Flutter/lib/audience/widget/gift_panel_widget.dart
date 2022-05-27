// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_pk/nav/nav_utils.dart';
import 'package:livekit_pk/values/strings.dart';

import '../../base/lifecycle_base_state.dart';
import '../../values/asset_name.dart';
import '../../values/colors.dart';
import 'package:sprintf/sprintf.dart';

class GiftPanelWidget extends StatefulWidget {
  final void Function(GiftInfo giftInfo) onSend;

  const GiftPanelWidget({Key? key, required this.onSend}) : super(key: key);

  @override
  State<GiftPanelWidget> createState() {
    return _GiftPanelWidgetState();
  }
}

class _GiftPanelWidgetState extends LifecycleBaseState<GiftPanelWidget> {
  final Radius _radius = const Radius.circular(8);
  final _giftList = [
    GiftInfo(1, Strings.biz_live_glow_stick, 9, AssetName.gift01,
        AssetName.lottieGift01),
    GiftInfo(2, Strings.biz_live_arrange, 99, AssetName.gift02,
        AssetName.lottieGift02),
    GiftInfo(3, Strings.biz_live_sports_car, 199, AssetName.gift03,
        AssetName.lottieGift03),
    GiftInfo(4, Strings.biz_live_rockets, 999, AssetName.gift04,
        AssetName.lottieGift04),
  ];
  late GiftInfo _selectedGiftInfo;

  @override
  void initState() {
    super.initState();
    _selectedGiftInfo = _giftList[0];
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    // var padding = data.size.height * 0.6;
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: SizedBox(
        height: 238 + MediaQuery.of(context).padding.bottom,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.only(topLeft: _radius, topRight: _radius)),
            child: SafeArea(
              top: false,
              child: buildContentView(),
            ),
          ),
        ),
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
        buildAllGift(),
        buildSendGiftButton(),
      ],
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
        children: const <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text(
              Strings.sendGift,
              style: TextStyle(
                  color: AppColors.black_333333,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  decoration: TextDecoration.none),
            ),
          ),
        ],
      ),
    );
  }

  buildAllGift() {
    return Container(
        height: 100,
        margin: const EdgeInsets.only(left: 10),
        child: ListView.builder(
            padding: EdgeInsets.zero,
            primary: false,
            itemCount: _giftList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return buildGiftWidget(_giftList[index]);
            }));
  }

  buildGiftWidget(GiftInfo giftInfo) {
    return GestureDetector(
      child: Container(
          width: 72,
          height: 100,
          padding: const EdgeInsets.only(top: 10),
          decoration: isSelected(giftInfo)
              ? BoxDecoration(
                  border: Border.all(color: AppColors.color_ff337eff, width: 2),
                  // color: AppColors.color_ff337eff,
                  borderRadius: BorderRadius.circular((4.0)), // 圆角度
                  // borderRadius: const BorderRadius.vertical(top: Radius.elliptical(20, 50)),
                )
              : null,
          child: Column(
            children: [
              Image(
                width: 40,
                height: 40,
                image: AssetImage(giftInfo.img),
              ),
              Text(
                giftInfo.name,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.color_222222,
                ),
              ),
              Text(
                sprintf(Strings.biz_live_zero_coin, [giftInfo.coinCount]),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.color_666666,
                ),
              )
            ],
          )),
      onTap: () {
        setState(() {
          _selectedGiftInfo = giftInfo;
        });
      },
    );
  }

  buildSendGiftButton() {
    return GestureDetector(
      onTap: () {
        _sendGift();
      },
      child: Container(
        height: 44,
        margin: const EdgeInsets.only(left: 20, right: 20, top: 24),
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
          Strings.send,
          style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              decoration: TextDecoration.none),
        ),
      ),
    );
  }

  void _sendGift() {
    widget.onSend(_selectedGiftInfo);
    NavUtils.pop(context);
  }

  bool isSelected(GiftInfo giftInfo) {
    return _selectedGiftInfo.giftId == giftInfo.giftId;
  }
}

class GiftInfo {
  int giftId;
  String name;
  int coinCount;
  String img;
  String lottieAnimal;

  GiftInfo(this.giftId, this.name, this.coinCount, this.img, this.lottieAnimal);
}
