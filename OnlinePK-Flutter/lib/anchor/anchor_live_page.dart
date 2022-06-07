// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_pk/anchor/anchor_sub_widget/beauty_setting_view.dart';
import 'package:livekit_pk/anchor/anchor_sub_widget/bottom_tool_view.dart';
import 'package:livekit_pk/anchor/anchor_sub_widget/live_pk_end_pk_button_View.dart';
import 'package:livekit_pk/anchor/anchor_sub_widget/live_pk_gift_process_view.dart';
import 'package:livekit_pk/anchor/anchor_sub_widget/live_pk_inviting_process_view.dart';
import 'package:livekit_pk/anchor/anchor_sub_widget/live_pk_start_pk_button_View.dart';
import 'package:livekit_pk/anchor/anchor_sub_widget/bottom_tool_view_more.dart';
import 'package:livekit_pk/audience/widget/anchor_info_widget.dart';
import 'package:livekit_pk/base/lifecycle_base_state.dart';
import 'package:livekit_pk/anchor/anchor_sub_widget/live_pk_memeber_inviting_view.dart';
import 'package:livekit_pk/nav/nav_utils.dart';
import 'package:livekit_pk/utils/dialog_utils.dart';
import 'package:livekit_pk/utils/toast_utils.dart';
import 'package:livekit_pk/values/asset_name.dart';
import 'package:livekit_pk/values/colors.dart';
import 'package:livekit_pk/values/strings.dart';
import 'package:livekit_pk/widgets/audience_portrait_widget.dart';
import 'package:netease_roomkit/netease_roomkit.dart';
import 'package:livekit_pk/widgets/chatroom_list_view.dart';
import '../audience/widget/audience_total_count_widget.dart';
import '../nav/router_name.dart';
import '../service/client/http_code.dart';
import 'anchor_sub_widget/audio_maxing_view.dart';
import 'package:livekit_pk/widgets/live_list.dart';
import 'package:netease_roomkit_interface/netease_roomkit_interface.dart';
import 'anchor_sub_widget/beauty_setting_view.dart';
import 'anchor_sub_widget/filter_setting_view.dart';
import 'anchor_sub_widget/live_pk_timer_count_view.dart';
import 'package:wakelock/wakelock.dart';

///主播直播页面
class AnchorLivePageRoute extends StatefulWidget {
  final NELiveDetail arguments;
  bool isBackCamera;

