// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/nav/nav_utils.dart';
import 'package:livekit_sample/nav/router_name.dart';
import 'package:livekit_sample/service/auth/auth_manager.dart';
import 'package:livekit_sample/values/asset_name.dart';
import 'package:livekit_sample/values/colors.dart';
import 'package:livekit_sample/values/strings.dart';
import 'package:netease_livekit/netease_livekit.dart';

class AppEntranceView extends StatelessWidget {
  const AppEntranceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
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
              color: AppColors.white_10Ffffff,
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
            return buildListViewItem(context, index);
          } else {
            return const Icon(Icons.add);
          }
        },
        itemCount: 1,
      ),
    );
  }

  Widget buildListViewItem(BuildContext context, int index) {
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
}
