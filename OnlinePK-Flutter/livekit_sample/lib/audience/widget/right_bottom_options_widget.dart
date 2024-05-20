// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../base/lifecycle_base_state.dart';
import '../../values/asset_name.dart';

class RightBottomOptions extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onGift;

  const RightBottomOptions(
      {Key? key, required this.onClose, required this.onGift})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RightBottomOptionsState();
  }
}

class _RightBottomOptionsState extends LifecycleBaseState<RightBottomOptions> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: widget.onGift, // Image tapped
              child: Image.asset(
                AssetName.iconAudienceGift,
                fit: BoxFit.cover, // Fixes border issues
                width: 32.0,
                height: 32.0,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: GestureDetector(
                onTap: widget.onClose, // Image tapped
                child: Image.asset(
                  AssetName.iconRoomAudienceClose,
                  fit: BoxFit.cover, // Fixes border issues
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
