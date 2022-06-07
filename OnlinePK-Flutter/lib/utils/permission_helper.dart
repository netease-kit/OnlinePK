// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../values/strings.dart';

enum ConfirmAction { cancel, accept }

class PermissionHelper {
  static Future<bool> requestPermissionSingle(
      BuildContext context, Permission permission, String title, String tips,
      {bool useDialog = true}) async {
    var status = await permission.status;
    var granted = status == PermissionStatus.granted;
    if (granted) return granted;
    if (useDialog) {
      final action = await showDialog<ConfirmAction>(
          context: context,
          builder: (BuildContext context) {
            return buildPermissionDialog(context, title, tips);
          });
      if (action == ConfirmAction.accept) {
        granted = await requestSingle(permission);
      }
    } else {
      granted = await requestSingle(permission);
    }
    return granted;
  }

  static CupertinoAlertDialog buildPermissionDialog(
      BuildContext context, String title, String tips) {
    return CupertinoAlertDialog(
      title: Text('${Strings.notWork}$tips'),
      content: Text(
          '${Strings.funcNeed}$tips,${Strings.needPermissionTipsFirst}$title${Strings.needPermissionTipsTail}$tips${Strings.permissionTips}？'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text(Strings.cancel),
          onPressed: () {
            Navigator.of(context).pop(ConfirmAction.cancel);
          },
        ),
        CupertinoDialogAction(
          child: const Text(Strings.toSetUp),
          onPressed: () {
            Navigator.of(context).pop(ConfirmAction.accept);
          },
        ),
      ],
    );
  }

  static Future<bool> requestSingle(Permission request) async {
    PermissionStatus status = await request.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return status == PermissionStatus.granted;
  }
}
