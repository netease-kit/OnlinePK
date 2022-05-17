// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netease_livekit/netease_livekit.dart';

import '../values/colors.dart';
import '../values/strings.dart';

class DialogUtils {
  static Future showCommonDialog(
      BuildContext context, String title, String content, VoidCallback cancelCallback, VoidCallback acceptCallback,
      {String cancelText = Strings.cancel,
        String acceptText = Strings.sure,
        bool canBack = true,
        bool isContentCenter = true}) {
    return showDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return WillPopScope(
            child: CupertinoAlertDialog(
              title: TextUtils.isEmpty(title) ? null : Text(title),
              content: Text(content, textAlign: isContentCenter ? TextAlign.center : TextAlign.left),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(cancelText),
                  onPressed: (){
                    Navigator.of(context).pop(); // close dialog
                    cancelCallback();
                  },
                  textStyle: const TextStyle(color: AppColors.color_666666),
                ),
                CupertinoDialogAction(
                  child: Text(acceptText),
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    acceptCallback();
                  },
                  textStyle: const TextStyle(color: AppColors.color_337eff),
                ),
              ],
            ),
            onWillPop: () async {
              return canBack;
            },
          );
        });
  }

  static Future showOneButtonCommonDialog(BuildContext context, String title, String content, VoidCallback callback,
      {String acceptText = Strings.iKnow, bool canBack = true, bool isContentCenter = true}) {

    return showDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return WillPopScope(
            child: CupertinoAlertDialog(
              title: TextUtils.isEmpty(title) ? null : Text(title),
              content: Text(content, textAlign: isContentCenter ? TextAlign.center : TextAlign.left),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(acceptText),
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    callback();
                  },
                ),
              ],
            ),
            onWillPop: () async {
              return canBack;
            },
          );
        });
  }

  static void showInvitePKDialog(BuildContext context, String userName, VoidCallback cancelCallback, VoidCallback acceptCallback,) {
    DialogUtils.showCommonDialog(
        context, Strings.invitePK, '${Strings.confirmInvitePKPre}$userName${Strings.confirmInvitePKTail}', () {
      cancelCallback();
    }, () {
      acceptCallback();
    },
        canBack: true,
        isContentCenter: true);
  }

  static void showEndLiveDialog(BuildContext context, String userName, VoidCallback cancelCallback, VoidCallback acceptCallback,) {
    DialogUtils.showCommonDialog(
        context, Strings.endLive, Strings.sureEndLive, () {
      cancelCallback();
    }, () {
      acceptCallback();
    },
        canBack: true,
        isContentCenter: true);
  }

  static void showEndPKDialog(BuildContext context, String userName, VoidCallback cancelCallback, VoidCallback acceptCallback,) {
    DialogUtils.showCommonDialog(
        context, Strings.endPK, Strings.stopPkDialogContent, () {
      cancelCallback();
    }, () {
      acceptCallback();
    },
        canBack: true,
        isContentCenter: true);
  }

  static Future<T?> showChildNavigatorDialog<T extends Object>(BuildContext context, Widget widgetPage){
    return showCupertinoDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return widgetPage;
        });
  }

  static Future<T?> showChildNavigatorPopup<T extends Object>(BuildContext context, Widget widgetPage){
    return showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return widgetPage;
        });
  }

  static commonShowCupertinoDialog(BuildContext context, String title,
      String content, VoidCallback cancelCallback, VoidCallback acceptCallback,
      {String sure = Strings.sure, String cancel = Strings.cancel , bool visi = true}) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return Visibility(
            visible: visi,
            child: CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  child: Text(cancel),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    cancelCallback();
                  },
                ),
                TextButton(
                  child: Text(sure),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    acceptCallback();
                  },
                ),
              ],
            ),
          );
        });
  }

  static commonShowOneChooseCupertinoDialog(BuildContext context, String title,
      String content, VoidCallback acceptCallback,
      {String sure = Strings.sure , bool visi = true}) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return Visibility(
            visible: visi,
            child: CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  child: Text(sure),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    acceptCallback();
                  },
                ),
              ],
            ),
          );
        });
  }
}
