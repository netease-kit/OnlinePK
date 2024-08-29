// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/values/strings.dart';
import 'package:netease_livekit/netease_livekit.dart';

import '../../base/lifecycle_base_state.dart';
import '../../values/colors.dart';
import '../audience_constant.dart';

// audience page anchor info ui
class AnchorInfoWidget extends StatefulWidget {
  final ValueNotifier<int> iconNumListener;
  final String anchorName;
  final String? anchorIcon;

  const AnchorInfoWidget(
      {Key? key,
      required this.anchorName,
      this.anchorIcon,
      required this.iconNumListener})
      : super(key: key);

  @override
  State<AnchorInfoWidget> createState() {
    return _AnchorInfoWidgetState();
  }
}

class _AnchorInfoWidgetState extends LifecycleBaseState<AnchorInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        decoration: BoxDecoration(
          color: AppColors.colorFf0C0C0D,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 40.0, top: 2.0, right: 15),
                  child: Text(
                    widget.anchorName,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    style:
                        const TextStyle(color: AppColors.white, fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0, top: 0, right: 15),
                  child: ValueListenableBuilder<int>(
                    valueListenable: widget.iconNumListener,
                    builder: (context, value, widget) {
                      return Text(
                        value.toString() + " " + Strings.coins,
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            color: AppColors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
              ],
            ),
            ClipOval(
              child: Image.network(
                TextUtils.isNotEmpty(widget.anchorIcon)
                    ? widget.anchorIcon!
                    : AudienceConstant.tmpAvatar,
                width: 36,
                height: 36,
              ),
            ),
          ],
        ));
  }
}
