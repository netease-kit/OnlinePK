// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:livekit_pk/values/asset_name.dart';
import 'package:livekit_pk/values/colors.dart';

import 'live_pk_timer_count_view.dart';

class LivePkGiftProcessView extends StatefulWidget {
  final ValueListenable<GiftModel> modelListener;
  final TimeDataController timeDataController;
  final ValueListenable<List<String?>?> leftIconListListener;
  final ValueListenable<List<String?>?> rightIconListListener;

  const LivePkGiftProcessView(
      {Key? key,
      required this.modelListener,
      required this.timeDataController,
      required this.leftIconListListener,
      required this.rightIconListListener})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LivePkGiftProcessView();
  }
}

class _LivePkGiftProcessView extends State<LivePkGiftProcessView> {
  TimeDataController get timeDataController => widget.timeDataController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: buildLivePkGiftProcessView(timeDataController),
    );
  }

  Widget buildLivePkGiftProcessView(TimeDataController _timeDataController) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Stack(
      children: <Widget>[
        Positioned(
          top: 1,
          left: 0,
          right: 0,
          height: 60,
          child: Column(
            children: <Widget>[
              ValueListenableBuilder<GiftModel>(
                valueListenable: widget.modelListener,
                builder: (context, value, widget) {
                  return Row(
                    children: <Widget>[
                      Expanded(
                        flex: value.selfGiftNum == 0 ? 1 : value.selfGiftNum,
                        child: Container(
                          height: 18,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              AppColors.color_ff00d2ff,
                              AppColors.color_ff0084ff,
                            ]),
                          ),
                          padding: const EdgeInsets.only(left: 8),
                        ),
                      ),
                      Expanded(
                        flex: value.otherGiftNum == 0 ? 1 : value.otherGiftNum,
                        child: Container(
                            height: 18,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                                AppColors.color_ffff0055,
                                AppColors.color_ffff00aa,
                              ]),
                            ),
                            child: Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.only(right: 8),
                            )),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(
                height: 1,
              ),
              SizedBox(
                height: 40,
                // color: Colors.blue,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        // width: 120,
                        height: 30,
                        // color: Colors.blueGrey,
                        child: ValueListenableBuilder<List<String?>?>(
                            valueListenable: widget.leftIconListListener,
                            builder: (context, value, widget) {
                              return ListView.builder(
                                itemCount: value?.length ?? 0,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  //TODO
                                  return getItemContainer(value, index);
                                },
                              );
                            }),
                      ),
                    ),
                    Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      // width: 62,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          AppColors.color_ffff0080,
                          AppColors.color_ff0095ff,
                        ]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: LivePKTimerCountView(
                        timeDataController: _timeDataController,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 30,
                        // color: Colors.greenAccent,
                        child: ValueListenableBuilder<List<String?>?>(
                            valueListenable: widget.rightIconListListener,
                            builder: (context, value, widget) {
                              return ListView.builder(
                                itemCount: value?.length ?? 0,
                                scrollDirection: Axis.horizontal,
                                reverse: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return getItemContainer(value, index);
                                },
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 1,
          left: 0,
          right: 0,
          height: 18,
          child: ValueListenableBuilder<GiftModel>(
            valueListenable: widget.modelListener,
            builder: (context, value, widget) {
              return Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.only(left: 8),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'our ' + value.selfGiftNum.toString(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                        child: Container(
                      alignment: Alignment.centerRight,
                      margin: const EdgeInsets.only(right: 8),
                      child: Text(
                        value.otherGiftNum.toString() + ' other',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                        ),
                      ),
                    )),
                  ),
                ],
              );
            },
          ),
        ),
        Positioned(
          top: 0,
          left: -10,
          right: -10,
          height: 20,
          // left: value.selfGiftNum * 1.0 / (value.selfGiftNum * 1.0 + value.otherGiftNum * 1.0) * width,
          child: ValueListenableBuilder<GiftModel>(
            valueListenable: widget.modelListener,
            builder: (context, value, widget) {
              return Row(
                children: <Widget>[
                  Expanded(
                    flex: value.selfGiftNum == 0 ? 1 : value.selfGiftNum,
                    child: Container(
                      // color: Colors.yellow,
                      height: 9,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                    width: 20,
                    // color: Colors.pink,
                    child: Image.asset(AssetName.iconLivePkStar),
                  ),
                  Expanded(
                    flex: value.otherGiftNum == 0 ? 1 : value.otherGiftNum,
                    child: Container(
                      // color: Colors.black,
                      height: 9,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget getItemContainer(List<String?>? imageUrls, int index) {
    return Stack(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              margin:
                  const EdgeInsets.only(top: 3, bottom: 3, left: 2, right: 2),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: ((imageUrls != null && imageUrls.isNotEmpty)
                      ? NetworkImage((imageUrls[index])!) as ImageProvider
                      : const AssetImage(AssetName.iconLiveStartPk)),
                ),
                color: Colors.yellow,
              ),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  side: const BorderSide(
                      width: 2, color: AppColors.color_ff0095ff),
                ),
                onPressed: () {},
                child: Container(),
              ),
            ),
          ],
        ),
        Positioned(
            left: 8,
            height: 12,
            width: 12,
            bottom: 0,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.color_ff0095ff,
              ),
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.white,
                ),
              ),
            )),
      ],
    );
  }
}

class GiftModel {
  late int _selfGiftNum = 0;

  int get selfGiftNum => _selfGiftNum;

  set selfGiftNum(int selfGiftNum) {
    _selfGiftNum = selfGiftNum;
  }

  late int _otherGiftNum = 0;

  int get otherGiftNum => _otherGiftNum;

  set otherGiftNum(int otherGiftNum) {
    _otherGiftNum = otherGiftNum;
  }

  GiftModel(this._selfGiftNum, this._otherGiftNum);
}
