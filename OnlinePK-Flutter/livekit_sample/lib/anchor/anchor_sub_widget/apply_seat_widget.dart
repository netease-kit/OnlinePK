// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:livekit_sample/anchor/anchor_log.dart';
import 'package:livekit_sample/utils/common_utils.dart';
import 'package:livekit_sample/utils/loading.dart';
import 'package:livekit_sample/utils/screen_utils.dart';
import 'package:livekit_sample/utils/toast_utils.dart';
import 'package:livekit_sample/values/asset_name.dart';
import 'package:livekit_sample/values/colors.dart';
import 'package:livekit_sample/widgets/load_img.dart';
import 'package:netease_roomkit/netease_roomkit.dart';
import 'package:netease_roomkit_interface/netease_roomkit_interface.dart';

class ApplySeatView extends StatefulWidget {
  final String roomUuid;
  final String anchorId;

  const ApplySeatView({
    required this.roomUuid,
    required this.anchorId,
    Key? key,
  }) : super(key: key);

  @override
  State<ApplySeatView> createState() => _ApplySeatViewState();
}

class _ApplySeatViewState extends State<ApplySeatView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late List<String> listTab = ["申请成员", "麦上成员"];

  late List<NESeatRequestItem> applySeatData = [];
  late List<NESeatItem> onSeatData = [];
  late NERoomContext? roomContext;

  @override
  void initState() {
    super.initState();
    tabController =
        TabController(length: listTab.length, vsync: this, initialIndex: 0);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        if (tabController.index == 0) {
          getApplySeatData();
        } else {
          getOnSeatData();
        }
      }
    });
    getRoomContext();
  }

  void getRoomContext() async {
    roomContext =
        NERoomKit.instance.roomService.getRoomContext(widget.roomUuid);
    if (roomContext != null) {
      getApplySeatData();
    }
  }

  void getApplySeatData() async {
    if (roomContext != null) {
      final response = await roomContext!.seatController.getSeatRequestList();
      if (response.code == 0) {
        setState(() {
          applySeatData = response.data ?? [];
        });
      }
    }
  }

  void getOnSeatData() async {
    if (roomContext != null) {
      final response = await roomContext!.seatController.getSeatInfo();
      if (response.code == 0 && response.data != null) {
        List<NESeatItem> updateData = [];
        response.data!.seatItems?.forEach((element) {
          if (CommonUtils.isStrNullEmpty(element.user ?? "")) {
            updateData.add(element);
          }
        });
        setState(() {
          onSeatData.clear();
          onSeatData.addAll(updateData);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          _titleView(context),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                _applySeatView(context),
                _onSeatView(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _applySeatView(BuildContext context) {
    return applySeatData.isNotEmpty
        ? ListView.builder(
            itemCount: applySeatData.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _listItem(context, applySeatData[index]);
            },
          )
        : Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AssetName.iconEmpty,
                  width: 75,
                  height: 73,
                ),
                const Text(
                  "暂无申请成员",
                  style: TextStyle(
                    color: AppColors.color_999999,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
  }

  Widget _listItem(BuildContext context, NESeatRequestItem item) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: ScreenUtils.setPx(5), horizontal: ScreenUtils.setPx(10)),
      child: Row(
        children: [
          CustExtendedImage(
            url: item.icon ?? "",
            fit: BoxFit.cover,
            cache: false,
            shape: BoxShape.circle,
            height: ScreenUtils.setPx(38),
            width: ScreenUtils.setPx(38),
          ),
          SizedBox(
            width: ScreenUtils.setPx(10),
          ),
          Expanded(
            child: Text(
              (item.userName?.isNotEmpty == true)
                  ? item.userName!
                  : (item.user ?? ''),
              maxLines: 1,
              style: TextStyle(
                  color: AppColors.textDfColor,
                  fontSize: ScreenUtils.setPx(13),
                  fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: ScreenUtils.setPx(10),
          ),

          ///拒绝
          GestureDetector(
            onTap: () {
              roomContext?.seatController
                  .rejectSeatRequest(item.user!)
                  .then((value) {
                AnchorLog.log("拒绝连麦" + value.toString());
                getApplySeatData();
              });
            },
            child: Container(
              alignment: Alignment.center,
              width: ScreenUtils.setPx(60),
              height: ScreenUtils.setPx(30),
              decoration: BoxDecoration(
                color: AppColors.color_999999,
                borderRadius: BorderRadius.circular(ScreenUtils.setPx(15)),
              ),
              child: Text(
                "拒绝",
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: ScreenUtils.setPx(13),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SizedBox(
            width: ScreenUtils.setPx(10),
          ),

          ///同意
          GestureDetector(
            onTap: () {
              LoadingUtil.showLoading();
              roomContext?.seatController.getSeatInfo().then((value) {
                if (value.code == 0) {
                  if (value.data != null) {
                    if (value.data!.seatItems != null) {
                      var list = [];
                      value.data!.seatItems?.forEach((element) async {
                        if (CommonUtils.isStrNullEmpty(element.user ?? "")) {
                          list.add(element);
                        }
                      });
                      if (list.length >= 6) {
                        LoadingUtil.cancelLoading();
                        ToastUtils.showToast(context, "加入失败，当前连麦已满");
                      } else {
                        roomContext?.seatController
                            .approveSeatRequest(item.user!)
                            .then((value) {
                          AnchorLog.log("同意连麦" + value.toString());
                          getApplySeatData();
                          LoadingUtil.cancelLoading();
                        });
                      }
                    } else {
                      LoadingUtil.cancelLoading();
                      ToastUtils.showToast(context, "加入失败，请重试");
                    }
                  } else {
                    LoadingUtil.cancelLoading();
                    ToastUtils.showToast(context, "加入失败，请重试");
                  }
                } else {
                  LoadingUtil.cancelLoading();
                  ToastUtils.showToast(context, "加入失败，请重试");
                }
              });
            },
            child: Container(
              alignment: Alignment.center,
              width: ScreenUtils.setPx(60),
              height: ScreenUtils.setPx(30),
              decoration: BoxDecoration(
                color: AppColors.appMainColor,
                borderRadius: BorderRadius.circular(ScreenUtils.setPx(15)),
              ),
              child: Text(
                "同意",
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: ScreenUtils.setPx(13),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _onSeatView(BuildContext context) {
    return onSeatData.isNotEmpty
        ? ListView.builder(
            itemCount: onSeatData.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _wheatListItem(context, onSeatData[index]);
            },
          )
        : Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AssetName.iconEmpty,
                  width: 75,
                  height: 73,
                ),
                Text(
                  "麦上暂无成员",
                  style: TextStyle(
                    color: AppColors.color_999999,
                    fontSize: ScreenUtils.setPx(15),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
  }

  Widget _wheatListItem(BuildContext context, NESeatItem item) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtils.setPx(5),
        horizontal: ScreenUtils.setPx(10),
      ),
      child: Row(
        children: [
          CustExtendedImage(
            url: item.icon ?? "",
            fit: BoxFit.cover,
            cache: false,
            shape: BoxShape.circle,
            height: ScreenUtils.setPx(38),
            width: ScreenUtils.setPx(38),
          ),
          SizedBox(width: ScreenUtils.setPx(10)),
          Expanded(
            child: Text(
              item.userName ?? "",
              maxLines: 1,
              style: TextStyle(
                color: AppColors.textDfColor,
                fontSize: ScreenUtils.setPx(13),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: ScreenUtils.setPx(10)),
          Visibility(
            visible: widget.anchorId != item.user,
            child: GestureDetector(
              onTap: () {
                roomContext!.seatController.kickSeat(item.user!).then((value) {
                  getOnSeatData();
                });
              },
              child: Container(
                alignment: Alignment.center,
                width: ScreenUtils.setPx(60),
                height: ScreenUtils.setPx(30),
                decoration: BoxDecoration(
                  color: AppColors.appMainColor,
                  borderRadius: BorderRadius.circular(ScreenUtils.setPx(15)),
                ),
                child: Text(
                  "踢下麦",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: ScreenUtils.setPx(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleView(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: TabBar(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        indicatorPadding: EdgeInsets.zero,
        dividerHeight: ScreenUtils.setPx(0),
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        tabs: [
          Tab(text: listTab[0]),
          Tab(text: listTab[1]),
        ],
        unselectedLabelColor: AppColors.textDfColor,
        unselectedLabelStyle: TextStyle(
          fontSize: ScreenUtils.setPx(14),
          fontWeight: FontWeight.w500,
        ),
        labelColor: AppColors.textDfColor,
        labelStyle: TextStyle(
          fontSize: ScreenUtils.setPx(14),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
