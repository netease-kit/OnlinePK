// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import '../base/lifecycle_base_state.dart';
import '../nav/nav_utils.dart';
import '../nav/router_name.dart';
import '../values/asset_name.dart';
import '../values/colors.dart';
import '../values/dimem.dart';
import '../values/strings.dart';

class HomePageRoute extends StatefulWidget {
  const HomePageRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageRouteState();
  }
}

class _HomePageRouteState extends LifecycleBaseState<HomePageRoute> {
  late PageController _pageController;
  final List<int> _list = [];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 1; i++) {
      _list.add(i);
    }
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChange,
          allowImplicitScrolling: true,
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[buildHomePage(), buildSettingPage()],
        ),
        bottomNavigationBar: buildBottomAppBar());
  }

  BottomAppBar buildBottomAppBar() {
    return BottomAppBar(
        color: AppColors.white_15,
        child: Container(
            height: 88,
            decoration: const BoxDecoration(
              // color: AppColors.white_15,
              boxShadow: [
                BoxShadow(
                    color: AppColors.color_19000000,
                    offset: Offset(0, -2),
                    blurRadius: 2)
              ],
            ),
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
                Container(
                  height: 34,
                )
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

  Widget buildHomePage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetName.iconHomeBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(height: MediaQuery.of(context).padding.top),
          Container(
            height: 80,
            alignment: Alignment.center,
            child: const Image(
              image: AssetImage(AssetName.iconHomePageLogo),
              fit: BoxFit.contain,
            ),
          ),
          Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              color: AppColors.white_10_ffffff,
              height: 1),
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            height: 300,
            // color: Colors.red,
            child: buildListView(),
          ),
          // Expanded(
          // )
        ],
      ),
    );
  }

  Widget buildListView() {
    return Scrollbar(
      child: RefreshIndicator(
          child: ListView.builder(
            // scrollDirection: Axis.horizontal,//设置为水平布局
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return buildListViewItem(index);
              } else {
                return const Icon(Icons.add);
              }
            },
            itemCount: _list.length,
          ),
          onRefresh: _onRefresh //下拉刷新执行此方法
          ),
    );
  }

  Future _onRefresh() async {
    return "";
  }

  Widget buildListViewItem(int index) {
    return GestureDetector(
      child: buildListViewDetail(),
      onTap: () {
        NavUtils.pushNamed(context, RouterName.liveListPage);
      },
    );
  }

  Widget buildListViewDetail() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: AppColors.black_80,
        // border: new Border.all(color: ColorUtil.hexColor(0x38CFCF),width: 0.5),
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //图片
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: Image.asset(AssetName.iconHomePkLive),
            ),
          ),
          Container(
            width: 12,
          ),
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  Strings.homeListViewDetailText1,
                  style: TextStyle(color: AppColors.white),
                ),
                Text(
                  Strings.homeListViewDetailText2,
                  style: TextStyle(color: AppColors.white),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Image.asset(AssetName.iconHomeMenuArrow),
          ),
        ],
      ),
    );
  }

// 顶部视图
  Widget buildTopView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(AssetName.tabSetting),
        const Text('图片待填充',
            style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400)),
        const Text(
          ' | 实时音视频',
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

  Widget buildSettingPage() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: viewportConstraints.maxHeight,
        ),
        child: Container(
          color: AppColors.global_bg,
          child: Column(
            children: <Widget>[
              Container(color: Colors.white, height: 44),
              buildTitle(Strings.settingTitle),
              buildSettingItemPadding(),
              buildSettingItemPadding(),
              buildSettingItem(Strings.about, () => {}),
              Container(
                height: 22,
                color: AppColors.global_bg,
              ),
            ],
          ),
        ),
      ));
    });
  }

  Container buildTitle(String title) {
    return Container(
      color: Colors.white,
      height: Dimen.titleHeight,
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
            color: AppColors.black_222222,
            fontSize: TextSize.titleSize,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Container buildSettingItemPadding() {
    return Container(color: AppColors.global_bg, height: Dimen.globalPadding);
  }

  Widget buildSettingItem(String title, VoidCallback voidCallback,
      {String iconTip = ''}) {
    return GestureDetector(
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        child: Row(
          children: <Widget>[
            Text(title,
                style: const TextStyle(
                    fontSize: 16, color: AppColors.black_222222)),
            const Spacer(),
            iconTip == ''
                ? Container()
                : Text(iconTip,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.color_999999)),
            Container(
              width: 10,
            ),
          ],
        ),
      ),
      onTap: voidCallback,
    );
  }

  Widget buildPersonItem(String title, VoidCallback voidCallback,
      {String titleTip = '', String arrowTip = ''}) {
    return GestureDetector(
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        child: Row(
          children: <Widget>[
            Text(title,
                style: const TextStyle(
                    fontSize: 16, color: AppColors.black_222222)),
            titleTip == ''
                ? Container()
                : Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.only(
                        left: 8, top: 3, right: 8, bottom: 3),
                    color: AppColors.color_1a337eff,
                    child: Text(titleTip,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.color_337eff)),
                  ),
            const Spacer(),
            arrowTip == ''
                ? Container()
                : Text(
                    arrowTip,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.color_999999),
                  ),
            Container(
              width: 20,
            ),
          ],
        ),
      ),
      onTap: voidCallback,
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
  }

  Widget line() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      color: AppColors.color_e8e9eb,
      height: 0.5,
    );
  }
}
