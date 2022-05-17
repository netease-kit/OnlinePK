// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_pk/values/asset_name.dart';
import 'package:livekit_pk/values/colors.dart';
import 'package:livekit_pk/values/strings.dart';
import 'package:livekit_pk/widgets/live_list.dart';

import '../../audience/live_header.dart';
import '../../utils/dialog_utils.dart';

class LivePkMemberInvitingView extends StatefulWidget {
  final clickPkCallback;

  const LivePkMemberInvitingView({Key? key, this.clickPkCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LivePkMemberInvitingView();
  }
}

class _LivePkMemberInvitingView extends State<LivePkMemberInvitingView> with LiveListDataMixin {
  var pageNum = 0;
  late EasyRefreshController _controller;

  void _loadDataCallback(List<NELiveDetail> liveInfoList, bool isRefresh) {
    setState(() {
      setDataList(liveInfoList, isRefresh);
    });
  }

  @override
  void initState() {
    _controller = EasyRefreshController();
    getLiveLists(true, _loadDataCallback);
  }

  @override
  Widget build(BuildContext context) {
    return buildContent();
  }

  Widget buildContent() {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          color: AppColors.white),
      child: Column(
        children: <Widget>[
          Container(
            height: 48,
            alignment: Alignment.center,
            child: const Text(
              Strings.invitingMemberToPk,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.black_333333,
              ),
            ),
          ),
          Container(
            color: AppColors.color_e6e7eb,
            height: 1,
          ),
          Expanded(
            flex: 1,
            child: EasyRefresh(
              controller: _controller,
              header: LiveListHeader(),
              footer: ClassicalFooter(),
              child: ListView.builder(
                  itemCount: liveList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return getItemContainer(liveList[index]);
                  }),
              onRefresh: () async {
                nextPageNum = 1;
                getLiveLists(true, _loadDataCallback);
              },
              onLoad: () async {
                if (haveMore) {
                  getLiveLists(true, _loadDataCallback);
                } else {
                  _controller.finishLoad(success: true, noMore: true);
                }
              },
              emptyWidget: liveList.length == 0
                  ? Container(
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(),
                            flex: 2,
                          ),
                          SizedBox(
                            width: 100.0,
                            height: 100.0,
                            child: Image.asset(AssetName.iconEmpty),
                          ),
                          const Text(
                            Strings.emptyLive,
                            style: TextStyle(
                                fontSize: 14.0, color: Color(0xff505065)),
                          ),
                          const Expanded(
                            child: SizedBox(),
                            flex: 3,
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // List<Widget> getWidgetList() {
  //   return list.map((item) => getItemContainer(item!)).toList();
  // }

  Widget getItemContainer(NELiveDetail item) {
    String name = (item.anchor?.userName ?? item.live!.userUuid).toString();
    if (name.length <= 0){
      name = "";
    }else{
      if(name.length > 20){
        name=name.substring(0,19);
      }
    }

    return Column(
      children: <Widget>[
        Container(
          height: 56,
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 20,
              ),
              Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                // child: Image.network(list[index].imageUrl),
                //TODO delete next Line
                child: (item.anchor?.icon != null && (item.anchor!.icon!.length > 0)) ? Image.network(item.anchor!.icon!): Image.asset(AssetName.iconAvatar),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 14,color: AppColors.black),
                      ),
                      Text(
                        Strings.invitingMemberAudienceCount +
                            ((item.live!.audienceCount > 10000)
                                ? ((item.live!.audienceCount / 10000)
                                        .toStringAsFixed(1) +
                                    '万')
                                : (item.live!.audienceCount.toString())),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.color_999999),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 71,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(colors: [
                    AppColors.color_fff359e2,
                    AppColors.color_ffff7272,
                  ]),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    widget.clickPkCallback(item);
                  },
                  child: const Text(
                    Strings.invitingMemberStartPK,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
              ),
              const SizedBox(
                width: 22,
              ),
            ],
          ),
        ),
        Container(
          child: Row(
            children: <Widget>[
              Container(
                width: 20,
              ),
              Expanded(
                child: Container(
                  color: AppColors.color_e6e7eb,
                  height: 1,
                ),
              ),
              Container(
                width: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
