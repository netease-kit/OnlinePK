// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livekit_pk/values/asset_name.dart';
import 'package:livekit_pk/values/colors.dart';

class LivePkEndPkButtonView extends StatefulWidget{
  final cancelCallback;

  const LivePkEndPkButtonView({Key? key, this.cancelCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _LivePkEndPkButtonView ();
  }

}

class _LivePkEndPkButtonView extends  State<LivePkEndPkButtonView>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return buildLivePkEndPkButtonView();
  }

  Widget buildLivePkEndPkButtonView() {
    return OutlinedButton(
      onPressed: () {
        widget.cancelCallback();
      },
      child: const Image(
        image: AssetImage(AssetName.iconLiveEndPk),
      ),
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        side: const BorderSide(width: 1, color: AppColors.white_50_ffffff),
        padding: const EdgeInsets.all(0),
      ),
    );
  }
}