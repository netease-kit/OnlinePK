// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 主播麦位+观众麦位UI
class SeatWidget extends StatefulWidget {
  const SeatWidget({Key? key}) : super(key: key);

  @override
  State<SeatWidget> createState() => _SeatState();
}

class _SeatState extends State<SeatWidget> {
  static const String tag = "_SeatState";
  bool isAnchor = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // AnchorSeatWidget(),
        // AudiencesSeatWidget(),
      ],
    );
  }
}
