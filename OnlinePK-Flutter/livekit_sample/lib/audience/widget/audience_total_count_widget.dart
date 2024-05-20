// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/nav/nav_utils.dart';
import 'package:livekit_sample/nav/router_name.dart';
import 'package:livekit_sample/pages/member_list_page.dart';
import 'package:livekit_sample/utils/dialog_utils.dart';

import '../../base/lifecycle_base_state.dart';
import '../../values/colors.dart';

class AudienceTotalCount extends StatefulWidget {
  final int memberNum;
  const AudienceTotalCount({Key? key, required this.memberNum})
      : super(key: key);

  @override
  State<AudienceTotalCount> createState() {
    return _AudienceTotalCountState();
  }
}

class _AudienceTotalCountState extends LifecycleBaseState<AudienceTotalCount> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 45,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        alignment: Alignment.bottomRight,
        decoration: BoxDecoration(
          color: AppColors.colorFf0C0C0D,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Text(
            widget.memberNum.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.white, fontSize: 12),
          ),
        ),
      ),
      onTap: () {
        _showMember();
      },
    );
  }

  /// 从下往上显示
  void _showMember() {
    DialogUtils.showChildNavigatorPopup(context, const MemberListPage());
  }
}
