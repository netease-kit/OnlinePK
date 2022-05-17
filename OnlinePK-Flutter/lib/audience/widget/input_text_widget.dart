// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../base/lifecycle_base_state.dart';
import '../../values/asset_name.dart';
import '../../values/colors.dart';

class InputTextWidget extends StatefulWidget {
  const InputTextWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InputTextWidgetState();
  }
}

class _InputTextWidgetState extends LifecycleBaseState<InputTextWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.color_ff0C0C0D,
        borderRadius: BorderRadius.circular(28),
      ),
      width: 175,
      height: 36,
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Image(
              image: AssetImage(AssetName.iconChatMsgInput),
              width: 16,
              height: 16,
            ),
            Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                "say something",
                style: TextStyle(color: AppColors.color_ccffffff, fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }
}
