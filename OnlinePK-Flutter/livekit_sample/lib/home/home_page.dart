// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/home/app_entrance_view.dart';
import 'package:livekit_sample/home/app_setting_view.dart';
import 'package:netease_livekit/netease_livekit.dart';
import '../../base/lifecycle_base_state.dart';
import '../../nav/nav_utils.dart';
import '../../nav/router_name.dart';
import '../../values/asset_name.dart';
import '../../values/colors.dart';
import '../../values/dimem.dart';

class HomePageRoute extends StatefulWidget {
  const HomePageRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageRouteState();
  }
}

class _HomePageRouteState extends LifecycleBaseState<HomePageRoute> {
  late NELiveCallback _callback;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _callback = NELiveCallback(loginKickOut: () {
      NavUtils.pushNamedAndRemoveUntil(context, RouterName.loginPage);
    });
    NELiveKit.instance.addEventCallback(_callback);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChange,
          allowImplicitScrolling: true,
          physics: const AlwaysScrollableScrollPhysics(),
          children: const <Widget>[AppEntranceView(), AppSettingView()],
        ),
        bottomNavigationBar: buildBottomAppBar());
  }

  BottomAppBar buildBottomAppBar() {
    return BottomAppBar(
        color: AppColors.white_15Ffffff,
        child: SizedBox(
            height: 54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    buildTabItem(
                        0,
                        _currentIndex == 0,
                        AssetName.iconHomeBottomMainSelect,
                        AssetName.iconHomeBottomMain),
                    buildTabItem(
                        1,
                        _currentIndex == 1,
                        AssetName.iconHomeBottomMineSelect,
                        AssetName.iconHomeBottomMine),
                  ],
                ),
              ],
            )));
  }

  Widget buildTabItem(
      int index, bool select, String selectAsset, String normalAsset) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _onTap(index);
      },
      child: Image.asset(select ? selectAsset : normalAsset,
          width: 130, height: 32),
    );
  }

  Widget buildTopView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(AssetName.tabSetting),
        const Text('',
            style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400)),
        const Text(
          ' | Real-time audio and video',
          style: TextStyle(color: AppColors.white, fontSize: 18),
        ),
        Container(
          width: 18,
        )
      ],
    );
  }

  Expanded buildItem(String assetStr, String text, VoidCallback voidCallback) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: voidCallback,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Image(
            //     image: AssetImage(assetStr, package: Packages.uiKit),
            //     width: Dimen.homeIconSize,
            //     height: Dimen.homeIconSize),
            Text(text,
                style: const TextStyle(
                    color: AppColors.black_222222,
                    fontSize: 14,
                    fontWeight: FontWeight.w400))
          ],
        ),
      ),
    );
  }

  void onPageChange(int value) {
    if (_currentIndex != value) {
      setState(() {
        _currentIndex = value;
      });
    }
  }

  void _onTap(int value) {
    _pageController.jumpToPage(value);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
    NELiveKit.instance.removeEventCallback(_callback);
  }

  Widget line() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      color: AppColors.colorE8e9eb,
      height: 0.5,
    );
  }
}
