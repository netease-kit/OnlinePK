// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// 页面适配
class ScreenUtils {
  static MediaQueryData _mediaQueryData = const MediaQueryData();
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double rpx = 0;
  static double px = 0;

  static void initialize(BuildContext context, {double standardWidth = 750}) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    rpx = screenWidth / standardWidth;
    px = screenWidth / standardWidth * 2;
  }

  // 按照像素来设置
  static double setPx(double size) {
    return ScreenUtils.rpx * size * 2;
  }

  // 按照rxp来设置
  static double setRpx(double size) {
    return ScreenUtils.rpx * size;
  }

  /// 获取屏幕宽度
  static double setWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 获取屏幕宽度
  static double setheight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
