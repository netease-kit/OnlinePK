// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///点击事件
class OnClickView extends StatefulWidget {
  final Widget child;
  final GestureTapCallback onTap;
  const OnClickView({Key? key, required this.onTap, required this.child})
      : super(key: key);

  @override
  _OnClickViewState createState() => _OnClickViewState();
}

class _OnClickViewState extends State<OnClickView> {
  static const int debounceDuration = 200;
  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _resetDebounceTimer();
      },
      child: widget.child,
    );
  }

  void _resetDebounceTimer() {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: debounceDuration), () {
      widget.onTap();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
