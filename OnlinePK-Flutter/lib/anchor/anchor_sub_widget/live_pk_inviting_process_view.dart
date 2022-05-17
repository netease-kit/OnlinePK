// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:livekit_pk/values/colors.dart';

class LivePKInvitingProcessView extends StatefulWidget{
  final connectName;
  final cancelCallback;
  const LivePKInvitingProcessView({Key? key, this.connectName, this.cancelCallback}) : super(key: key);

  @override
  State<LivePKInvitingProcessView> createState() {
    return _livePKInvetingProcessView();
  }
}

class _livePKInvetingProcessView extends State<LivePKInvitingProcessView>{

  @override
  Widget build(BuildContext context) {
    return buildContentView();
  }

  Widget buildContentView() {
    String name =  widget.connectName;
    if (name.length <= 0){
      name = "";
    }else{
      if(name.length > 20){
        name=name.substring(0,19);
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.color_66000000
      ),
      child:  Row(
        children: <Widget>[
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              'Invite"' + name + '" to PK...',
              style: const TextStyle(fontSize: 14,color: Colors.white),
            ),
            flex: 1,
          ),
          Container(
            height: 28,
            width: 50,
            decoration:
            BoxDecoration(
                gradient: const LinearGradient(colors: [
                  AppColors.color_fffa555f,
                  AppColors.color_ffd846f6,
                ]), // 渐变色
                borderRadius: BorderRadius.circular(4)),
            child:ElevatedButton(
              onPressed: (){
                widget.cancelCallback();
              },
              child: const Text('cancel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                ),),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  shadowColor:MaterialStateProperty.all(Colors.transparent),
              ),

            ),
          ),
          const SizedBox(
            width: 12,
          ),
        ],
      ),
    );
  }

}


