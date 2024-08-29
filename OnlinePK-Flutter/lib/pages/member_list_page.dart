// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:livekit_sample/values/colors.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:netease_roomkit_interface/netease_roomkit_interface.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MemberListPageState();
  }
}

class MemberListPageState extends State<MemberListPage> {
  MemberListPageState();
  static const _radius = 8.0;
  final int _pageSize = 20;
  List<NEChatroomMember> liveMemberList = [];
  int nextPageNum = 1;
  String? _lastMember;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    liveMemberList.clear();
    _getDataFromServer(null);
  }

  void _loadMoreData() {
    _getDataFromServer(_lastMember);
  }

  void _getDataFromServer(String? lastMember) {
    NELiveKit.instance
        .fetchChatroomMembers(
            NEChatroomMemberQueryType.kGuestDesc, _pageSize, lastMember)
        .then((value) {
      final data = value.data;
      if (data != null) {
        _lastMember = data.last.uuid;
        if (mounted) {
          setState(() {
            value.data?.forEach((element) {
              liveMemberList.add(element);
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    var padding = data.size.height * 0.15;
    return Card(
        margin: EdgeInsets.only(top: padding),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_radius),
            topRight: Radius.circular(_radius),
          ),
        ),
        child: Column(children: <Widget>[
          buildTitle(),
          Expanded(
            child: buildContent(),
          ),
        ]));
  }

  Widget buildTitle() {
    return const SizedBox(
      height: 48,
      child: Stack(
        children: <Widget>[
          Center(
            child: Text(
              '观众',
              style: TextStyle(
                  color: AppColors.black_333333,
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                  decoration: TextDecoration.none),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
          )
        ],
      ),
    );
  }

  Widget buildContent() {
    return EasyRefresh.custom(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: liveMemberList[index].avatar != null
                      ? NetworkImage(liveMemberList[index].avatar!)
                      : null,
                ),
                title: Text(liveMemberList[index].nick ?? ''),
                subtitle: Text(liveMemberList[index].uuid ?? ''),
              );
            },
            childCount: liveMemberList.length,
          ),
        ),
      ],
      footer: ClassicalFooter(
        loadText: 'Pull to load more',
        loadingText: 'Loading...',
        loadedText: 'Load completed',
        loadFailedText: 'Load failed',
        noMoreText: 'No more data',
        infoText: '',
        infoColor: Colors.black,
        textColor: Colors.black,
        enableHapticFeedback: false,
      ),
      onRefresh: () async {
        refreshData();
      },
      onLoad: () async {
        _loadMoreData();
      },
    );
  }
}
