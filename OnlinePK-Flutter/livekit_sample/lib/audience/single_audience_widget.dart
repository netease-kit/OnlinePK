// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:event_bus/event_bus.dart' as event;
import 'package:flutter/material.dart';
import 'package:livekit_sample/nav/router_name.dart';
import 'package:livekit_sample/utils/live_utils.dart';
import 'package:livekit_sample/utils/net_util.dart';
import 'package:livekit_sample/audience/live_audience_page.dart';
import 'package:livekit_sample/utils/screen_utils.dart';
import 'package:livekit_sample/utils/toast_utils.dart';
import 'package:livekit_sample/widgets/seat_widget.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_sample/audience/live_err_page.dart';
import 'package:livekit_sample/audience/live_stream_play_widget.dart';
import 'package:livekit_sample/audience/option/live_options.dart';
import 'package:livekit_sample/audience/widget/anchor_info_widget.dart';
import 'package:livekit_sample/audience/widget/audience_total_count_widget.dart';
import 'package:livekit_sample/audience/widget/gift_panel_widget.dart';
import 'package:livekit_sample/audience/widget/right_bottom_options_widget.dart';
import 'package:livekit_sample/nav/nav_utils.dart';
import 'package:livekit_sample/utils/dialog_utils.dart';
import 'package:livekit_sample/audience/widget/audience_portrait_widget.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_roomkit/netease_roomkit.dart';
import 'package:netease_roomkit_interface/netease_roomkit_interface.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/input_widget.dart';
import '../base/lifecycle_base_state.dart';
import '../values/asset_name.dart';
import '../values/colors.dart';
import '../values/strings.dart';
import '../widgets/chatroom_list_view.dart';
import 'audience_log.dart';

class SingleAudienceWidget extends StatefulWidget {
  final NELiveDetail liveDetail;
  final event.EventBus eventBus;

  const SingleAudienceWidget(
      {Key? key, required this.liveDetail, required this.eventBus})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SingleAudienceWidgetState();
  }
}