  AnchorLivePageRoute({
    Key? key,
    required this.arguments,
    required this.isBackCamera,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AnchorLivePageRouteState();
  }
}

class _AnchorLivePageRouteState extends LifecycleBaseState<AnchorLivePageRoute>
    with LiveListDataMixin {
  int? _memberNum;
  String? _anchorRoomUUid;

  /// if pkAlert showed
  var _showPkAlert = false;

  /// if endPkDialog showed
  var _showEndPkDialog = false;

  /// if invitePkDialog showed
  var _showInvitePkDialog = false;

  /// if show invitingProcessView
  var _showInvitingProcessView = false;

  //choose anchor to pk
  NELiveDetail? _anchorDetail;
  String? inviterUsername;
  bool _showLivePkMemberInvitingView = false;
  AudioMaxing _audioMaxing = AudioMaxing(-1, 100, -1, 100);
  var _height = 0.0;

  // local video
  NERtcVideoRenderer? localRenderer;

  // remote video
  NERtcVideoRenderer? remoteRenderer;
  late NELiveCallback _callback;
  var _isPK = false;
  var _isOtherSoundOn = true;
  NELivePKAnchor? _peer;
  var _anchorSuccess = 0;
  var _showPKResult = true; // false;
  late NELiveDetail _liveDetail;
  static const int pkResultFailed = -1;
  static const int pkResultSuccess = 1;
  static const int pkResultDraw = 0;
  final List<String> _audienceAvatarList = [];

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

  final ChatroomMessagesController _controller = ChatroomMessagesController();

  final ValueNotifier<GiftModel> _giftListener =
      ValueNotifier<GiftModel>(GiftModel(0, 0));
  late TimeDataController _timeDataController =
      TimeDataController(TimeDataValue(Strings.pK, 0));
  final ValueNotifier<int> _iconNumListener = ValueNotifier<int>(0);
  final ValueNotifier<List<String?>?> _leftIconListListener =
      ValueNotifier<List<String?>?>([]);
  final ValueNotifier<List<String?>?> _rightIconListListener =
      ValueNotifier<List<String?>?>([]);

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _height = MediaQuery.of(context).viewInsets.bottom;
      });
    });
  }

  void reloadWithDatas() {
    List<NERoomMember>? memberList = NELiveKit.instance.members;
    int? tempIconNum = memberList?.length;
    if (tempIconNum == null || tempIconNum == 0) {
      tempIconNum = 1;
    }
    setState(() {
      _memberNum = tempIconNum! - 1;
    });
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _timeDataController = TimeDataController(TimeDataValue(Strings.pK, 0));
    _liveDetail = widget.arguments;
    _anchorRoomUUid = _liveDetail.live?.roomUuid;
    _moreModel = _defaultDataList();
    reloadWithDatas();
    getLiveLists(true, _loadDataCallback);
    _callback = NELiveCallback(
      pushStart: () {
        if (widget.isBackCamera) {
          NELiveKit.instance.mediaController.switchCamera();
        }
      },
      pKAccepted: (NELivePKAnchor actionAnchor) {
        ToastUtils.showToast(context, Strings.theOtherPartyAcceptYourInvite);
      },
      pKTimeout: (NELivePKAnchor actionAnchor) {
        ToastUtils.showToast(context, Strings.invitePkTimeOut);
        setState(() {
          dismissPKAlert();
          _showInvitingProcessView = false;
        });
      },
      pKCanceled: (NELivePKAnchor actionAnchor) {
        setState(() {
          dismissPKAlert();
          _showInvitingProcessView = false;
        });
        ToastUtils.showToast(context, Strings.invitePkCancel);
      },
      pKRejected: (NELivePKAnchor actionAnchor) {
        setState(() {
          dismissPKAlert();
          _showInvitingProcessView = false;
        });
        ToastUtils.showToast(context, Strings.invitePkReject);
      },
      pKInvited: (NELivePKAnchor actionAnchor) {
        setState(() {
          _showPkAlert = true;
          DialogUtils.commonShowCupertinoDialog(context, Strings.invitePK,
              '${(actionAnchor.userName ?? actionAnchor.userUuid)} ${Strings.inviteYouPkWhetherToAccept}',
              () {
            //cancel
            _showPkAlert = false;
            NELiveKit.instance.rejectPK();
          }, () {
            dismissInvitePKDialog();
            _showPkAlert = false;
            _showLivePkMemberInvitingView = false;
            NELiveKit.instance.acceptPK();
          }, sure: Strings.accept, cancel: Strings.refuse, visi: _showPkAlert);
        });
      },
      pkStart: (int pkStartTime, int pkCountDown, NELivePKAnchor self,
          NELivePKAnchor peer) {
        setState(() {
          _leftIconListListener.value = [];
          _rightIconListListener.value = [];
          _showInvitingProcessView = false;
          _showPKResult = false;
          _giftListener.value = GiftModel(0, 0);
          _isPK = true;
          _timeDataController
              .setTimeDataValue(TimeDataValue(Strings.pK, pkCountDown));
          initPKVideoView(peer.userUuid);
          _peer = peer;
          if (_isOtherSoundOn == false) {
            _isOtherSoundOn = true;
            NELiveKit.instance.mediaController
                .enablePeerAudio()
                .then((value) => print('value --- ' + value.code.toString()));
          }
        });
      },
      pkPunishmentStart:
          (int pkPenaltyCountDown, int selfRewards, int peerRewards) {
        setState(() {
          if (selfRewards == peerRewards) {
            _anchorSuccess = pkResultDraw;
          } else if (selfRewards > peerRewards) {
            _anchorSuccess = pkResultSuccess;
          } else {
            _anchorSuccess = pkResultFailed;
          }
          _showPKResult = true;
        });
        if (_anchorSuccess == pkResultDraw) {
          ///stop count
          // [self.pkStatusBar stopCountdown];
        } else {
          _timeDataController.setTimeDataValue(
              TimeDataValue(Strings.punish, pkPenaltyCountDown));
        }
      },
      pkEnded: (int reason,
          int pkEndTime,
          String senderUserUuid,
          String userName,
          int selfRewards,
          int peerRewards,
          bool countDownEnd) {
        if (reason == NEEndPKStatus.notNormal.index) {
          if (NELiveKit.instance.userUuid != senderUserUuid) {
            ToastUtils.showToast(context, userName + " End PK");
          }
        }
        setState(() {
          dismissEndPKDialog();
          _showPKResult = false;
          _showInvitingProcessView = false;
          _isPK = false;
          recoverSingleVideoView();
        });
      },
      membersJoin: (List<NERoomMember> members) {
        reloadWithDatas();
        for (var m in members) {
          if (!m.role.name.contains('host')) {
            _controller.addMessage(
              ChatroomNotifyMessage(
                  notifyType: ChatroomNotifyType.kMemberJoin,
                  userUuid: m.uuid,
                  nickname: m.name),
            );
          }
        }
        _refreshAudiencePortrait();
      },
      membersLeave: (List<NERoomMember> members) {
        reloadWithDatas();
        for (var m in members) {
          if (!m.role.name.contains('host')) {
            _controller.addMessage(
              ChatroomNotifyMessage(
                  notifyType: ChatroomNotifyType.kMemberLeave,
                  userUuid: m.uuid,
                  nickname: m.name),
            );
          }
        }
        _refreshAudiencePortrait();
      },
      messagesReceived: (List<NERoomTextMessage> messages) {
        for (var m in messages) {
          _controller.addMessage(
            ChatroomTextMessage(
                userUuid: m.fromAccount,
                nickname: m.fromNick,
                text: m.text,
                isAnchor: false),
          );
        }
      },
      rewardReceived: (String rewarderUserUuid,
          String? rewarderUserName,
          int giftId,
          NELiveAnchorReward anchorReward,
          NELiveAnchorReward otherAnchorReward) {
        setState(() {
          bool isToSelf = anchorReward.userUuid == NELiveKit.instance.userUuid;
          if (NELiveKit.instance.pkStatus == NELivePKStatus.pking) {
            int leftReward = isToSelf
                ? anchorReward.pkRewardTotal
                : otherAnchorReward.pkRewardTotal;
            List<String?>? leftAvatars = isToSelf
                ? anchorReward.rewardIcons
                : otherAnchorReward.rewardIcons;
            int rightReward = isToSelf
                ? otherAnchorReward.pkRewardTotal
                : anchorReward.pkRewardTotal;
            List<String?>? rightAvatars = isToSelf
                ? otherAnchorReward.rewardIcons
                : anchorReward.rewardIcons;
            _giftListener.value = GiftModel(leftReward, rightReward);
            _leftIconListListener.value = leftAvatars;
            _rightIconListListener.value = rightAvatars;
          }

          // 更新用户信息栏(云币值)
          int coins = anchorReward.rewardTotal;
          if (!isToSelf) {
            coins = otherAnchorReward.rewardTotal;
          }
          _iconNumListener.value = coins;

          if (isToSelf) {
            // to self
            _controller.addMessage(
              ChatroomGiftMessage(
                  giftId: giftId,
                  userUuid: rewarderUserUuid,
                  nickname: rewarderUserName),
            );
          }
        });
      },
      loginKickOut: () {
        /// TODO: 账号被踢
      },
      liveEnded: (int reason) {
        if (reason == 30015) {
          ///net lose
          DialogUtils.commonShowOneChooseCupertinoDialog(context, 'Remind',
              'The Internet connection appears to be offline.Live End', () {
            NavUtils.popUntil(context, RouterName.liveListPage);
          });
        } else {
          DialogUtils.commonShowOneChooseCupertinoDialog(
              context, 'Remind', 'error happen.Live End,errorCode:$reason', () {
            NavUtils.popUntil(context, RouterName.liveListPage);
          });
        }
      },
    );
    NELiveKit.instance.addEventCallback(_callback);
    initSingleVideoView();
  }

  void dismissPKAlert() {
    if (_showPkAlert) {
      NavUtils.pop(context);
      _showPkAlert = false;
    }
  }

  void dismissEndPKDialog() {
    if (_showEndPkDialog) {
      NavUtils.pop(context);
      _showEndPkDialog = false;
    }
  }

  void dismissInvitePKDialog() {
    if (_showInvitePkDialog) {
      NavUtils.pop(context);
      _showInvitePkDialog = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.green,
      body: WillPopScope(
        onWillPop: () {
          _showEndLiveDialog();
          return Future.value(false);
        },
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: buildSmallVideoView(
                NELiveKit.instance.nickname ?? NELiveKit.instance.userUuid!),
            onTap: () {
              _touchAreaClickCallback();
            }
            // _touchAreaClickCallback(),
            ),
      ),
    );
  }

  Widget buildSmallVideoView(String userUuid) {
    // return NERoomUserVideoView(
    //   userUuid,
    //   mirror: true,

    // );
    return Stack(
      children: <Widget>[
        Container(
          child: localRenderer == null || _isPK
              ? Container(
                  color: AppColors.black,
                )
              : NERtcVideoView(localRenderer!,
                  fitType: NERtcVideoViewFitType.cover),
        ),
        Positioned(
          ///chatView
          right: 87,
          bottom: 100 + _height,
          left: 8,
          height: 204,
          child: ChatroomListView(
            controller: _controller,
          ),
        ),
        Positioned(
            right: 0,
            left: 0,
            top: 64 + MediaQuery.of(context).padding.top,
            child: Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.123,
                  child: buildPKVideoView(userUuid),
                ),
                Visibility(
                    visible: _isPK,
                    child: SizedBox(
                      height: 60,
                      child: LivePkGiftProcessView(
                        modelListener: _giftListener,
                        timeDataController: _timeDataController,
                        leftIconListListener: _leftIconListListener,
                        rightIconListListener: _rightIconListListener,
                      ),
                    ))
              ],
            )),
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
            memberNum: _memberNum ?? 0,
          ),
        ),
        Positioned(
          ///InvitingProcessView
          right: 8,
          top: 108,
          left: 8,
          // height: 36,
          child: Visibility(
              visible: _showInvitingProcessView,
              child: LivePKInvitingProcessView(
                connectName: _anchorDetail?.anchor?.userName ??
                    _anchorDetail?.anchor?.userUuid,
                cancelCallback: () {
                  NELiveKit.instance.cancelPKInvite().then((value) {
                    if (value.code != 0) {
                      ToastUtils.showToast(
                          context,
                          Strings.cancelInviteFail +
                              value.code.toString() +
                              (value.msg ?? ''));
                    }
                  });
                  setState(() {
                    _showLivePkMemberInvitingView = false;
                    _showInvitingProcessView = false;
                  });
                },
              )),
        ),
        Visibility(
          visible: !_isPK,
          child: Positioned(

              ///start PK Button
              right: 8,
              bottom: 100,
              height: 56,
              width: 56,
              child: LivePkStartPkButtonView(
                callback: () {
                  ///show other author list
                  _handleStartPkButtonCallback();
                },
              )),
        ),
        Positioned(
          right: 8,
          bottom: 100,
          height: 56,
          width: 56,
          child: Visibility(
              visible: _isPK,
              child: LivePkEndPkButtonView(
                cancelCallback: _handleEndPkButtonCallback,
                // {   _giftListener.value = getGiftModelData(
                //     Random().nextInt(100), Random().nextInt(100), 0.5, 100);
                // }
              )),
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
                  _controller.addMessage(ChatroomTextMessage(
                      userUuid: NELiveKit.instance.userUuid,
                      nickname:
                          NELiveKit.instance.liveDetail?.anchor?.userName ??
                              NELiveKit.instance.userUuid,
                      text: message,
                      isAnchor: true));
                }
              },
            )),
        Positioned(
          ///inviting pk author list
          right: 0,
          bottom: 0,
          left: 0,
          height: 308,
          child: Visibility(
            visible: _showLivePkMemberInvitingView,
            child: LivePkMemberInvitingView(
              clickPkCallback: clickPkCallback,
            ),
          ),
        ),
        Positioned(
            right: 8,
            top: 72 + MediaQuery.of(context).padding.top,
            child: Visibility(
              visible: _isPK, // _isPK,
              child: true
                  ? Container(
                      padding: const EdgeInsets.only(
                        left: 2.0,
                        right: 6.0,
                        top: 2.0,
                        bottom: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.color_ff0C0C0D,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child:
                                (_peer?.icon != null && _peer!.icon!.length > 0)
                                    ? Image.network(
                                        _peer!.icon!,
                                        height: 24,
                                        width: 24,
                                      )
                                    : Image.asset(
                                        AssetName.iconAvatar,
                                        height: 24,
                                        width: 24,
                                      ),
                          ),
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 100, // 最大宽度
                            ),
                            margin: const EdgeInsets.only(left: 4),
                            child: Text(
                              _peer?.userName ?? "",
                              maxLines: 1,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
            )),
      ],
    );
  }

  late List<Model> _moreModel;

  ///bottom view click callback
  void tapCallBack(int index) {
    print('click position button ' + index.toString());
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
            return const BeautySettingView();
          });
    }
  }

  /// choose author to Pk call back
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
      'camera',
      'voice',
      'ear back',
      'flip',
      'filter',
      'end'
    ];
    return list;
  }

  ///bottom More view click callback
  void tapToolMoreCallBack(Model model) {
    print('click  button ' +
        model.itemIndex.toString() +
        model.itemSelected.toString());
    if (model.itemIndex == 0) {
      // camera
      if (model.itemSelected) {
        NELiveKit.instance.mediaController.disableLocalVideo();
      } else {
        NELiveKit.instance.mediaController.enableLocalVideo().then((value) {
          if (Platform.isIOS) {
            widget.isBackCamera = false;
          }
        });
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
            ToastUtils.showToast(context, value.msg);
            model.itemSelected = true;
            setState(() {});
          }
        });
      } else {
        NELiveKit.instance.mediaController.disableEarBack();
      }
    } else if (model.itemIndex == 3) {
      // flip
      NELiveKit.instance.mediaController
          .switchCamera()
          .then((value) => widget.isBackCamera = !widget.isBackCamera);
    } else if (model.itemIndex == 4) {
      // filter
      NavUtils.pop(context);
      DialogUtils.showChildNavigatorPopup(context, const FilterSettingView());
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

  ///handleStartPkButtonCallback
  void _handleStartPkButtonCallback() {
    // _showLivePkMemberInvitingView = true;
    NELivePKStatus pkState = NELiveKit.instance.pkStatus;
    if (pkState == NELivePKStatus.idle) {
      if (_showInvitingProcessView) {
        ToastUtils.showToast(context, Strings.startFailByInPkList);
      } else {
        setState(() {
          _showLivePkMemberInvitingView = true;
        });
      }
    } else if (pkState == NELivePKStatus.pking ||
        pkState == NELivePKStatus.punishing) {
      //TODO alert
    } else if (pkState == NELiveStatus.inviting) {
      ToastUtils.showToast(context, Strings.startFailByInPkList);
    }
  }

  void _handleEndPkButtonCallback() {
    NELivePKStatus pkState = NELiveKit.instance.pkStatus;
    if (pkState == NELivePKStatus.pking ||
        pkState == NELivePKStatus.punishing) {
      _showEndPkDialog = true;
      DialogUtils.commonShowCupertinoDialog(
          context, Strings.endPKTitle, Strings.endPKContent, () {
        //cancel
        _showEndPkDialog = false;
      }, () {
        //accept
        _showEndPkDialog = false;
        NELiveKit.instance.stopPK();
        //TODO 刷新布局
      }, sure: Strings.endPKRightNow);
    }
  }

  /// choose author to Pk call back
  void clickPkCallback(NELiveDetail item) {
    setState(() {
      _showLivePkMemberInvitingView = false;
    });
    _showInvitePkDialog = true;
    DialogUtils.showInvitePKDialog(context, item.anchor!.userName!, () {
      //cancel
      _showInvitePkDialog = false;
    }, () {
      _showInvitePkDialog = false;
      _anchorDetail = item;
      confirmInvitePK(item);
    });
  }

  void confirmInvitePK(NELiveDetail item) {
    setState(() {
      _showInvitingProcessView = false;
    });
    NELivePKRule rule = NELivePKRule();
    rule.agreeTaskTime = 10;
    NELiveKit.instance.invitePK(item.anchor!.userUuid!, rule).then((value) {
      if (value.code == 0) {
        setState(() {
          inviterUsername = item.anchor!.userName;
          _showInvitingProcessView = true;
        });
      } else {
        ToastUtils.showToast(
          context,
          TextUtils.isNotEmpty(value.msg) ? value.msg : Strings.invitePKFailed,
        );
      }
    });
  }

  void commonShowCupertinoDialog(String title, String content,
      VoidCallback cancelCallback, VoidCallback acceptCallback,
      {String sure = Strings.sure, String cancel = Strings.cancel}) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                child: Text(cancel),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  cancelCallback();
                },
              ),
              TextButton(
                child: Text(sure),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  acceptCallback();
                },
              ),
            ],
          );
        });
  }

  ///click area callback
  _touchAreaClickCallback() {
    setState(() {
      _showLivePkMemberInvitingView = false;
    });
  }

  Widget buildPKVideoView(String userUuid) {
    return Visibility(
        child: // _isPK
            Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 50, // 50%
                child: Center(
                  child: Stack(
                    children: [
                      localRenderer == null
                          ? Container(
                              color: Colors.orange,
                            )
                          : Center(
                              child: NERtcVideoView(localRenderer!,
                                  fitType: NERtcVideoViewFitType.contain)),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: handleResultFlag(true),
                      ),
                    ],
                  ),
                )),
            Expanded(
                flex: 50, // 50%
                child: Center(
                  child: Stack(
                    children: [
                      remoteRenderer == null
                          ? Container(
                              color: Colors.pink,
                            )
                          : Center(
                              child: NERtcVideoView(remoteRenderer!,
                                  fitType: NERtcVideoViewFitType.contain)),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: handleResultFlag(false),
                      ),
                      Positioned(
                        ///sound mute
                        right: 10,
                        bottom: 10,
                        height: 25,
                        width: 25,
                        child: Visibility(
                          visible: _isPK,
                          child: GestureDetector(
                            child: _isOtherSoundOn
                                ? Image.asset(AssetName.iconLiveSoundOpen)
                                : Image.asset(AssetName.iconLiveSoundMute),
                            onTap: () {
                              if (_isOtherSoundOn) {
                                NELiveKit.instance.mediaController
                                    .disablePeerAudio();
                              } else {
                                NELiveKit.instance.mediaController
                                    .enablePeerAudio();
                              }
                              NELiveKit.instance;
                              setState(() {
                                _isOtherSoundOn = !_isOtherSoundOn;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
          ],
        ),
        visible: _isPK // _isPK,
        );
  }

  void initSingleVideoView() {
    initLocalVideoView();
  }

  Future<void> initPKVideoView(String? userUuid) async {
    releaseLocalVideoView();
    initLocalVideoView();
    initRemoteVideoView(userUuid);
  }

  void recoverSingleVideoView() {
    releaseRemoteVideoView();
    releaseLocalVideoView();
    initLocalVideoView();
  }

  Future<void> initLocalVideoView() async {
    localRenderer =
        await VideoRendererFactory.createVideoRenderer(_anchorRoomUUid!);
    await localRenderer!.attachToLocalVideo();
    if (Platform.isAndroid) {
      localRenderer!.setMirror(true);
    }
    setState(() {});
  }

  Future<void> releaseLocalVideoView() async {
    var tempRender = localRenderer;
    setState(() {
      localRenderer = null;
    });
    tempRender?.dispose();
  }

  Future<void> initRemoteVideoView(String? userUuid) async {
    if (userUuid != null && _isPK) {
      remoteRenderer =
          await VideoRendererFactory.createVideoRenderer(_anchorRoomUUid!);
      await remoteRenderer!.attachToRemoteVideo(userUuid);
      remoteRenderer!.setMirror(true);
    }
    setState(() {});
  }

  Future<void> releaseRemoteVideoView() async {
    var tempRender = remoteRenderer;
    setState(() {
      remoteRenderer = null;
    });
    tempRender?.dispose();
  }

  Widget handleResultFlag(bool isSelf) {
    String resultImg = "";
    if (_showPKResult) {
      switch (_anchorSuccess) {
        case pkResultFailed:
          resultImg = isSelf ? AssetName.iconPKFail : AssetName.iconPKSuccess;
          break;
        case pkResultSuccess:
          resultImg = isSelf ? AssetName.iconPKSuccess : AssetName.iconPKFail;
          break;
        case pkResultDraw:
          resultImg = AssetName.iconPKDraw;
          break;
      }
      return Image.asset(
        resultImg,
        width: 120,
        height: 120,
      );
    } else {
      return Container();
    }
  }

  void _refreshAudiencePortrait() {
    NELiveKit.instance
        .fetchChatRoomMembers(NEChatroomMemberQueryType.kGuestDesc, 10)
        .then((value) {
      _audienceAvatarList.clear();
      value.data?.forEach((element) {
        _audienceAvatarList.add(element.avatar ?? '');
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
    localRenderer?.dispose();
    remoteRenderer?.dispose();
    if (widget.isBackCamera) {
      NELiveKit.instance.mediaController.switchCamera();
    }
    NELiveKit.instance.removeEventCallback(_callback);
    NELiveKit.instance.stopLive();
  }
}
