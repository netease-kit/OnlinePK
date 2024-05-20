// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'neliveplayer_player.dart';

class NELivePlayerView extends StatefulWidget {
  final NELivePlayer player;

  NELivePlayerView({Key? key, required this.player}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LivePlayerViewState();
}

class _LivePlayerViewState extends State<NELivePlayerView> {
  Widget _buildVideoView() {
    String viewType = 'platform_video_view';

    Map<String, String> param = Map();
    param['playerId'] = widget.player.playerId;
    if (Platform.isAndroid &&
        widget.player.textureIdAndroid?.isNotEmpty == true) {
      int textureId = int.parse(widget.player.textureIdAndroid!);
      return Texture(textureId: textureId);
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        creationParams: param,
        creationParamsCodec: StandardMessageCodec(),
      );
    } else {
      return Text('not support');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildVideoView();
  }
}
