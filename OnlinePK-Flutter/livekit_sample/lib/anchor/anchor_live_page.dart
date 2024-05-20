// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:livekit_sample/anchor/anchor_log.dart';
import 'package:livekit_sample/anchor/anchor_sub_widget/apply_seat_widget.dart';
import 'package:livekit_sample/anchor/anchor_sub_widget/start_live_widget.dart';
import 'package:livekit_sample/service/auth/auth_manager.dart';
import 'package:livekit_sample/utils/live_utils.dart';
import 'package:livekit_sample/utils/screen_utils.dart';
import 'package:livekit_sample/values/strings.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_sample/anchor/anchor_sub_widget/bottom_tool_view.dart';
import 'package:livekit_sample/anchor/anchor_sub_widget/bottom_tool_view_more.dart';
import 'package:livekit_sample/audience/widget/anchor_info_widget.dart';
import 'package:livekit_sample/base/lifecycle_base_state.dart';
import 'package:livekit_sample/nav/nav_utils.dart';
import 'package:livekit_sample/utils/dialog_utils.dart';
import 'package:livekit_sample/utils/toast_utils.dart';
import 'package:livekit_sample/values/asset_name.dart';
import 'package:livekit_sample/values/colors.dart';
import 'package:livekit_sample/audience/widget/audience_portrait_widget.dart';
import 'package:netease_roomkit/netease_roomkit.dart';
import 'package:livekit_sample/widgets/chatroom_list_view.dart';
import 'package:permission_handler/permission_handler.dart';
import '../audience/widget/audience_total_count_widget.dart';
import '../nav/router_name.dart';
import '../service/client/http_code.dart';
import 'anchor_sub_widget/audio_maxing_view.dart';
import 'package:livekit_sample/widgets/live_list.dart';
import 'anchor_sub_widget/faceunity/faceunity_beauty_cache.dart';
import 'anchor_sub_widget/faceunity/faceunity_beauty_setting_view.dart';
import 'anchor_sub_widget/faceunity/faceunity_filter_setting_view.dart';
import 'package:wakelock/wakelock.dart';
import 'package:netease_roomkit_interface/netease_roomkit_interface.dart';

///主播直播页面
// ignore: must_be_immutable
class AnchorLivePageRoute extends StatefulWidget {
  const AnchorLivePageRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AnchorLivePageRouteState();
  }
}

