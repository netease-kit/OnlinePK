// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_pk/service/auth/auth_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
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
  static const _tag = "_HomePageRouteState";
  late NELiveCallback _callback;
  late PageController _pageController;
  final List<int> _list = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _callback = NELiveCallback(loginKickOut: () {
      NavUtils.pushNamedAndRemoveUntil(context, RouterName.login);
    });
    NELiveKit.instance.addEventCallback(_callback);
    for (var i = 0; i < 1; i++) {
      _list.add(i);
    }
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
          children: <Widget>[buildHomePage(), buildSettingPage()],
        ),
        bottomNavigationBar: buildBottomAppBar());
  }

  BottomAppBar buildBottomAppBar() {
    return BottomAppBar(
        color: AppColors.white_15_ffffff,
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
              width: 250,
              height: 35,
              image: AssetImage(AssetName.iconHomePageLogo),
              fit: BoxFit.fill,
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
    );
  }

  Future _onRefresh() async {
    Alog.i(tag: _tag, content: 'did refresh action');
    return "";
  }

  Widget buildListViewItem(int index) {
    return GestureDetector(
        child: buildListViewDetail(),
        onTap: () {
          NELiveKit.instance.nickname = AuthManager().nickName;
          NavUtils.pushNamed(context, RouterName.liveListPage);
        });
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
          const SizedBox(
            width: 48,
            height: 48,
            child: Image(
              image: AssetImage(AssetName.iconHomePkLive),
              fit: BoxFit.fill,
            ),
          ),
          Container(
            width: 12,
          ),
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  Strings.homeListViewDetailText1,
                  style: TextStyle(color: AppColors.white, fontSize: 18),
                ),
                Container(
                  height: 8,
                ),
                const Text(
                  Strings.homeListViewDetailText2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

  Widget buildSettingPage() {
    /// name
    var personalName = AuthManager().nickName;

    ///iconImage
    var personalIconUrl = AuthManager().avatar;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: viewportConstraints.maxHeight,
        ),
        child: Container(
          color: AppColors.color_1a1a24,
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).padding.top,
              ),
              Container(
                height: 80,
                color: AppColors.color_191923,
                alignment: Alignment.center,
                child: buildTitle(Strings.settingTitle),
              ),
              Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  color: AppColors.white_10_ffffff,
                  height: 1),
              buildSettingItemPadding(),
              buildPersonMessageItem(personalIconUrl, personalName),
              buildSettingItemPadding(),
              buildSettingItem(
                  Strings.freeForTest,
                  () => {
                        _launchInWebViewOrVC(
                            'https://id.commsease.com/register?h=media&t=media&from=commsease%7Chttps%3A%2F%2Fcommsease.com%2Fen&clueFrom=overseas&locale=en_US&i18nEnable=true&referrer=https%3A%2F%2Fconsole.commsease.com')
                      }),
              buildSettingItem(Strings.about,
                  () => {NavUtils.pushNamed(context, RouterName.aboutView)},
                  needBottomLine: false),
            ],
          ),
        ),
      ));
    });
  }

  Future<void> _launchInWebViewOrVC(String url) async {
    if (!await launch(
      url,
      forceSafariVC: true,
      forceWebView: true,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $url';
    }
  }

  Container buildTitle(String title) {
    return Container(
      height: Dimen.titleHeight,
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
            color: AppColors.white,
            fontSize: TextSize.titleSize,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Container buildSettingItemPadding() {
    return Container(height: Dimen.globalPadding);
  }

  Widget buildPersonMessageItem(String? iconUrl, String? name) {
    return GestureDetector(
      onTap: () {
        NavUtils.pushNamed(context, RouterName.aboutLogoutView);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        height: 88,
        color: AppColors.white_10_ffffff,
        child: Row(
          children: <Widget>[
            //图片
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: iconUrl != null
                  ? Image.network(iconUrl)
                  : Image.asset(AssetName.iconAvatar),
            ),

            Container(
              width: 12,
            ),

            Text(
              name ?? 'name',
              style: const TextStyle(color: AppColors.white, fontSize: 20),
            ),

            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerRight,
                child: Image.asset(AssetName.iconHomeMenuArrow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSettingItem(String title, VoidCallback voidCallback,
      {bool needBottomLine = true}) {
    return GestureDetector(
      child: Container(
          height: Dimen.primaryItemHeight,
          color: AppColors.white_10_ffffff,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, color: AppColors.white)),
                      const Spacer(),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerRight,
                          // padding: EdgeInsets.only(right: 22),
                          child: Image.asset(AssetName.iconHomeMenuArrow),
                        ),
                      ),
                    ],
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
                ),
              ),
              (needBottomLine
                  ? Container(
                      padding: EdgeInsets.only(left: Dimen.globalPadding),
                      child: itemLine(),
                    )
                  : Container(
                      padding: EdgeInsets.only(left: Dimen.globalPadding),
                    )),
            ],
          )),
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
    NELiveKit.instance.removeEventCallback(_callback);
  }

  Widget line() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      color: AppColors.color_e8e9eb,
      height: 0.5,
    );
  }

  Widget itemLine() {
    return Container(
        margin: const EdgeInsets.only(left: 0, right: 0),
        color: AppColors.white_50_ffffff,
        height: 1);
  }
}
