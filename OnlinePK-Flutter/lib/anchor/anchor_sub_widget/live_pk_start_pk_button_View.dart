// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livekit_pk/nav/nav_utils.dart';
import 'package:livekit_pk/utils/dialog_utils.dart';
import 'package:livekit_pk/values/asset_name.dart';
import 'package:livekit_pk/values/strings.dart';

class LivePkStartPkButtonView extends StatefulWidget {
  final callback;

  const LivePkStartPkButtonView({Key? key, this.callback}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _LivePkStartPkButtonView();
  }
}

class _LivePkStartPkButtonView extends State<LivePkStartPkButtonView> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return buildLivePkButtonView();
  }

  Widget buildLivePkButtonView() {
    return GestureDetector(
      child: Container(
        child: OutlinedButton(
          onPressed: () {
            widget.callback();
          },
          child: Image(
            image: AssetImage(AssetName.iconLiveStartPk),
          ),
          style: OutlinedButton.styleFrom(
            shape: StadiumBorder(),
            // side: BorderSide(width: 1, color: AppColors.white_50_ffffff),
            padding: EdgeInsets.all(0),
          ),
        ),
      ),
      onTap: () {
        DialogUtils.showInvitePKDialog(context, "12345", () {}, () {});
      },
    );
  }

  void showInvitePKDialog(String userName) {
    DialogUtils.showCommonDialog(context, Strings.invitePK,
        '${Strings.confirmInvitePKPre}$userName${Strings.confirmInvitePKTail}',
        () {
      NavUtils.closeCurrentState('cancel');
    }, () {
      NavUtils.closeCurrentState('ok');
    }, canBack: true, isContentCenter: true);
  }
}
