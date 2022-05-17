// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:livekit_pk/audience/live_err_page.dart';
import 'package:livekit_pk/audience/live_stream_play_widget.dart';
import 'package:livekit_pk/audience/option/live_options.dart';
import 'package:livekit_pk/audience/widget/anchor_info_widget.dart';
import 'package:livekit_pk/audience/widget/audience_total_count_widget.dart';
import 'package:livekit_pk/audience/widget/gift_panel_widget.dart';
import 'package:livekit_pk/audience/widget/right_bottom_options_widget.dart';
import 'package:livekit_pk/nav/nav_utils.dart';
import 'package:livekit_pk/utils/dialog_utils.dart';
import 'package:livekit_pk/widgets/audience_portrait_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:netease_common/src/api_result.dart';
import 'package:netease_roomkit/netease_roomkit.dart';
import 'package:netease_roomkit_interface/netease_roomkit_interface.dart';

import '../anchor/anchor_sub_widget/input_widget.dart';
import '../anchor/anchor_sub_widget/live_pk_gift_process_view.dart';
import '../anchor/anchor_sub_widget/live_pk_timer_count_view.dart';
import '../base/lifecycle_base_state.dart';
import '../values/asset_name.dart';
import '../values/colors.dart';
import '../values/strings.dart';
import '../widgets/chatroom_list_view.dart';
import 'audience_log.dart';

class SingleAudienceWidget extends StatefulWidget {
  final NELiveDetail liveDetail;

  SingleAudienceWidget({Key? key, required this.liveDetail}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // AudienceLog.log("createState");
    return _SingleAudienceWidgetState();
  }
}

