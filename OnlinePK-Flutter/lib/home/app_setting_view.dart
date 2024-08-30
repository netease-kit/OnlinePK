// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/nav/nav_utils.dart';
import 'package:livekit_sample/nav/router_name.dart';
import 'package:livekit_sample/service/auth/auth_manager.dart';
import 'package:livekit_sample/utils/toast_utils.dart';
import 'package:livekit_sample/values/asset_name.dart';
import 'package:livekit_sample/values/colors.dart';
import 'package:livekit_sample/values/dimem.dart';
import 'package:livekit_sample/values/strings.dart';
import 'package:livekit_sample/widgets/check_network_view.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:url_launcher/url_launcher.dart';

class AppSettingView extends StatelessWidget {
  const AppSettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.white_10Ffffff,
                  height: 1),
              buildSettingItemPadding(),
              buildPersonMessageItem(
                  context, AuthManager().avatar, AuthManager().nickName),
              buildSettingItemPadding(),
              buildSettingItem(Strings.checkNetwork, () {
                showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return const CheckNetworkWidget();
                    });
              }),
              buildSettingItem(Strings.uploadLog, () {
                NELiveKit.instance.uploadLog().then((value) => {
                      if (value.code == 0)
                        {ToastUtils.showToast(context, Strings.uploadSuccess)}
                      else
                        {ToastUtils.showToast(context, Strings.uploadFailed)}
                    });
              }),
              buildSettingItem(
                  Strings.freeForTest,
                  () => _launchInWebViewOrVC(
                      'https://id.commsease.com/register?h=media&t=media&from=commsease%7Chttps%3A%2F%2Fcommsease.com%2Fen&clueFrom=overseas&locale=en_US&i18nEnable=true&referrer=https%3A%2F%2Fconsole.commsease.com')),
              buildSettingItem(Strings.about,
                  () => NavUtils.pushNamed(context, RouterName.aboutPage),
                  needBottomLine: false),
            ],
          ),
        ),
      ));
    });
  }

  Widget buildPersonMessageItem(
      BuildContext context, String? iconUrl, String? name) {
    return GestureDetector(
      onTap: () {
        NavUtils.pushNamed(context, RouterName.userProfilePage);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        height: 88,
        color: AppColors.white_10Ffffff,
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

  Widget buildPersonItem(String title, VoidCallback voidCallback,
      {String titleTip = '', String arrowTip = ''}) {
    return GestureDetector(
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
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

  Container buildSettingItemPadding() {
    return Container(height: Dimen.globalPadding);
  }

  Container buildTitle(String title) {
    return Container(
      height: Dimen.titleHeight,
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
            color: AppColors.white,
            fontSize: TextSize.titleSize,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> _launchInWebViewOrVC(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
    )) {
      throw 'Could not launch $url';
    }
  }

  Widget itemLine() {
    return Container(
        margin: const EdgeInsets.only(left: 0, right: 0),
        color: AppColors.white_50Ffffff,
        height: 1);
  }
}
