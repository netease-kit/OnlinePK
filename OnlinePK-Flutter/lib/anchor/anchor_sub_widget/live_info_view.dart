// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_pk/service/repo/live_repo.dart';
import 'package:livekit_pk/values/asset_name.dart';

class StartLiveInfoView extends StatefulWidget {
  final Function(String? cover, String? topic)? onInfoChanged;

  const StartLiveInfoView({
    Key? key,
    required this.onInfoChanged,
  }) : super(key: key);

  @override
  _StartLiveInfoViewState createState() => _StartLiveInfoViewState();
}

class _StartLiveInfoViewState extends State<StartLiveInfoView> {
  final TextEditingController _textEditingController =
      TextEditingController(text: '');
  String _cover = '';
  String _topic = '';

  _default() {
    _refreshLiveCover();
    _refreshLiveTopic();
  }

  @override
  void initState() {
    super.initState();
    _default();
    _textEditingController.addListener(() {
      if (_topic != _textEditingController.text) {
        _topic = _textEditingController.text;
        if (widget.onInfoChanged != null) {
          widget.onInfoChanged!(_cover, _topic);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 110,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Stack(children: [
          Positioned(
            left: 10,
            top: 10,
            width: 90,
            height: 90,
            child: MaterialButton(
              padding: const EdgeInsets.all(0.0),
              child: Image(
                image: _cover.isEmpty ? const AssetImage('assets/images/3.0x/add_cover_ico.png') : NetworkImage(_cover) as ImageProvider,
              ),
              onPressed: () {
                _refreshLiveCover();
              },
            ),
          ),
          const Positioned(
            left: 90,
            top: 9,
            width: 10,
            height: 10,
            child:
                Image(image: AssetImage('assets/images/3.0x/refresh_ico.png')),
          ),
          Positioned(
            left: 110,
            top: 20,
            height: 90,
            right: 50,
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 2,
              maxLength: 40,
              decoration: const InputDecoration(border: InputBorder.none),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
              controller: _textEditingController,
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            width: 20,
            height: 20,
            child: MaterialButton(
              padding: const EdgeInsets.all(0.0),
              child: const Image(
                image: AssetImage('assets/images/3.0x/random_topic_ico.png'),
                color: Colors.white,
              ),
              onPressed: () {
                _refreshLiveTopic();
              },
            ),
          ),
        ]));
  }

  void _refreshLiveCover() {
    LiveRepo().getCover().then((value) {
      if (mounted) {
        var cover = value.data;
        if (_cover != cover) {
          setState(() {
            _cover = cover ?? '';
          });
          if (widget.onInfoChanged != null) {
            widget.onInfoChanged!(cover, _topic);
          }
        }
      }
    });
  }

  void _refreshLiveTopic(){
    LiveRepo().getTopic().then((value) {
      if(mounted) {
        var topic = value.data;
        if (_topic != topic) {
          setState(() {
            _textEditingController.text = topic ?? _topic;
          });
        }
      }
    });
  }
}