class _SingleAudienceWidgetState
    extends LifecycleBaseState<SingleAudienceWidget>
    with TickerProviderStateMixin {
  final String _tag = "_SingleAudienceWidgetState-";
  late StreamSubscription<ConnectivityResult> subscription;

  AnimationController? _lottieController;
  final List _giftAnimalList = [];
  bool _giftAnimalIsRunning = false;
  String? _showLottieAnimal;
  int _memberNum = 0;
  NELiveCallback? _callback;

  ///当前房间的上下文。获取房间信息
  NERoomContext? roomContext;

  ///房间的回调
  NESeatEventCallback? _seatEventCallback;
  late PageController pageController;

  final ValueNotifier<int> _iconNumListener = ValueNotifier<int>(0);
  bool showLiverErrorPage = false;
  ConnectivityResult? currentNetworkState;

  late VoidCallback listener;

  final List<String> _audienceAvatarList = [];

  final ChatroomMessagesController _chatController =
      ChatroomMessagesController();
  final ChatroomMessagesController _importantChatroomController =
      ChatroomMessagesController();
  final ChatroomMessagesController _seatInfoController =
      ChatroomMessagesController();

  String? _anchorUserName;
  String? _anchorIcon;
  late StreamSubscription<JoinRetEvent> joinSubscription;

  /// 0 普通观众，1 连麦中
  ///
  static const int stateNormal = 0;
  static const int stateRequestSeat = 1;
  static const int stateOnSeat = 2;
  int currentState = stateNormal;
  //单个连麦的高度
  double itemVideoHeight = 0;
  double itemVideoWidth = 0;

  ///当前连麦中的id
  List<String> onSeatUsers = [];

  ///当前连麦的数组
  List<SeatInfoModel> rtcVideoRenderers = [];

  _SingleAudienceWidgetState();

  @override
  void initState() {
    super.initState();
    AudienceLog.log(tag: _tag, "initState：" + toStringShort());
    _anchorUserName = widget.liveDetail.anchor?.userName;
    _anchorIcon = widget.liveDetail.anchor?.icon;
    currentNetworkState = NetUtil.globalNetWork;
    showLiverErrorPage = currentNetworkState == ConnectivityResult.none;
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      showLiverErrorPage = result == ConnectivityResult.none;
      if (currentNetworkState == ConnectivityResult.none) {
        NELiveKit.instance.leaveLive().then((value) {
          NELiveKit.instance.joinLive(widget.liveDetail).then((joinRet) {
            // widget.liveDetail里的数据可能不是最新，所以加入直播后要查一把
            _refreshAudiencePortrait();
            showLiverErrorPage = value.code != 0;
            AudienceLog.log(
                tag: _tag,
                "Audience page network restore showLiverErrorPage:" +
                    showLiverErrorPage.toString());
            if (!showLiverErrorPage) {
              // network reconnect
              liveStreamPlayWidgetKey.currentState?.reconnect();
            }
            if (mounted) {
              setState(() {
                currentNetworkState = result;
              });
            }
          });
        });
      } else {
        if (mounted) {
          setState(() {
            currentNetworkState = result;
          });
        }
        AudienceLog.log(
            tag: _tag,
            "Audience page currentNetworkState:" +
                result.toString() +
                ",showLiverErrorPage:" +
                showLiverErrorPage.toString());
      }
    });
    joinSubscription = widget.eventBus.on<JoinRetEvent>().listen((event) {
      if (event.recordId == widget.liveDetail.live!.liveRecordId) {
        if (mounted) {
          _anchorUserName = NELiveKit.instance.liveDetail?.anchor?.userName;
          _anchorIcon = NELiveKit.instance.liveDetail?.anchor?.icon;
          _refreshAudiencePortrait();
          _handleLiveUi(event.result);
        }
      }
    });

    pageController = PageController(
      initialPage: LiveConfig.audienceSelectIndex,
      keepPage: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (currentState == stateOnSeat) {
          DialogUtils.showCommonDialog(
              context, Strings.tip, Strings.assertEndOnSeat, () {}, () {
            roomContext?.seatController.leaveSeat().then((value) {
              if (value.code == 0) {
                ToastUtils.showToast(context, Strings.endOnSeatSuccess);
              } else {
                ToastUtils.showToast(
                    context, value.msg ?? Strings.endOnSeatFailed);
              }
            });
            NELiveKit.instance.leaveLive().then((value) {
              NavUtils.pop(context);
              // widget.cancelCallback();
            });
          });
          return Future.value(false);
        } else {
          NELiveKit.instance.leaveLive().then((value) {
            NavUtils.pop(context);
            // widget.cancelCallback();
          });
          return Future.value(false);
        }
      },
      child: _audienceLayoutView(context),
    );
  }

  SizedBox _buildLeftPage(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
    );
  }

  Widget _buildRightPage() {
    return Stack(
      children: [
        Positioned(
            left: 8,
            top: 40,
            child: AnchorInfoWidget(
              anchorName: _anchorUserName ?? '',
              anchorIcon: _anchorIcon,
              iconNumListener: _iconNumListener,
            )),
        Positioned(
            right: 68,
            top: 40,
            height: 28,
            child: AudiencePortraitWidget(
              avatarList: _audienceAvatarList,
            )),
        Positioned(
            right: 8,
            top: 40,
            child: AudienceTotalCount(
              memberNum: _memberNum >= 0 ? _memberNum : 0,
            )),
        Positioned(
            right: 8,
            bottom: 14,
            left: 8,
            height: 36,
            child: Row(
              children: [
                Expanded(
                  child: _buildInputView(),
                  flex: 3,
                ),
                Expanded(
                  child: RightBottomOptions(
                    onClose: () {
                      NELiveKit.instance
                          .leaveLive()
                          .then((value) => NavUtils.pop(context));
                    },
                    onGift: () {
                      DialogUtils.showChildNavigatorPopup(context,
                          GiftPanelWidget(
                        onSend: (giftInfo) {
                          NELiveKit.instance.reward(giftInfo.giftId);
                          // playAnimal(giftInfo);
                        },
                      ));
                    },
                  ),
                  flex: 1,
                ),
              ],
            )),
        Positioned(
          ///chatView
          right: 87,
          bottom: 100,
          left: 8,
          height: 204,
          child: ChatroomListView(
            controller: _chatController,
          ),
        ),
        Positioned(
          ///chatView
          right: 8,
          bottom: 100,
          left: 210,
          height: 204,
          child: ChatroomListView(
            controller: _importantChatroomController,
          ),
        ),
        Positioned(
          ///chatView
          right: 0,
          bottom: 300,
          left: 8,
          height: 204,
          child: ChatroomListView(
            controller: _seatInfoController,
          ),
        ),
        Positioned(
          ///chatView
          right: 15,
          bottom: 58,
          height: 36,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Image.asset(
              AssetName.iconLinkmic,
              fit: BoxFit.cover, // Fixes border issues
              width: 32.0,
              height: 32.0,
            ),
            onTap: () {
              bool isAllGranted = true;
              _requestPermissions().then((value) {
                value.forEach((key, value) {
                  if (value.isDenied || value.isPermanentlyDenied) {
                    isAllGranted = false;
                  }
                });
                if (isAllGranted) {
                  AudienceLog.log(
                      tag: _tag, "currentState" + currentState.toString());
                  if (currentState == stateNormal) {
                    DialogUtils.showCommonDialog(
                        context, Strings.tip, Strings.assertOnSeat, () {}, () {
                      roomContext?.seatController
                          .submitSeatRequest(null, false)
                          .then((value) {
                        if (value.code == 0) {
                          ToastUtils.showToast(
                              context, Strings.requestOnSeatSuccess);
                        } else {
                          ToastUtils.showToast(context,
                              value.msg ?? Strings.requestOnSeatFailed);
                        }
                      });
                    });
                  } else if (currentState == stateRequestSeat) {
                    DialogUtils.showCommonDialog(context, Strings.tip,
                        Strings.cancelRequestOnSeat, () {}, () {
                      roomContext?.seatController
                          .cancelSeatRequest()
                          .then((value) {
                        if (value.code == 0) {
                          ToastUtils.showToast(
                              context, Strings.cancelRequestOnSeatSuccess);
                        } else {
                          ToastUtils.showToast(context,
                              value.msg ?? Strings.cancelRequestOnSeatFailed);
                        }
                      });
                    });
                  } else {
                    DialogUtils.showCommonDialog(context, Strings.tip,
                        Strings.assertEndOnSeatWithHost, () {}, () {
                      roomContext?.seatController.leaveSeat().then((value) {
                        if (value.code == 0) {
                          ToastUtils.showToast(
                              context, Strings.endOnSeatSuccess);
                        } else {
                          ToastUtils.showToast(
                              context, value.msg ?? Strings.endOnSeatFailed);
                        }
                      });
                    });
                  }
                } else {
                  ///没有权限处理
                  ToastUtils.showToast(context, Strings.havePermissions);
                }
              });
            },
          ),
        ),
        // 麦位UI
        const Positioned(
          top: 120,
          child: SeatWidget(),
        ),
      ],
    );
  }

  Widget _buildInputView() {
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
                    if (value.isNotEmpty) {
                      NELiveKit.instance.sendTextMessage(value!);
                      _chatController.addMessage(ChatroomTextMessage(
                          userUuid: NELiveKit.instance.userUuid,
                          nickname: NELiveKit.instance.nickname,
                          text: value,
                          isAnchor: false));
                    }
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  ///直播画面
  Widget _audienceLayoutView(BuildContext context) {
    //错误的显示
    LiveErrorType errorType = LiveErrorType.kLiveEnd;
    if (currentNetworkState == ConnectivityResult.none) {
      errorType = LiveErrorType.kNetwork;
    }
    if (showLiverErrorPage) {
      liveStreamPlayWidgetKey.currentState?.reset();
    }
    return Container(
        color: AppColors.color_999999,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Stack(
          children: [
            if (currentState == stateOnSeat)
              _buildOnSeatVideoWidget()
            else
              _buildSingleAudienceWidget(),
            _buildLiveErrorWidget(showLiverErrorPage, errorType),
            _buildLiveNormalWidget(showLiverErrorPage),
          ],
        ));
  }

  ///创建自己的视图 和主播的或者正在连麦的视图
  Future<void> _handleSelfJoinRTC() async {
    AudienceLog.log(tag: _tag, '_handleSelfJoinRTC');
    currentState = stateOnSeat;
    NERtcVideoRenderer? renderer =
        await NERtcVideoRendererFactory.createVideoRenderer(
            widget.liveDetail.live!.roomUuid!);
    renderer.attachToLocalVideo();
    renderer.setMirror(false);
    rtcVideoRenderers
        .add(SeatInfoModel(NELiveKit.instance.localMember!, renderer));
    liveStreamPlayWidgetKey.currentState?.isClose(true);

    ///成员加入RTC
    setState(() {
      // liveStreamPlayWidgetKey.currentState?.isClose(true);
      roomContext!.rtcController.unmuteMyAudio();
      roomContext!.rtcController.unmuteMyVideo();
      roomContext!.rtcController
          .subscribeRemoteVideoStream(
              widget.liveDetail.anchor!.userUuid!, NEVideoStreamType.kHigh)
          .then((result) {
        if (result.isSuccess()) {
          AudienceLog.log(
              tag: _tag,
              'subscribeRemoteVideoStream success uuid = ${widget.liveDetail.anchor!.userUuid}');
        } else {
          AudienceLog.log(
              tag: _tag,
              'subscribeRemoteVideoStream error code ${result.code},msg:${result.msg}');
        }
      });
    });
    // 如果有其他人在连麦，需要订阅他们的视频
    if (NELiveKit.instance.roomContext?.remoteMembers.isNotEmpty ?? false) {
      NELiveKit.instance.roomContext?.remoteMembers.forEach((element) {
        _handleOtherJoinRTC(element);
      });
    }
  }

  ///连麦者下线
  _handleSelfLeaveSeat() {
    if (rtcVideoRenderers.isNotEmpty) {
      for (var element in rtcVideoRenderers) {
        element.renderer.detach();
        element.renderer.dispose();
      }
    }
    rtcVideoRenderers = [];
    liveStreamPlayWidgetKey.currentState?.isClose(false);
    roomContext?.rtcController.leaveRtcChannel().then((result) {
      if (result.isSuccess()) {
        AudienceLog.log(tag: _tag, 'leave RTC success');
      } else {
        AudienceLog.log(
            tag: _tag, 'leave RTC error code ${result.code},msg:${result.msg}');
      }
    });
    roomContext?.changeMemberRole(
        NELiveKit.instance.userUuid!, NERoomBuiltinRole.OBSERVER);

    setState(() {
      currentState = stateNormal;
    });
  }

  _handleOtherLeaveSeat(String user) {
    AudienceLog.log(
        tag: _tag,
        "handleOtherLeaveSeat $user, rtcVideoRenderers = ${rtcVideoRenderers.length}");
    if (rtcVideoRenderers.isNotEmpty) {
      rtcVideoRenderers.removeWhere((element) {
        if (element.member.uuid == user) {
          element.renderer.detach();
          element.renderer.dispose();
          return true; // 返回 true 表示满足条件的元素需要被移除
        }
        return false; // 返回 false 表示满足条件的元素不需要被移除
      });
    }
    AudienceLog.log(
        tag: _tag, "current rtcVideoRenderers ${rtcVideoRenderers.length}");
  }

  Future<void> _handleOtherJoinRTC(NERoomMember member) async {
    AudienceLog.log(tag: _tag, '_handleOtherJoinRTC member = $member');
    AudienceLog.log(
        tag: _tag,
        '_handleOtherJoinRTC rtcVideoRenderers = $rtcVideoRenderers');
    if (currentState == stateOnSeat) {
      //查询rtcVideoRenderers中是否有当前的人
      bool containsId = rtcVideoRenderers
          .any((userInfo) => userInfo.member.uuid == member.uuid);
      if (!containsId) {
        NERtcVideoRenderer renderer =
            await NERtcVideoRendererFactory.createVideoRenderer(
                widget.liveDetail.live!.roomUuid!);
        renderer.attachToRemoteVideo(member.uuid);
        renderer.setMirror(false);
        rtcVideoRenderers.add(SeatInfoModel(member, renderer));
        setState(() {
          roomContext!.rtcController
              .subscribeRemoteVideoStream(member.uuid, NEVideoStreamType.kHigh)
              .then((result) {
            if (result.isSuccess()) {
              AudienceLog.log(
                  tag: _tag,
                  'subscribeRemoteVideoStream success uuid = ${member.uuid}');
            } else {
              AudienceLog.log(
                  tag: _tag,
                  'subscribeRemoteVideoStream failed uuid = ${member.uuid}');
            }
          });
        });
      }
    }
  }

  @override
  void dispose() {
    AudienceLog.log(
        tag: _tag, "SingleAudienceWidget dispose" + toStringShort());
    if (_callback != null) {
      NELiveKit.instance.removeEventCallback(_callback!);
    }
    joinSubscription.cancel();
    // NELiveKit.instance.leaveLive();
    pageController.dispose();
    subscription.cancel();
    super.dispose();
  }

  Widget _buildLiveNormalWidget(bool showLiverErrorPage) {
    if (showLiverErrorPage) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
    return PageView(
      onPageChanged: (int index) {
        AudienceLog.log(tag: _tag, "onPageChanged index $index");
        setState(() {
          LiveConfig.audienceSelectIndex = index;
        });
      },
      reverse: false,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      controller: pageController,
      children: [
        _buildLeftPage(context),
        _buildRightPage(),
      ],
    );
  }

  void _playAnimal(GiftInfo giftInfo) {
    _giftAnimalList.add(giftInfo);
    _playAnimalDetail();
  }

  Future _playAnimalDetail() async {
    if (_giftAnimalIsRunning) {
      _lottieController!.stop();
      _lottieController?.dispose();
      _giftAnimalList.removeAt(0);
      _giftAnimalIsRunning = false;
      setState(() {
        _showLottieAnimal = null;
      });
    }
    if (!mounted) {
      _giftAnimalList.clear();
      _giftAnimalIsRunning = false;
      return;
    }
    _giftAnimalIsRunning = true;
    _lottieController = AnimationController(vsync: this);
    _lottieController!.addStatusListener((state) {
      if (state == AnimationStatus.completed) {
        _lottieController?.dispose();
        _giftAnimalList.removeAt(0);
        _giftAnimalIsRunning = false;
        setState(() {
          _showLottieAnimal = null;
        });
      }
    });
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {
          _showLottieAnimal = (_giftAnimalList.first as GiftInfo).lottieAnimal;
        });
      });
    }
    // }
  }

  Widget _buildLiveErrorWidget(
      bool showLiverErrorPage, LiveErrorType errorType) {
    if (!showLiverErrorPage) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
    return AudienceLiveErrorPage(
        imageUrl: widget.liveDetail.anchor?.icon ?? '',
        nickname: widget.liveDetail.anchor?.userName ?? '',
        errorType: errorType,
        returnAction: () {
          AudienceLog.log(tag: _tag, "returnAction" + toStringShort());
          NavUtils.pop(context);
        },
        reconnectingAction: () {
          AudienceLog.log(tag: _tag, "reconnectingAction" + toStringShort());
          // network reconnect refresh current ui
          NELiveKit.instance.leaveLive().then((value) {
            NELiveKit.instance.joinLive(widget.liveDetail).then((joinRet) {
              // widget.liveDetail里的数据可能不是最新，所以加入直播后要查一把
              _refreshAudiencePortrait();
            });
          });
        });
  }

  _handleLiveUi(NEResult<String?> value) {
    AudienceLog.log(
        tag: _tag,
        "handleLiveUi,code:" +
            value.code.toString() +
            ",msg:" +
            value.msg.toString() +
            toStringShort());
    if (value.code != 0 && mounted) {
      setState(() {
        showLiverErrorPage = true;
      });
      return;
    }

    _callback = NELiveCallback(membersJoin: (List<NERoomMember> members) {
      for (var member in members) {
        AudienceLog.log(tag: _tag, "member join room member = $member");
        _handleMemberJoin(member);
      }
    }, membersJoinChatroom: (List<NERoomMember> members) {
      for (var member in members) {
        AudienceLog.log(tag: _tag, "member join chatroom member = $member");
        _handleMemberJoinChatroom(member);
      }
    }, membersJoinRtc: (List<NERoomMember> members) {
      for (var member in members) {
        AudienceLog.log(tag: _tag, 'on membersJoinRtc $member');
        if (LiveUtils.isSelf(member.uuid)) {
          currentState = stateOnSeat;
          _handleSelfJoinRTC();
        } else {
          _handleOtherJoinRTC(member);
        }
      }
    }, memberLeaveRtc: (List<NERoomMember> members) {
      // /离开Rtc
      for (var member in members) {
        AudienceLog.log(tag: _tag, 'on membersLeaveRtc $member');
      }
    }, membersLeave: (List<NERoomMember> members) {
      for (var member in members) {
        AudienceLog.log(tag: _tag, "member leave room member = $member");
        _handleMemberLeave(member);
      }
    }, membersLeaveChatroom: (List<NERoomMember> members) {
      for (var member in members) {
        AudienceLog.log(tag: _tag, "member leave chatroom member = $member");
        _handleMemberLeaveChatroom(member);
      }
    }, messagesReceived: (List<NERoomChatTextMessage> messages) {
      for (var message in messages) {
        AudienceLog.log(tag: _tag, "messagesReceived");
        _handleMessagesReceived(message);
      }
    }, rewardReceived: (NELiveBatchRewardMessage message) {
      AudienceLog.log(tag: _tag, "on receive reward");
      setState(() {
        message.seatUserReward?.forEach((element) {
          _handleRewardReceived(message.userUuid ?? "", message.userName ?? "",
              message.giftId ?? 0, element);
        });
      });
    }, loginKickOut: () {
      AudienceLog.log(tag: _tag, "on loginKickOut");
    }, liveEnded: (int reason) {
      AudienceLog.log(tag: _tag, "on live ended $reason");
      _handleLiveEnded(reason);
    });
    NELiveKit.instance.addEventCallback(_callback!);
    NERoomService roomService = NERoomKit.instance.roomService;
    roomContext = roomService.getRoomContext(widget.liveDetail.live!.roomUuid!);
    _seatEventCallback = NESeatEventCallback(
      seatManagerAddedCallback: (List<String?> managers) {
        ///主播设置管理员
        AudienceLog.log(tag: _tag, "on seatManager added $managers");
      },
      seatManagerRemovedCallback: (List<String?> managers) {
        ///主播取消管理员
        AudienceLog.log(tag: _tag, "on seatManager removed $managers");
      },
      seatRequestSubmittedCallback: (int seatIndex, String user) {
        ///申请连麦
        AudienceLog.log(
            tag: _tag, "on seat request submitted $seatIndex $user");

        _seatInfoController.addMessage(
          ChatroomTextMessage(
              userUuid: user,
              nickname: user,
              text: 'request on seat',
              isAnchor: false),
        );

        if (LiveUtils.isSelf(user)) {
          currentState = stateRequestSeat;
          // _handleSelfSeatRequestSubmitted(seatIndex, user);
        }
      },
      seatRequestCancelledCallback: (int seatIndex, String user) {
        ///取消连麦
        AudienceLog.log(
            tag: _tag, "on seat request cancelled $seatIndex $user");

        _seatInfoController.addMessage(
          ChatroomTextMessage(
              userUuid: user,
              nickname: user,
              text: 'cancel request on seat',
              isAnchor: false),
        );

        if (LiveUtils.isSelf(user)) {
          currentState = stateNormal;
        }
      },
      seatRequestApprovedCallback:
          (int seatIndex, String user, String operateBy, bool isAutoAgree) {
        ///同意连麦
        AudienceLog.log(
            tag: _tag, "on seat request approved $seatIndex $user $operateBy");
        // _handleSeatRequestApproved(seatIndex, user, operateBy, isAutoAgree);

        _seatInfoController.addMessage(
          ChatroomTextMessage(
              userUuid: user,
              nickname: user,
              text: 'approve on seat',
              isAnchor: false),
        );

        ///主播端同意连麦后。观众段的操作
        /// 自己上麦成功，再做上麦操作
        if (LiveUtils.isSelf(user)) {
          AudienceLog.log(tag: _tag, 'seat request is approved, user is me');
          currentState = stateOnSeat;
          roomContext?.changeMemberRole(user, 'audience');
        }
      },
      seatRequestRejectedCallback:
          (int seatIndex, String user, String operateBy) {
        ///拒绝连麦
        AudienceLog.log(
            tag: _tag, "on seat request rejected $seatIndex $user $operateBy");
        _seatInfoController.addMessage(
          ChatroomTextMessage(
              userUuid: user,
              nickname: user,
              text: 'is rejected on seat',
              isAnchor: false),
        );
        if (LiveUtils.isSelf(user)) {
          currentState = stateNormal;
        }
        // _handleSeatRequestRejected(seatIndex, user, operateBy);
      },
      seatLeaveCallback: (int seatIndex, String user) {
        ///连麦者下麦
        AudienceLog.log(tag: _tag, "on seat leave $seatIndex $user");
        _seatInfoController.addMessage(
          ChatroomTextMessage(
              userUuid: user,
              nickname: user,
              text: 'leave seat',
              isAnchor: false),
        );

        if (LiveUtils.isSelf(user)) {
          currentState = stateNormal;
          _handleSelfLeaveSeat();
        } else {
          _handleOtherLeaveSeat(user);
        }
        setState(() {});
      },
      seatKickedCallback: (int seatIndex, String user, String operateBy) {
        ///连麦者被踢
        AudienceLog.log(
            tag: _tag,
            "seat kick seatIndex = $seatIndex, user = $user, operateBy = $operateBy");
        _seatInfoController.addMessage(
          ChatroomTextMessage(
              userUuid: user,
              nickname: user,
              text: 'is kicked seat',
              isAnchor: false),
        );
        if (LiveUtils.isSelf(user)) {
          currentState = stateNormal;
          _handleSelfLeaveSeat();
        } else {
          _handleOtherLeaveSeat(user);
        }
        setState(() {});
      },
      seatListChangedCallback: (List<NESeatItem> seatItems) {
        ///麦位列表变化
        AudienceLog.log(tag: _tag, "on seat list changed $seatItems");
        // _handleSeatListChanged(seatItems);
        if (seatItems.isNotEmpty) {
          for (var element in seatItems) {
            AudienceLog.log(
                tag: _tag,
                "on seat list change item = ${element.user} ${element.userName}");
            // onSeatUsers.add(element.user!);
          }
        }
      },
    );
    roomContext?.seatController.addEventCallback(_seatEventCallback!);

    var liveRecordId = widget.liveDetail.live!.liveRecordId;
    // query live state
    NELiveKit.instance
        .fetchLiveInfo(liveRecordId)
        .then((value) => _handleGiftReward(value));
  }

  _buildOnSeatVideoWidget() {
    AudienceLog.log(
        tag: _tag, "current rtcVideoRenderers = ${rtcVideoRenderers.length}");
    itemVideoHeight =
        (ScreenUtils.setheight(context) - ScreenUtils.setPx(78)) / 3.5;
    itemVideoWidth = ScreenUtils.setWidth(context) / 2;
    AudienceLog.log(tag: _tag, "item video height = $itemVideoWidth");
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

  _onSeatVideoWidgetItemView(SeatInfoModel item) {
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
                      visible: LiveUtils.isAnchor(item.member.uuid),
                      child: Container(
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: AppColors.appMainColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 2),
                        child: const Text(
                          Strings.anchor,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: AppColors.white, fontSize: 10),
                        ),
                      ),
                    ),
                    Text(
                      item.member.name,
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

  _buildSingleAudienceWidget() {
    if (showLiverErrorPage) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
    return LiveStreamPlayWidget(
        key: const Key("ss"),
        liveDetail: widget.liveDetail,
        playNormal: () {
          showLiverErrorPage = false;
        },
        playError: () {
          AudienceLog.log(tag: _tag, "playError,mounted:$mounted");
          if (mounted) {
            setState(() {
              showLiverErrorPage = true;
            });
          }
        });
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

  _handleGiftReward(NEResult<NELiveDetail> value) {
    AudienceLog.log(
        tag: _tag,
        "_handleGiftReward,rewardTotal:${value.data?.live?.rewardTotal}");
    _iconNumListener.value = value.data?.live?.rewardTotal ?? 0;
  }

  void _handleMemberJoin(NERoomMember member) {}

  void _handleMemberJoinChatroom(NERoomMember member) {
    if (!mounted) {
      return;
    }
    if (LiveUtils.isSelf(member.uuid)) {
      return;
    }
    if (!member.role.name.contains(NELiveRole.anchor)) {
      _chatController.addMessage(
        ChatroomNotifyMessage(
            notifyType: ChatroomNotifyType.kMemberJoin,
            userUuid: member.uuid,
            nickname: member.name),
      );
    }
    _refreshAudiencePortrait();
  }

  void _handleMemberLeaveChatroom(NERoomMember member) {
    if (!member.role.name.contains('host')) {
      _chatController.addMessage(
        ChatroomNotifyMessage(
            notifyType: ChatroomNotifyType.kMemberLeave,
            userUuid: member.uuid,
            nickname: member.name),
      );
    }
    _refreshAudiencePortrait();
  }

  void _handleMemberLeave(NERoomMember member) {}

  void _handleMessagesReceived(NERoomChatTextMessage message) {
    _chatController.addMessage(
      ChatroomTextMessage(
          userUuid: message.fromUserUuid,
          nickname: message.fromNick,
          text: message.text,
          isAnchor: LiveUtils.isAnchor(message.fromUserUuid ?? '')),
    );
  }

  void _handleRewardReceived(String rewarderUserUuid, String? rewarderUserName,
      int giftId, NELiveBatchSeatUserReward anchorReward) {
    AudienceLog.log(
        tag: _tag, "rewardReceived,anchorReward:${anchorReward.rewardTotal}");
    if (!mounted) {
      return;
    }

    setState(() {
      bool isToSelf = anchorReward.userUuid ==
          NELiveKit.instance.liveDetail?.anchor?.userUuid;
      int coins = anchorReward.rewardTotal ?? 0;
      _iconNumListener.value = coins;
      AudienceLog.log(
          tag: _tag,
          "to user ${anchorReward.userUuid}, isToMe $isToSelf, coins1:$coins");
      if (isToSelf) {
        // to self
        _chatController.addMessage(
          ChatroomGiftMessage(
              giftId: giftId,
              userUuid: rewarderUserUuid,
              nickname: rewarderUserName),
        );

        _importantChatroomController.addMessage(
          ChatroomGiftMessage(
              giftId: giftId,
              userUuid: rewarderUserUuid,
              nickname: rewarderUserName),
        );

        if (giftId == 1) {
          _playAnimal(GiftInfo(1, Strings.bizLiveGlowStick, 9, AssetName.gift01,
              AssetName.lottieGift01));
        } else if (giftId == 2) {
          _playAnimal(GiftInfo(2, Strings.bizLiveArrange, 99, AssetName.gift02,
              AssetName.lottieGift02));
        } else if (giftId == 3) {
          _playAnimal(GiftInfo(3, Strings.bizLiveSportsCar, 199,
              AssetName.gift03, AssetName.lottieGift03));
        } else if (giftId == 4) {
          _playAnimal(GiftInfo(4, Strings.bizLiveRockets, 999, AssetName.gift04,
              AssetName.lottieGift04));
        }
      }
    });
  }

  void _handleLiveEnded(int reason) {
    AudienceLog.log(tag: _tag, "liveEnded,reason:$reason," + toStringShort());
    if (reason == NERoomEndReason.kLeaveBySelf.index || !mounted) {
      return;
    }
    setState(() {
      showLiverErrorPage = true;
      Navigator.of(context).popUntil(
          (route) => route.settings.name == RouterName.liveAudiencePage);
    });
  }

  ///权限申请
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
}

class SeatInfoModel {
  NERoomMember member;
  NERtcVideoRenderer renderer;

  SeatInfoModel(this.member, this.renderer);
}