class _AnchorLivePageRouteState extends LifecycleBaseState<AnchorLivePageRoute>
    with LiveListDataMixin {
  static const int previewWidth = 540;
  static const int previewHeight = 960;
  bool isInLive = false;

  AudioMaxing _audioMaxing = AudioMaxing(-1, 100, -1, 100);
  var _height = 0.0;

  // local video
  NERtcVideoRenderer? localRenderer;

  late NELiveCallback _callback;
  final List<String> _audienceAvatarList = [];

  //单个连麦的高度
  double itemVideoHeight = 0;
  double itemVideoWidth = 0;
  int _memberNum = 0;

  NEPreviewRoomContext? previewRoomContext;

  void _loadDataCallback(
      List<NELiveDetail> liveInfoList, bool isRefresh, int valueCode) {
    setState(() {
      setDataList(liveInfoList, isRefresh);
    });
    if (valueCode == HttpCode.netWorkError) {
      ToastUtils.showToast(
          context, 'The Internet connection appears to be offline.');
    }
  }

  final ChatroomMessagesController _chatroomController =
      ChatroomMessagesController();
  final ChatroomMessagesController _importantChatroomController =
      ChatroomMessagesController();
  final ChatroomMessagesController _seatInfoController =
      ChatroomMessagesController();

  final ValueNotifier<int> _iconNumListener = ValueNotifier<int>(0);

  ///当前连麦中的id
  List<String> onSeatUsers = [];

  ///当前连麦的数组
  List<LiveLianMaiUserInfoBean> rtcVideoRenderers = [];

  ///当前房间的上下文。获取房间信息
  NERoomContext? roomContext;

  ///麦位监听器
  NESeatEventCallback? _seatEventCallback;

  ///房间事件监听器
  NERoomEventCallback? _roomEventCallback;
  bool isVideo = true;

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _height = MediaQuery.of(context).viewInsets.bottom;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _moreModel = _defaultDataList();
    getLiveLists(true, _loadDataCallback);
    _callback = NELiveCallback(
      membersJoinChatroom: (List<NERoomMember> members) {
        for (var m in members) {
          if (!m.role.name.contains(NELiveRole.anchor)) {
            _chatroomController.addMessage(
              ChatroomNotifyMessage(
                  notifyType: ChatroomNotifyType.kMemberJoin,
                  userUuid: m.uuid,
                  nickname: m.name),
            );
          }
        }
        _refreshAudiencePortrait();
      },
      membersLeaveChatroom: (List<NERoomMember> members) {
        for (var m in members) {
          if (!m.role.name.contains('host')) {
            _chatroomController.addMessage(
              ChatroomNotifyMessage(
                  notifyType: ChatroomNotifyType.kMemberLeave,
                  userUuid: m.uuid,
                  nickname: m.name),
            );
          }
        }
        _refreshAudiencePortrait();
      },
      messagesReceived: (List<NERoomChatTextMessage> messages) {
        for (var m in messages) {
          _chatroomController.addMessage(
            ChatroomTextMessage(
                userUuid: m.fromUserUuid,
                nickname: m.fromNick,
                text: m.text,
                isAnchor: false),
          );
        }
      },
      rewardReceived: (NELiveBatchRewardMessage message) {
        setState(() {
          message.seatUserReward?.forEach((element) {
            if (element.userUuid == NELiveKit.instance.userUuid) {
              _iconNumListener.value = element.rewardTotal ?? 0;
              _chatroomController.addMessage(
                ChatroomGiftMessage(
                    giftId: message.giftId ?? 0,
                    userUuid: message.senderUserUuid,
                    nickname: message.userName),
              );
              _importantChatroomController.addMessage(
                ChatroomGiftMessage(
                    giftId: message.giftId ?? 0,
                    userUuid: message.senderUserUuid,
                    nickname: message.userName),
              );
            }
          });
        });
      },
      loginKickOut: () {
        /// TODO: 账号被踢
      },
      liveEnded: (int reason) {
        DialogUtils.commonShowOneChooseCupertinoDialog(
            context, 'Remind', 'error happen.Live End,errorCode:$reason', () {
          NavUtils.popUntil(context, RouterName.liveListPage);
        });
      },
    );
    NELiveKit.instance.addEventCallback(_callback);
    _startPreview();
  }

  _startPreview() {
    bool isAllGranted = true;
    _requestPermissions().then((value) {
      value.forEach((key, value) {
        if (value.isDenied || value.isPermanentlyDenied) {
          isAllGranted = false;
        }
      });
      if (isAllGranted) {
        NELiveKit.instance.mediaController.previewRoom().then((value) {
          initLocalVideoView().then((_) {
            previewRoomContext = value.data;
            previewRoomContext?.previewController
                .setLocalVideoConfig(NERoomVideoConfig(
                    width: previewWidth, height: previewHeight, fps: 30))
                .then((value) {
              previewRoomContext?.previewController
                  .startPreview()
                  .then((value) {
                FaceUnityBeautyCache().init();
                FaceUnityBeautyCache().resetBeauty();
                FaceUnityBeautyCache().resetFilter();
              });
            });
          });
        });
      } else {
        NavUtils.pop(context,
            arguments: StartLiveArguments(StartLiveResult.noPermission));
      }
    });
  }

  Future<Map<Permission, PermissionStatus>> _requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        // Permission.storage,
        Permission.microphone,
        Permission.camera,
      ].request();
      return statuses;
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.camera,
      ].request();
      return statuses;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.green,
      body: WillPopScope(
        onWillPop: () {
          if (isInLive) {
            _showEndLiveDialog();
            return Future.value(false);
          } else {
            Navigator.of(context).pop();
            return Future.value(false);
          }
        },
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {},
            child: Stack(
              children: [
                if (onSeatUsers.isEmpty)
                  _singleHostWidget()
                else
                  _multiHostAndAudienceWidget(),
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: isInLive
                      ? Container()
                      : StartLiveWidget(
                          onCreateLiveOK: (live) {
                            if (live != null || mounted) {
                              _refreshAudiencePortrait();
                              roomCallback();
                              setState(() {
                                isInLive = true;
                              });
                            }
                          },
                        ),
                ),
                !isInLive
                    ? Container()
                    : buildSmallVideoView(NELiveKit.instance.nickname ??
                        NELiveKit.instance.userUuid!),
              ],
            )
            // _touchAreaClickCallback(),
            ),
      ),
    );
  }

  Widget buildSmallVideoView(String userUuid) {
    return Stack(
      children: <Widget>[
        Positioned(
          ///chatView
          right: 87,
          bottom: 100 + _height,
          left: 8,
          height: 204,
          child: ChatroomListView(
            controller: _chatroomController,
          ),
        ),
        Positioned(
          ///chatView
          right: 8,
          bottom: 100 + _height,
          left: 210,
          height: 204,
          child: ChatroomListView(
            controller: _importantChatroomController,
          ),
        ),
        Positioned(
          ///chatView
          right: 87,
          bottom: 300 + _height,
          left: 8,
          height: 204,
          child: ChatroomListView(
            controller: _seatInfoController,
          ),
        ),
        Positioned(
          ///inroom info
          left: 8,
          top: 4 + MediaQuery.of(context).padding.top,
          // width: 54,
          // height: 36,
          child: Container(
            child: AnchorInfoWidget(
              anchorName: userUuid,
              anchorIcon: NELiveKit.instance.liveDetail?.anchor?.icon,
              iconNumListener: _iconNumListener,
            ),
            constraints: const BoxConstraints(
              maxWidth: 150, // 最大宽度
            ),
          ),
        ),
        Positioned(
            right: 68,
            top: 8 + MediaQuery.of(context).padding.top,
            height: 28,
            child: AudiencePortraitWidget(
              avatarList: _audienceAvatarList,
            )),
        Positioned(
          ///inroom number
          right: 8,
          top: 8 + MediaQuery.of(context).padding.top,
          // width: 54,
          height: 28,
          child: AudienceTotalCount(
            memberNum: _memberNum >= 0 ? _memberNum : 0,
          ),
        ),
        Positioned(
          ///chatView
          right: 10,
          bottom: 90,
          height: 36,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Image.asset(
                  AssetName.iconLinkmic,
                  fit: BoxFit.cover, // Fixes border issues
                  width: 32.0,
                  height: 32.0,
                ),
                Visibility(
                  visible: true,
                  child: Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: ScreenUtils.setPx(10),
                      height: ScreenUtils.setPx(10),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.circular(ScreenUtils.setPx(10)),
                      ),
                    ),
                  ),
                )
              ],
            ),
            onTap: () {
              ///连麦列表
              var roomId = NELiveKit.instance.liveDetail?.live?.roomUuid ?? "";

              showModalBottomSheet(
                backgroundColor: AppColors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setBottomSheetState) {
                      return ApplySeatView(
                          roomUuid: roomId,
                          anchorId:
                              NELiveKit.instance.liveDetail?.anchor?.userUuid ??
                                  "");
                    },
                  );
                },
              );
            },
          ),
        ),
        Positioned(

            ///bottom Tool View
            right: 8,
            bottom: 48,
            left: 8,
            height: 36,
            child: BottomTooView(
              tapCallBack: tapCallBack,
              onSend: (message) {
                if (TextUtils.isNotEmpty(message)) {
                  NELiveKit.instance.sendTextMessage(message);
                  _chatroomController.addMessage(ChatroomTextMessage(
                      userUuid: NELiveKit.instance.userUuid,
                      nickname:
                          NELiveKit.instance.liveDetail?.anchor?.userName ??
                              NELiveKit.instance.userUuid,
                      text: message,
                      isAnchor: true));
                }
              },
            )),
      ],
    );
  }

  late List<Model> _moreModel;

  ///bottom view click callback
  void tapCallBack(int index) {
    if (index == 3) {
      ///click more button
      showModalBottomSheet(
          context: context,
          builder: (_) {
            return BottomToolViewMore(
                tapCallBack: tapToolMoreCallBack, modelDatas: _moreModel);
          });
    } else if (index == 2) {
      showModalBottomSheet(
          context: context,
          builder: (_) {
            return AudioMaxingView(
              audioMaxing: _audioMaxing,
              audioMaxingcallback: audioMaxingCallback,
            );
          });
    } else if (index == 1) {
      showModalBottomSheet(
          context: context,
          builder: (_) {
            return const FaceUnityBeautySettingView();
          });
    }
  }

  void audioMaxingCallback(AudioMaxing item) {
    _audioMaxing = item;
  }

  List<Model> _defaultDataList() {
    List<Model> list = [];
    List<String> imageList = _getImageNameDataList();
    List<String> textList = _getTextDataList();
    List<String> imageAnotherList = _getAnotherImageNameDataList();

    for (var index = 0; index < 6; index++) {
      Model model = Model(
          textList[index], imageList[index], 0, imageAnotherList[index], index);
      list.add(model);
    }
    return list;
  }

  List<String> _getImageNameDataList() {
    List<String> list = [
      AssetName.iconBottomMoreCameraOn,
      AssetName.iconBottomMoreVoiceOn,
      AssetName.iconBottomEarBackOff,
      AssetName.iconBottomMoreFlip,
      AssetName.iconBottomMoreFilter,
      AssetName.iconBottomMoreClose
    ];
    return list;
  }

  List<String> _getAnotherImageNameDataList() {
    List<String> list = [
      AssetName.iconBottomMoreCameraOff,
      AssetName.iconBottomMoreVoiceOff,
      AssetName.iconBottomEarBackOn,
      AssetName.iconBottomMoreFlip,
      AssetName.iconBottomMoreFilter,
      AssetName.iconBottomMoreClose
    ];
    return list;
  }

  List<String> _getTextDataList() {
    List<String> list = [
      Strings.camera,
      Strings.microPhone,
      Strings.earBack,
      Strings.flip,
      Strings.filter,
      Strings.endLive
    ];
    return list;
  }

  ///bottom More view click callback
  void tapToolMoreCallBack(Model model) {
    if (model.itemIndex == 0) {
      // camera
      if (model.itemSelected) {
        NELiveKit.instance.mediaController.disableLocalVideo();
        isVideo = false;
      } else {
        NELiveKit.instance.mediaController.enableLocalVideo();
        isVideo = true;
      }
    } else if (model.itemIndex == 1) {
      // voice
      if (model.itemSelected) {
        NELiveKit.instance.mediaController.disableLocalAudio();
      } else {
        NELiveKit.instance.mediaController.enableLocalAudio();
      }
    } else if (model.itemIndex == 2) {
      // ear back
      if (model.itemSelected) {
        NELiveKit.instance.mediaController.enableEarBack(80).then((value) {
          if (value.code == -1) {
            ToastUtils.showToast(context, Strings.earBackTip);
            model.itemSelected = true;
            setState(() {});
          }
        });
      } else {
        NELiveKit.instance.mediaController.disableEarBack();
      }
    } else if (model.itemIndex == 3) {
      // flip
      NELiveKit.instance.mediaController.switchCamera();
    } else if (model.itemIndex == 4) {
      // filter
      NavUtils.pop(context);
      DialogUtils.showChildNavigatorPopup(
          context, const FaceUnityFilterSettingView());
    } else if (model.itemIndex == 5) {
      // end live
      _showEndLiveDialog();
    }
  }

  void _showEndLiveDialog() {
    DialogUtils.showEndLiveDialog(context, '', () {}, () {
      NavUtils.popUntil(context, RouterName.liveListPage);
    });
  }

  ///其他人的连麦
  Future<void> createRemoteVideoViewTo(
      String roomId, NERoomMember member) async {
    bool containsId =
        rtcVideoRenderers.any((userInfo) => userInfo.userId == member.uuid!);
    if (!containsId) {
      NERtcVideoRenderer rtcVideoRenderer =
          await NERtcVideoRendererFactory.createVideoRenderer(roomId);
      rtcVideoRenderer.attachToRemoteVideo(member.uuid);
      rtcVideoRenderer.setMirror(false);
      rtcVideoRenderers.add(LiveLianMaiUserInfoBean(
          member.uuid, member.name, member.avatar, rtcVideoRenderer));
    }
  }

  Future<void> initLocalVideoView() async {
    localRenderer = await NERtcVideoRendererFactory.createVideoRenderer("");
    await localRenderer!.attachToLocalVideo();
    localRenderer!.setMirror(true);
    rtcVideoRenderers.add(LiveLianMaiUserInfoBean(NELiveKit.instance.userUuid!,
        AuthManager().nickName, AuthManager().avatar, localRenderer!));
    setState(() {});
  }

  Future<void> releaseLocalVideoView() async {
    var tempRender = localRenderer;
    setState(() {
      localRenderer = null;
    });
    tempRender?.dispose();
  }

  void _refreshAudiencePortrait() {
    NELiveKit.instance
        .fetchChatroomMembers(NEChatroomMemberQueryType.kGuestDesc, 10000, null)
        .then((value) {
      _audienceAvatarList.clear();
      final data = value.data;
      if (data != null) {
        _memberNum = data.length;
        if (value.data!.length < 6) {
          value.data?.forEach((element) {
            _audienceAvatarList.add(element.avatar ?? '');
          });
        } else {
          // 只取前五个头像
          for (var i = 0; i < 5; i++) {
            _audienceAvatarList.add(data[i].avatar ?? '');
          }
        }
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  ///监听房间
  void roomCallback() {
    NERoomService roomService = NERoomKit.instance.roomService;
    roomContext = roomService
        .getRoomContext(NELiveKit.instance.liveDetail!.live!.roomUuid!);

    _seatEventCallback = NESeatEventCallback(
      seatManagerAddedCallback: (List<String?> managers) {
        ///主播设置管理员
        AnchorLog.log("add seat manager");
      },
      seatManagerRemovedCallback: (List<String?> managers) {
        ///主播取消管理员
        AnchorLog.log("remove seat manager");
      },
      seatRequestSubmittedCallback: (int seatIndex, String user) {
        ///申请连麦
        AnchorLog.log("member $user request seat $seatIndex submitted");
        _seatInfoController.addMessage(
          ChatroomTextMessage(
              userUuid: user,
              nickname: user,
              text: 'request on seat',
              isAnchor: false),
        );
        // _handleSeatRequestSubmitted(seatIndex, user);
      },
      seatRequestCancelledCallback: (int seatIndex, String user) {
        ///取消连麦
        AnchorLog.log("member $user request seat $seatIndex cancelled");
        _seatInfoController.addMessage(
          ChatroomTextMessage(
              userUuid: user,
              nickname: user,
              text: 'cancel request on seat',
              isAnchor: false),
        );
        // _handleSeatRequestCancelled(seatIndex, user);
      },
      seatRequestApprovedCallback:
          (int seatIndex, String user, String operateBy, bool isAutoAgree) {
        ///同意连麦
        AnchorLog.log(
            "member $user request seat $seatIndex approved by $operateBy");
        // _handleSeatRequestApproved(seatIndex, user, operateBy, isAutoAgree);
        _seatInfoController.addMessage(
          ChatroomTextMessage(
              userUuid: user,
              nickname: user,
              text: 'is approved on seat',
              isAnchor: false),
        );
      },
      seatRequestRejectedCallback:
          (int seatIndex, String user, String operateBy) {
        ///拒绝连麦
        AnchorLog.log(
            "member $user request seat $seatIndex rejected by $operateBy");
        _seatInfoController.addMessage(
          ChatroomTextMessage(
              userUuid: user,
              nickname: user,
              text: 'is reject on seat',
              isAnchor: false),
        );
        // _handleSeatRequestRejected(seatIndex, user, operateBy);
      },
      seatLeaveCallback: (int seatIndex, String user) {
        ///连麦者下麦
        AnchorLog.log("member $user leave seat $seatIndex");
        _seatInfoController.addMessage(
          ChatroomTextMessage(
              userUuid: user,
              nickname: user,
              text: 'leave seat',
              isAnchor: false),
        );
        _handleSeatLeave(seatIndex, user);
      },
      seatKickedCallback: (int seatIndex, String user, String operateBy) {
        ///连麦者被踢
        AnchorLog.log("member $user kicked by $operateBy from seat $seatIndex");
        _seatInfoController.addMessage(
          ChatroomTextMessage(
              userUuid: user,
              nickname: user,
              text: 'is kicked seat',
              isAnchor: false),
        );
        _handleSeatLeave(seatIndex, user);
      },
      seatListChangedCallback: (List<NESeatItem> seatItems) {
        ///麦位列表变化
        AnchorLog.log("seat list changed $seatItems");
        // _handleSeatListChanged(seatItems);
      },
    );
    _roomEventCallback = NERoomEventCallback(
      ///成员加入rtc
      memberJoinRtcChannel: (List<NERoomMember> members) {
        if (members.isEmpty) {
          return;
        }
        for (var member in members) {
          AnchorLog.log("member ${member.toJson()} join rtc channel");
          if (!LiveUtils.isSelf(member.uuid)) {
            _handleOtherJoinRTC(member);
          }
        }
        setState(() {});
      },

      ///成员离开rtc
      memberLeaveRtcChannel: (List<NERoomMember> members) {
        for (var member in members) {
          AnchorLog.log("member ${member.uuid} leave rtc channel");
        }
      },
    );
    roomContext?.seatController.addEventCallback(_seatEventCallback!);
    roomContext?.addEventCallback(_roomEventCallback!);
  }

  _handleSeatLeave(int seatIndex, String user) {
    onSeatUsers.remove(user);
    if (rtcVideoRenderers.isNotEmpty) {
      rtcVideoRenderers.removeWhere((element) {
        if (element.userId == user) {
          element.renderer.detach();
          element.renderer.dispose();
          return true;
        }
        return false;
      });
    }
    NELiveKit.instance.updateLive(onSeatUsers);
    setState(() {});
  }

  Future<void> _handleOtherJoinRTC(NERoomMember member) async {
    AnchorLog.log("_handleOtherJoinRTC member = ${member.toJson()}");
    bool containsId =
        rtcVideoRenderers.any((userInfo) => userInfo.userId == member.uuid);
    if (!containsId) {
      createRemoteVideoViewTo(
          NELiveKit.instance.liveDetail!.live!.roomUuid!, member);
      onSeatUsers.add(member.uuid);
      NELiveKit.instance.updateLive(onSeatUsers);
      roomContext!.rtcController
          .subscribeRemoteVideoStream(member.uuid, NEVideoStreamType.kHigh)
          .then((result) {
        if (result.isSuccess()) {
          AnchorLog.log('subscribeRemoteVideoStream success');
        } else {
          AnchorLog.log(
              'subscribeRemoteVideoStream error code ${result.code},msg:${result.msg}');
        }
      });
    }
  }

  ///单人的
  _singleHostWidget() {
    return Container(
        child: localRenderer == null
            ? Container(
                color: AppColors.black,
              )
            : isVideo
                ? Container(
                    child: NERtcVideoView(
                      localRenderer!,
                      fitType: NERtcVideoViewFitType.cover,
                    ),
                  )
                : Container(
                    color: AppColors.black,
                  ));
  }

  _multiHostAndAudienceWidget() {
    itemVideoHeight =
        (ScreenUtils.setheight(context) - ScreenUtils.setPx(78)) / 3.5;
    itemVideoWidth = ScreenUtils.setWidth(context) / 2;
    return Container(
      margin: EdgeInsets.only(
          top: ScreenUtils.setPx(48), bottom: ScreenUtils.setPx(30)),
      height: ScreenUtils.setheight(context),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: itemVideoHeight,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        //本身不滚动，让外面的singlescrollview来滚动
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: rtcVideoRenderers.length,
        itemBuilder: (BuildContext context, int index) {
          return _onSeatVideoWidgetItemView(rtcVideoRenderers[index]);
        },
      ),
    );
  }

  _onSeatVideoWidgetItemView(LiveLianMaiUserInfoBean item) {
    return ClipRect(
      child: Stack(
        children: [
          SizedBox(
            width: itemVideoWidth,
            height: itemVideoHeight,
            child: NERtcVideoView(
              item.renderer,
              fitType: NERtcVideoViewFitType.cover,
            ),
          ),
          Positioned(
              bottom: 3,
              right: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.black_60,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: Row(
                  children: [
                    Visibility(
                      visible: LiveUtils.isAnchor(item.userId),
                      child: Container(
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: AppColors.appMainColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 2),
                        child: const Text(
                          "主播",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: AppColors.white, fontSize: 10),
                        ),
                      ),
                    ),
                    Text(
                      item.userName ?? "观众",
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: AppColors.white, fontSize: 12),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
    localRenderer?.dispose();
    NELiveKit.instance.removeEventCallback(_callback);
    previewRoomContext?.previewController.stopPreview();
    NELiveKit.instance.stopLive();
    FaceUnityBeautyCache().destroy();
  }
}

class LiveLianMaiUserInfoBean {
  String userId;
  String? userHead;
  String? userName;
  NERtcVideoRenderer renderer;

  LiveLianMaiUserInfoBean(
      this.userId, this.userName, this.userHead, this.renderer);
}
