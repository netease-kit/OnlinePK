// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livekit_pk/values/colors.dart';

class TimeDataValue {
  final String content;
  final int timerCount;
  TimeDataValue(this.content, this.timerCount);
}

class TimeDataController extends ValueNotifier<TimeDataValue> {
  TimeDataValue get timeDataValue => value;
  TimeDataController(TimeDataValue value) : super(value);
  setTimeDataValue(TimeDataValue timeData) {
    value = timeData;
  }
}

class LivePKTimerCountView extends StatefulWidget{
  final TimeDataController timeDataController;
  const LivePKTimerCountView({Key? key, required this.timeDataController}) : super(key: key);

  @override
  State<LivePKTimerCountView> createState() {
    return _LivePKTimerCountView();
  }

}


class _LivePKTimerCountView extends State<LivePKTimerCountView> {
  TimeDataController get timeDataController => widget.timeDataController;
  /// 倒计时的计时器。
  late Timer _timer;
  var _seconds;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _cancelTimer();
      }
      _seconds--;
      setState(() {});
      if (_seconds == 0) {
        _cancelTimer();
      }
    });
  }

  void _cancelTimer() {
    _timer.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelTimer();
  }
  @override
  void initState() {
    super.initState();
    _seconds = timeDataController.value.timerCount;
    if(_seconds > 0){
      startTimer();
    }
    timeDataController.addListener(() {
      if(timeDataController.value.timerCount > 0){
        if(mounted){
          _seconds = timeDataController.value.timerCount;
          _timer.cancel();
          startTimer();
        }
      }else{
        _timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildLivePKTimerCountView();
  }
  Widget _buildLivePKTimerCountView() {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        (timeDataController.value.content) + _durationTransform(_seconds),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
        ),
      ),
    );
  }

  //时间转换 将秒转换为小时分钟
  String _durationTransform(int seconds) {
     var min = seconds ~/ 60;
     var sec = seconds % 60;
     // DateFormat('MM/SS').format(DateTime.parse('${min}:${sec}'))

    // return DateFormat('hh:mm').format(DateTime.parse('2022-04-14T00:${min}:${sec}'));
    return'${min.toString().padLeft(2,'0')}:${sec.toString().padLeft(2,'0')}';
  }
}