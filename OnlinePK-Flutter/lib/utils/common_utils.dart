// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:convert' as convert;
import 'dart:ui';
import 'package:flutter/cupertino.dart';

class CommonUtils {
  /// 获取设备类型 andorid 还是ios
  static int getDeviceType() {
    if (Platform.isAndroid) {
      return 1;
    } else if (Platform.isIOS) {
      return 2;
    } else {
      return 0;
    }
  }

  ///字符串是否为空 或者为null
  static bool isStrNullEmpty(String str) {
    return str == null || (str ?? "").isNotEmpty;
  }

  ///显示
  static String money$Symbol(String data) {
    if (isStrNullEmpty(data)) {
      return "\$$data";
    } else {
      return "\$0.00";
    }
  }

  static String base64Decode(String data) {
    List<int> bytes = convert.base64Decode(data);
    // 网上找的很多都是String.fromCharCodes，这个中文会乱码
    //String txt1 = String.fromCharCodes(bytes);
    String result = convert.utf8.decode(bytes);
    return result;
  }

  //时间戳转时分秒
  static String formatTimestamp(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedTime =
        "${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
    return formattedTime;
  }

  ///秒转时分秒
  static String formatDuration(int miao) {
    Duration duration = Duration(seconds: miao);
    int hours = duration.inHours;
    int minutes = (duration.inMinutes % 60);
    int seconds = (duration.inSeconds % 60);

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    return '$hoursStr:$minutesStr:$secondsStr';
  }

  static bool isJson(String str) {
    try {
      json.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 将 HEX 字符串转换为 Color 对象的函数
  static Color hexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// 版本号比较
  /// 前者等于后者则返回0  ==
  /// 如果前者大于后者，返
  ///  前者小于后者则返回-1
  /// compareTo()方法返回值为int类型，就是比较两个值，如：x.compareTo(y)。如果前者大于后者，返回1，前者等于后者则返回0，前者小于后者则返回-1
  static int compareVersion(String version1, String version2) {
    List<String> version1Array = version1.split(".");
    List<String> version2Array = version2.split(".");
    int len1 = version1Array.length;
    int len2 = version2Array.length;
    int lim = len1 < len2 ? len1 : len2;

    int i = 0;
    while (i < lim) {
      int c1 = version1Array[i] == "" ? 0 : int.parse(version1Array[i]);
      int c2 = version2Array[i] == "" ? 0 : int.parse(version2Array[i]);
      if (c1 != c2) {
        return c1 - c2;
      }
      i++;
    }
    return len1 - len2;
  }
}
