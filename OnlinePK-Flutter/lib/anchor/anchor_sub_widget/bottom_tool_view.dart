// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/values/strings.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_sample/widgets/input_widget.dart';
import 'package:livekit_sample/values/asset_name.dart';
import 'package:livekit_sample/values/colors.dart';

class BottomTooView extends StatefulWidget {
  final Function tapCallBack;
  final void Function(String message) onSend;

  const BottomTooView(
      {Key? key, required this.tapCallBack, required this.onSend})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BottomTooView();
  }
}

class _BottomTooView extends State<BottomTooView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildContentView(),
    );
  }

  //build Content
  Widget buildContentView() {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        //输入框
        Expanded(
          flex: 2,
          child: buildInputView(),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Image.asset(AssetName.iconBottomToolBeauty),
                onTap: () {
                  widget.tapCallBack(1);
                },
              ),

              // GestureDetector(
              //   behavio
              //   r: HitTestBehavior.opaque,
              //   child: Image.asset(AssetName.iconBottomToolFilter),
              //   onTap: (){
              //     print('click click click');
              //     widget.tapCallBack(2);
              //   },
              // ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Image.asset(AssetName.iconBottomToolMusic),
                onTap: () {
                  widget.tapCallBack(2);
                },
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Image.asset(AssetName.iconBottomToolMore),
                onTap: () {
                  widget.tapCallBack(3);
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildInputView() {
    return Container(
      height: 36,
      // color: Colors.red,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18), color: AppColors.black_60),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 21,
          ),
          Image.asset(AssetName.iconLivingInput),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: GestureDetector(
              child: const Text(
                Strings.saySomething,
                style: TextStyle(fontSize: 14, color: AppColors.white),
              ),
              onTap: () {
                InputDialog.show(context).then((value) {
                  setState(() {
                    if (TextUtils.isNotEmpty(value)) {
                      widget.onSend(value!);
                    }
                    // _inputText = value.toString();
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget showInputView() {
    return const TextField(
      style: TextStyle(color: AppColors.white, fontSize: 14),
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent)),
        fillColor: Colors.red,
        labelStyle: TextStyle(color: AppColors.white, fontSize: 14),
        hintText: 'Enter a search term',
        hintStyle: TextStyle(
          color: AppColors.white_80Ffffff,
          fontSize: 14,
        ),
      ),
    );
  }
}
