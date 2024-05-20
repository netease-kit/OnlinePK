// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/nav/nav_utils.dart';
import 'package:livekit_sample/values/asset_name.dart';
import 'package:livekit_sample/values/colors.dart';
import 'package:livekit_sample/values/dimem.dart';
import 'package:livekit_sample/values/strings.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutViewPage extends StatefulWidget {
  const AboutViewPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AboutViewRouteRouteState();
  }
}

class _AboutViewRouteRouteState extends State<AboutViewPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: _buildContentView(),
          onTap: () {}
          // _touchAreaClickCallback(),
          ),
    );
  }

  Widget _buildContentView() {
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
                child: buildTitle(Strings.about),
              ),
              itemLine(),
              SizedBox(
                height: 218,
                child: Image.asset(AssetName.iconAboutLogo),
              ),
              buildSystemSettingItem(Strings.appVersion, _packageInfo.version),
              buildSettingItemPadding(),
              buildSettingItem(
                  Strings.privacyPolicy,
                  () => _launchInWebViewOrVC(
                      'https://yunxin.163.com/clauses?serviceType=3')),
              buildSettingItem(Strings.termsOfService,
                  () => _launchInWebViewOrVC('https://yunxin.163.com/clauses')),
              buildSettingItem(
                  Strings.disclaimer,
                  () => _launchInWebViewOrVC(
                      'https://yunxin.163.com/clauses?serviceType=4'),
                  needBottomLine: false),
            ],
          ),
        ),
      ));
    });
  }

  Future<void> _launchInWebViewOrVC(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
    )) {
      throw 'Could not launch $url';
    }
  }

  Widget buildTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            NavUtils.pop(context);
          },
          child: Container(
            child: Image.asset(AssetName.iconBack),
            width: 24,
            margin: const EdgeInsets.only(left: 20),
          ),
        ),
        Container(
          height: Dimen.titleHeight,
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
                color: AppColors.white,
                fontSize: TextSize.titleSize,
                fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 20),
        ),
      ],
    );
  }

  Widget buildSystemSettingItem(String title, String subtitle) {
    return GestureDetector(
      child: Container(
          height: Dimen.primaryItemHeight,
          color: AppColors.white_10Ffffff,
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
                          child: Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 16, color: AppColors.white)),
                        ),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimen.globalPadding),
                ),
              ),
            ],
          )),
    );
  }

  Widget buildSettingItem(String title, VoidCallback voidCallback,
      {bool needBottomLine = true}) {
    return GestureDetector(
      child: Container(
          height: Dimen.primaryItemHeight,
          color: AppColors.white_10Ffffff,
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

                      // Icon(IconFont.iconyx_allowx, size: 14, color: AppColors.grey_cccccc)
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimen.globalPadding),
                ),
              ),
              (needBottomLine
                  ? Container(
                      padding: const EdgeInsets.only(left: Dimen.globalPadding),
                      child: itemLine(),
                    )
                  : Container(
                      padding: const EdgeInsets.only(left: Dimen.globalPadding),
                    )),
            ],
          )),
      onTap: voidCallback,
    );
  }

  Container buildSettingItemPadding() {
    return Container(height: Dimen.globalPadding);
  }

  Widget itemLine() {
    return Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        color: AppColors.white_10Ffffff,
        height: 1);
  }

  Future<void> _initPackageInfo() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }
}
