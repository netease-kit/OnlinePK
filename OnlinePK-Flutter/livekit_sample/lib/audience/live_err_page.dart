// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';

import '../values/strings.dart';

enum LiveErrorType {
  kNetwork,
  kLiveEnd,
}

class AudienceLiveErrorPage extends StatefulWidget {
  final String imageUrl;
  final String nickname;
  final LiveErrorType errorType;
  final VoidCallback returnAction;
  final VoidCallback reconnectingAction;

  const AudienceLiveErrorPage({
    Key? key,
    required this.imageUrl,
    required this.nickname,
    required this.errorType,
    required this.returnAction,
    required this.reconnectingAction,
  }) : super(key: key);

  @override
  State<AudienceLiveErrorPage> createState() => _AudienceLiveErrorPageState();
}

class _AudienceLiveErrorPageState extends State<AudienceLiveErrorPage> {
  double get _top => MediaQuery.of(context).padding.top;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Image(
            image: NetworkImage(widget.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Opacity(
                opacity: 0.3,
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),
        ),
        Positioned(
            width: 100,
            height: 100,
            top: 72 + _top,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
            )),
        Positioned(
          top: 184 + _top,
          child: Text(
            widget.nickname,
            style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                decoration: TextDecoration.none),
          ),
        ),
        Positioned(
            top: 233 + _top,
            child: Container(
              width: 240,
              height: 100,
              decoration: const BoxDecoration(
                  border: Border.symmetric(
                      horizontal: BorderSide(
                color: Color.fromRGBO(255, 255, 255, 0.1),
                width: 1,
                style: BorderStyle.solid,
              ))),
              child: Center(
                child: Text(
                  widget.errorType == LiveErrorType.kNetwork
                      ? Strings.liveOverLose
                      : Strings.liveOver,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      decoration: TextDecoration.none),
                ),
              ),
            )),
        Positioned(
          top: 390 + _top,
          child: widget.errorType == LiveErrorType.kNetwork
              ? buildMaterialButtons()
              : buildGestureTips(),
        )
      ],
    );
  }

  Column buildGestureTips() {
    return Column(
      children: [
        Container(
          width: 163,
          margin: const EdgeInsets.only(right: 4.5),
          child:
              buildMaterialButton(widget.returnAction, Strings.liveOverReturn),
        ),
        const Image(
          image: AssetImage('assets/images/3.0x/up_arrow_ico.png'),
          width: 20,
          height: 20,
        ),
        const Image(
            image: AssetImage('assets/images/3.0x/up_point_ico.png'),
            width: 48,
            height: 48),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: const Text(
            Strings.liveOverSwitch,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
            softWrap: true,
          ),
        ),
        const Image(
            image: AssetImage('assets/images/3.0x/down_arrow_ico.png'),
            width: 20,
            height: 20),
      ],
    );
  }

  Row buildMaterialButtons() {
    return Row(
      children: [
        Container(
          width: 163,
          margin: const EdgeInsets.only(right: 4.5),
          child:
              buildMaterialButton(widget.returnAction, Strings.liveOverReturn),
        ),
        Container(
          width: 163,
          margin: const EdgeInsets.only(left: 4.5),
          child: buildMaterialButton(
              widget.reconnectingAction, Strings.liveOverReconnect),
        ),
      ],
    );
  }

  MaterialButton buildMaterialButton(VoidCallback onPress, String text) {
    return MaterialButton(
      onPressed: onPress,
      height: 50,
      minWidth: 100,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.white, width: 1),
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
    );
  }
}