class _SingleAudienceWidgetState
    extends LifecycleBaseState<SingleAudienceWidget>
    with TickerProviderStateMixin {
  late StreamSubscription<ConnectivityResult> subscription;

  AnimationController? _lottieController;
  final List _giftAnimalList = [];
  bool _giftAnimalIsRunning = false;
  String? _showLottieAnimal;
  int? _memberNum;
  NELiveCallback? _callback;

  late PageController pageController;

  final ValueNotifier<int> _iconNumListener = ValueNotifier<int>(0);
  var _isPK = false;
  var _anchorSuccess = 0;
  var _showPKResult = false;
  static const int pkResultFailed = -1;
  static const int pkResultSuccess = 1;
  static const int pkResultDraw = 0;
  NELivePKAnchor? _peer;
  bool showLiverErrorPage = false;
  ConnectivityResult? currentNetworkState;

  late VoidCallback listener;

  final List<String> _audienceAvatarList = [];

  final ValueNotifier<GiftModel> _giftListener =
  ValueNotifier<GiftModel>(GiftModel(0, 0));
  final TimeDataController _timeDataController = TimeDataController(TimeDataValue(Strings.pK,1));
  final ValueNotifier<List<String?>?> _leftIconListListener =
  ValueNotifier<List<String?>?>([]);
  final ValueNotifier<List<String?>?> _rightIconListListener =
  ValueNotifier<List<String?>?>([]);

  final ChatroomMessagesController _controller = ChatroomMessagesController();
  final String _tag = "_SingleAudienceWidgetState-";

  String? _anchorUserName;
  String? _anchorIcon;

  final VideoPKStateController _videoPKStateController =
  VideoPKStateController();

  _SingleAudienceWidgetState();

  void _reloadWithDatas() {
    List<NERoomMember>? memberList = NELiveKit.instance.members;
    int? tempIconNum = memberList?.length;
    if (tempIconNum == null || tempIconNum == 0) {
      tempIconNum = 1;
    }
    if (mounted) {
      setState(() {
        _memberNum = tempIconNum! - 1;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    AudienceLog.log(_tag + "initState：" + toStringShort());
    _anchorUserName = widget.liveDetail.anchor?.userName;
    _anchorIcon = widget.liveDetail.anchor?.icon;
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      showLiverErrorPage = result == ConnectivityResult.none;
      if (currentNetworkState == null) {
        currentNetworkState = result;
        AudienceLog.log(_tag + "Audience page currentNetworkState==null");
      }
      if (currentNetworkState != null && currentNetworkState != result) {
        if (currentNetworkState == ConnectivityResult.none) {
          NELiveKit.instance.leaveLive().then((value) {
            NELiveKit.instance.joinLive(widget.liveDetail).then((joinRet) {
              showLiverErrorPage = value.code != 0;
              AudienceLog.log(_tag +
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
          AudienceLog.log(_tag +
              "Audience page currentNetworkState:" +
              result.toString() +
              ",showLiverErrorPage:" +
              showLiverErrorPage.toString());
        }
      }
    });
    NELiveKit.instance.leaveLive().then((value) {
      NELiveKit.instance.joinLive(widget.liveDetail).then((joinRet) {
        if (mounted) {
          _anchorUserName = NELiveKit.instance.liveDetail?.anchor?.userName;
          _anchorIcon = NELiveKit.instance.liveDetail?.anchor?.icon;
          _handleLiveUi(joinRet);
        }
      });
    });

    pageController = PageController(
      initialPage: LiveConfig.audienceSelectIndex,
      keepPage: true,
    );

    _refreshAudiencePortrait();
  }

  @override
  Widget build(BuildContext context) {
    return _buildAudienceLayout(context);
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
              memberNum: _memberNum ?? 0,
            )),
        Positioned(
            right: 8,
            top: 72 + MediaQuery.of(context).padding.top,
            child: Visibility(
                visible: _isPK,
                child: Container(
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
                        child: Image.network(
                          _peer?.icon ??
                              "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201702%2F06%2F20170206204000_eNiGY.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1652948404&t=adb3e855bb7b0d29c9b35973678b094c",
                          height: 24,
                          width: 24,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        child: Text(
                          _peer?.userName ?? "",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )
            )),
        Positioned(
            right: 0,
            left: 0,
            top: 64 + MediaQuery.of(context).padding.top,
            child: Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.123,
                  child: _buildPKVideoView(),
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
            controller: _controller,
          ),
        ),
      ],
    );
  }

  Widget _buildPKVideoView() {
    return Visibility(
        child: // _isPK
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
                flex: 50, // 50%
                child: Container(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _handleResultFlag(true),
                      ),
                    ],
                  ),
                )),
            Flexible(
                flex: 50, // 50%
                child: Container(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _handleResultFlag(false),
                      ),
                    ],
                  ),
                ))
          ],
        ),
        visible: _isPK);
  }

  Widget _handleResultFlag(bool isSelf) {
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
                'say something',
                style: TextStyle(fontSize: 14, color: AppColors.white),
              ),
              onTap: () {
                InputDialog.show(context).then((value) {
                  setState(() {
                    if (TextUtils.isNotEmpty(value)) {
                      NELiveKit.instance.sendTextMessage(value!);
                      _controller.addMessage(ChatroomTextMessage(
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

  Widget _buildAudienceLayout(BuildContext context) {
    LiveErrorType errorType = LiveErrorType.kLiveEnd;
    if (currentNetworkState != null &&
        currentNetworkState == ConnectivityResult.none) {
      errorType = LiveErrorType.kNetwork;
    }
    if (showLiverErrorPage) {
      liveStreamPlayWidgetKey.currentState?.reset();
    }
    return Container(
        color: Colors.black,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Stack(
          children: [
            _buildVideoWidget(),
            _buildLiveErrorWidget(
                showLiverErrorPage, errorType, widget.liveDetail),
            _buildLiveNormalWidget(showLiverErrorPage),
            if (_showLottieAnimal != null)
              Lottie.asset(
                _showLottieAnimal!,
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController
                    ?..duration = composition.duration
                    ..forward();
                },
              ),
          ],
        ));
  }

  @override
  void dispose() {
    AudienceLog.log(_tag + "SingleAudienceWidget dispose" + toStringShort());
    if (_callback != null) {
      NELiveKit.instance.removeEventCallback(_callback!);
    }
    NELiveKit.instance.leaveLive();
    pageController.dispose();
    subscription.cancel();
    _videoPKStateController.dispose();
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
        AudienceLog.log(_tag + "onPageChanged index $index");
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

  Widget _buildLiveErrorWidget(bool showLiverErrorPage, LiveErrorType errorType,
      NELiveDetail liveDetail) {
    if (!showLiverErrorPage) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
    return AudienceLiveErrorPage(
        imageUrl: liveDetail.anchor?.icon ?? '',
        nickname: liveDetail.anchor?.userName ?? '',
        errorType: errorType,
        returnAction: () {
          AudienceLog.log(_tag + "returnAction" + toStringShort());
          NavUtils.pop(context);
        },
        reconnectingAction: () {
          AudienceLog.log(_tag + "reconnectingAction" + toStringShort());
          // network reconnect refresh current ui
          NELiveKit.instance.leaveLive().then((value) {
            NELiveKit.instance.joinLive(widget.liveDetail).then((joinRet) {
              if (mounted) {
                setState(() {});
              }
            });
          });
        });
  }

  _handleLiveUi(NEResult<String?> value) {
    AudienceLog.log(_tag +
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

    _callback = NELiveCallback(
        membersJoin: (List<NERoomMember> members) {
          _handleMembersJoin(members);
        },
        membersLeave: (List<NERoomMember> members) {
          _handleMembersLeave(members);
        },
        messagesReceived: (List<NERoomTextMessage> messages) {
          _handleMessagesReceived(messages);
          AudienceLog.log(_tag + "messagesReceived");
        },
        rewardReceived: (String rewarderUserUuid,
            String? rewarderUserName,
            int giftId,
            NELiveAnchorReward anchorReward,
            NELiveAnchorReward otherAnchorReward) {
          _handleRewardReceived(rewarderUserUuid, rewarderUserName, giftId,
              anchorReward, otherAnchorReward);
        },
        pkStart: (int pkStartTime, int pkCountDown, NELivePKAnchor self,
            NELivePKAnchor peer) {
          _handlePkStart(pkStartTime, pkCountDown, self, peer);
        },
        pkPunishmentStart:
            (int pkPenaltyCountDown, int selfRewards, int peerRewards) {
          _handlePkPunishmentStart(
              pkPenaltyCountDown, selfRewards, peerRewards);
        },
        pkEnded: (int reason, int pkEndTime, String senderUserUuid, String userName,
            int selfRewards, int peerRewards, bool countDownEnd) {
          _handlePkEnded(reason, pkEndTime, senderUserUuid, selfRewards,
              peerRewards, countDownEnd);
        },
        loginKickOut: () {},
        liveEnded: (int reason) {
          _handleLiveEnded(reason);
        });
    NELiveKit.instance.addEventCallback(_callback!);

    AudienceLog.log(_tag + "${toStringShort()} fetchPKInfo");
    var liveRecordId = widget.liveDetail.live!.liveRecordId;
    // query live state
    NELiveKit.instance
        .fetchLiveInfo(liveRecordId)
        .then((value) => _handleGiftReward(value));
    // query pk state
    NELiveKit.instance.fetchPKInfo(liveRecordId).then((pkRet) {
      _handlePkInfo(pkRet);
    });
  }

  _buildVideoWidget() {
    if (showLiverErrorPage) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
    return LiveStreamPlayWidget(
        key: const Key("ss"),
        liveDetail: widget.liveDetail,
        pkStateController: _videoPKStateController,
        playNormal: () {
          showLiverErrorPage = false;
        },
        playError: () {
          AudienceLog.log("playError,mounted:$mounted");
          if (mounted) {
            setState(() {
              showLiverErrorPage = true;
            });
          }
        });
  }

  void _refreshAudiencePortrait() {
    NELiveKit.instance
        .fetchChatRoomMembers(NEChatroomMemberQueryType.kGuestDesc, 10)
        .then((value) {
      _audienceAvatarList.clear();
      value.data?.forEach((element) {
        _audienceAvatarList.add(element.avatar ?? '');
      });
      if (mounted) {
        setState(() {});
      }
    });
  }

  _handleGiftReward(NEResult<NELiveDetail> value) {
    AudienceLog.log(_tag +
        "_handleGiftReward,rewardTotal:${value.data?.live?.rewardTotal}");
    _iconNumListener.value = value.data?.live?.rewardTotal ?? 0;
  }

  void _handleMembersJoin(members) {
    AudienceLog.log(_tag + "membersJoin");
    if (!mounted) {
      return;
    }
    _reloadWithDatas();
    for (var m in members) {
      if (m.uuid == NELiveKit.instance.userUuid) {
        continue;
      }
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
  }

  void _handleMembersLeave(List<NERoomMember> members) {
    AudienceLog.log(_tag + "membersLeave");
    _reloadWithDatas();
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
  }

  void _handleMessagesReceived(List<NERoomTextMessage> messages) {
    for (var m in messages) {
      _controller.addMessage(
        ChatroomTextMessage(
            userUuid: m.fromAccount,
            nickname: m.fromNick,
            text: m.text,
            isAnchor: m.fromAccount ==
                NELiveKit.instance.liveDetail?.anchor?.userUuid),
      );
    }
  }

  void _handleRewardReceived(
      String rewarderUserUuid,
      String? rewarderUserName,
      int giftId,
      NELiveAnchorReward anchorReward,
      NELiveAnchorReward otherAnchorReward) {
    AudienceLog.log(_tag +
        "rewardReceived,anchorReward:${anchorReward.pkRewardTotal}" +
        ",otherAnchorReward:${otherAnchorReward.pkRewardTotal}");
    if (!mounted) {
      return;
    }
    setState(() {
      bool isToSelf = anchorReward.userUuid ==
          NELiveKit.instance.liveDetail?.anchor?.userUuid;
      if (NELiveKit.instance.pkStatus == NELivePKStatus.pking) {
        int leftReward = isToSelf
            ? anchorReward.pkRewardTotal
            : otherAnchorReward.pkRewardTotal;
        List<String?>? leftAvatars =
        isToSelf ? anchorReward.rewardIcons : otherAnchorReward.rewardIcons;
        int rightReward = isToSelf
            ? otherAnchorReward.pkRewardTotal
            : anchorReward.pkRewardTotal;
        List<String?>? rightAvatars =
        isToSelf ? otherAnchorReward.rewardIcons : anchorReward.rewardIcons;
        _giftListener.value = GiftModel(leftReward, rightReward);
        _leftIconListListener.value = leftAvatars;
        _rightIconListListener.value = rightAvatars;
      }
      int coins = anchorReward.rewardTotal;
      if (!isToSelf) {
        coins = otherAnchorReward.rewardTotal;
      }
      _iconNumListener.value = coins;
      AudienceLog.log(_tag + "coins1:$coins");
      if (isToSelf) {
        // to self
        _controller.addMessage(
          ChatroomGiftMessage(
              giftId: giftId,
              userUuid: rewarderUserUuid,
              nickname: rewarderUserName),
        );
        if (giftId == 1) {
          _playAnimal(GiftInfo(1, Strings.biz_live_glow_stick, 9,
              AssetName.gift01, AssetName.lottieGift01));
        } else if (giftId == 2) {
          _playAnimal(GiftInfo(2, Strings.biz_live_arrange, 99,
              AssetName.gift02, AssetName.lottieGift02));
        } else if (giftId == 3) {
          _playAnimal(GiftInfo(3, Strings.biz_live_sports_car, 199,
              AssetName.gift03, AssetName.lottieGift03));
        } else if (giftId == 4) {
          _playAnimal(GiftInfo(4, Strings.biz_live_rockets, 999,
              AssetName.gift04, AssetName.lottieGift04));
        }
      }
    });
  }

  void _handlePkStart(int pkStartTime, int pkCountDown, NELivePKAnchor self,
      NELivePKAnchor peer) {
    AudienceLog.log(_tag +
        "pkStart,pkStartTime:" +
        pkStartTime.toString() +
        ",pkCountDown:" +
        pkCountDown.toString() +
        ",self:" +
        self.userName.toString() +
        ",peer:" +
        peer.userName.toString());
    if (!mounted) {
      return;
    }
    setState(() {
      _leftIconListListener.value = [];
      _rightIconListListener.value = [];
      _peer = peer;
      _isPK = true;
      _videoPKStateController.switchPK!();
      _giftListener.value = GiftModel(0, 0);
      _timeDataController.setTimeDataValue(TimeDataValue(Strings.pK,pkCountDown));
    });
  }

  void _handlePkPunishmentStart(
      int pkPenaltyCountDown, int selfRewards, int peerRewards) {
    AudienceLog.log(_tag +
        "pkStart,pkPenaltyCountDown:" +
        pkPenaltyCountDown.toString() +
        ",selfRewards:" +
        selfRewards.toString() +
        ",peerRewards:" +
        peerRewards.toString());
    if (!mounted) {
      return;
    }
    setState(() {
      _showPKResult = true;
      if (selfRewards == peerRewards) {
        _anchorSuccess = pkResultDraw;
      } else if (selfRewards > peerRewards) {
        _anchorSuccess = pkResultSuccess;
      } else {
        _anchorSuccess = pkResultFailed;
      }
      if (_anchorSuccess == pkResultDraw) {
        ///stop count
        // [self.pkStatusBar stopCountdown];
      } else {
        _timeDataController.setTimeDataValue(TimeDataValue(Strings.punish,pkPenaltyCountDown));
      }
    });
  }

  void _handlePkEnded(int reason, int pkEndTime, String senderUserUuid,
      int selfRewards, int peerRewards, bool countDownEnd) {
    AudienceLog.log(_tag +
        "pkEnded,reason:$reason,pkEndTime:$pkEndTime,selfRewards:$selfRewards,peerRewards:$peerRewards");
    if (!mounted) {
      return;
    }
    setState(() {
      _showPKResult = false;
      _isPK = false;
      _videoPKStateController.switchPkEnd!();
    });
  }

  void _handleLiveEnded(int reason) {
    AudienceLog.log(_tag + "liveEnded,reason:$reason," + toStringShort());
    if (reason == NERoomEndReason.kLeaveBySelf.index || !mounted) {
      return;
    }
    setState(() {
      _showPKResult = false;
      showLiverErrorPage = true;
    });
  }

  void _handlePkInfo(NEResult<NELivePKDetail?> pkRet) {
    if (!mounted) {
      return;
    }
    AudienceLog.log(_tag + "${toStringShort()} want setState");

    setState(() {
      if (pkRet.isSuccess() && pkRet.data != null) {
        if (pkRet.data!.state == NELivePKState.pking ||
            pkRet.data!.state == NELivePKState.punishing) {
          _peer = NELiveKit.instance.isInviter
              ? pkRet.data!.invitee
              : pkRet.data!.inviter;
          _isPK = true;
          _videoPKStateController.switchPK!();
          int leftReward = NELiveKit.instance.isInviter
              ? pkRet.data!.inviterReward!.rewardCoinTotal
              : pkRet.data!.inviteeReward!.rewardCoinTotal;
          List<String?>? leftAvatars = NELiveKit.instance.isInviter
              ? pkRet.data!.inviterReward!.rewardIcons
              : pkRet.data!.inviteeReward!.rewardIcons;
          int rightReward = NELiveKit.instance.isInviter
              ? pkRet.data!.inviteeReward!.rewardCoinTotal
              : pkRet.data!.inviterReward!.rewardCoinTotal;
          List<String?>? rightAvatars = NELiveKit.instance.isInviter
              ? pkRet.data!.inviteeReward!.rewardIcons
              : pkRet.data!.inviterReward!.rewardIcons;
          _giftListener.value = GiftModel(leftReward, rightReward);
          _leftIconListListener.value = leftAvatars;
          _rightIconListListener.value = rightAvatars;
          _timeDataController.setTimeDataValue(TimeDataValue(pkRet.data!.state == NELivePKState.punishing ? Strings.punish:Strings.pK,pkRet.data!.countDown));
          if (pkRet.data!.state == NELivePKState.punishing) {
            _showPKResult = true;
            if (leftReward == rightReward) {
              _anchorSuccess = pkResultDraw;
            } else if (leftReward > rightReward) {
              _anchorSuccess = pkResultSuccess;
            } else {
              _anchorSuccess = pkResultFailed;
            }
          }
        }
      }
    });
  }
}
