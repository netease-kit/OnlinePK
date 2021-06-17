package com.netease.biz_live.yunxin.live.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.blankj.utilcode.util.NetworkUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.utils.StringUtils;
import com.netease.biz_live.yunxin.live.chatroom.ChatRoomMsgCreator;
import com.netease.biz_live.yunxin.live.chatroom.custom.AnchorCoinChangedAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PkStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PunishmentStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.model.AudienceInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.RewardGiftInfo;
import com.netease.biz_live.yunxin.live.constant.ErrorCode;
import com.netease.biz_live.yunxin.live.constant.LiveTimeDef;
import com.netease.biz_live.yunxin.live.constant.LiveType;
import com.netease.biz_live.yunxin.live.dialog.AnchorListDialog;
import com.netease.biz_live.yunxin.live.dialog.AudienceConnectDialog;
import com.netease.biz_live.yunxin.live.dialog.ChoiceDialog;
import com.netease.biz_live.yunxin.live.liveroom.AnchorPk;
import com.netease.biz_live.yunxin.live.liveroom.AnchorPkDelegate;
import com.netease.biz_live.yunxin.live.liveroom.AnchorSeatDelegate;
import com.netease.biz_live.yunxin.live.liveroom.AnchorSeatManager;
import com.netease.biz_live.yunxin.live.liveroom.LiveRoomCallback;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAnchorBaseLiveRoomDelegate;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAnchorLiveRoom;
import com.netease.biz_live.yunxin.live.liveroom.NERTCLiveRoom;
import com.netease.biz_live.yunxin.live.liveroom.msg.PkInfo;
import com.netease.biz_live.yunxin.live.liveroom.state.LiveState;
import com.netease.biz_live.yunxin.live.model.JoinInfo;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;
import com.netease.biz_live.yunxin.live.model.message.MsgPkStart;
import com.netease.biz_live.yunxin.live.model.message.MsgPunishStart;
import com.netease.biz_live.yunxin.live.model.message.MsgReward;
import com.netease.biz_live.yunxin.live.model.response.AnchorQueryInfo;
import com.netease.biz_live.yunxin.live.network.LiveInteraction;
import com.netease.biz_live.yunxin.live.ui.widget.AnchorActionView;
import com.netease.biz_live.yunxin.live.ui.widget.LinkSeatsAudienceRecycleView;
import com.netease.biz_live.yunxin.live.ui.widget.PKControlView;
import com.netease.biz_live.yunxin.live.ui.widget.PKVideoView;
import com.netease.biz_live.yunxin.live.utils.ClickUtils;
import com.netease.lava.nertc.sdk.NERtcOption;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.ResponseCode;
import com.netease.nimlib.sdk.avsignalling.builder.InviteParamBuilder;
import com.netease.nimlib.sdk.avsignalling.event.InvitedEvent;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.android.lib.picture.ImageLoader;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.demo.basic.BuildConfig;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.annotations.NonNull;
import io.reactivex.observers.ResourceSingleObserver;

/**
 * 互动直播主播直播页面
 */
public class InteractionLiveActivity extends LiveBaseActivity implements NERTCAnchorBaseLiveRoomDelegate, AnchorPkDelegate {

    private static final String LOG_TAG = "NERTCLiveRoomImpl";

    private PKControlView pkControlView;

    private ImageView ivPkRequest;

    private LinearLayout llyPkProgress;

    //主播操作条
    private AnchorActionView anchorActionView;

    private boolean isReceiver;//是否是PK接受者

    /**
     * 连麦相关回调
     */
    private AnchorSeatDelegate seatDelegate;


    /**
     * pk直播信息
     */
    private LiveInfo pkLiveInfo;

    private ChoiceDialog pkRequestDialog;

    private ChoiceDialog pkInviteedDialog;

    private ChoiceDialog stopPkDialog;

    private AnchorListDialog anchorListDialog;

    private PKControlView.WrapperCountDownTimer countDownTimer;

    private PKVideoView pkVideoView;

    private AnchorPk pkService;

    private AnchorSeatManager seatManager;

    private LinkSeatsAudienceRecycleView seatsView;


    public static void startAnchorActivity(Context context) {
        context.startActivity(new Intent(context, InteractionLiveActivity.class));
    }

    @Override
    protected void initContainer() {
        LayoutInflater.from(this).inflate(R.layout.pk_live_anchor_layout,flyContainer,true);
        pkControlView = findViewById(R.id.pk_control_view);
        llyPkProgress = findViewById(R.id.lly_pk_progress);
        ivPkRequest = findViewById(R.id.iv_request_pk);
        seatsView = findViewById(R.id.audience_seats_view);
        anchorActionView = findViewById(R.id.view_action);
        seatsView.setUseScene(LinkSeatsAudienceRecycleView.UseScene.ANCHOR);
    }

    protected void setListener(){
        super.setListener();
        ivConnect.setOnClickListener(view -> showConnectDialog());
        ivPkRequest.setOnClickListener(v -> {
            if (pkService.getLiveCurrentState().getStatus() == LiveState.STATE_LIVE_ON) {
                showAnchorListDialog();
            } else if (pkService.getLiveCurrentState().getStatus() == LiveState.STATE_PKING) {
                showStopPkDialog();
            } else {
                ToastUtils.showShort("正在连线中，请取消后再试");
                ALog.d(LOG_TAG, "state error status = " + pkService.getLiveCurrentState().getStatus());
            }
        });
    }

    @Override
    protected void initData() {
        super.initData();
        initSeatDelegate();
        liveRoom.setDelegate(this);
        pkService = liveRoom.getService(AnchorPk.class);
        seatManager = liveRoom.getService(AnchorSeatManager.class);
        //添加网络监听回调
        NetworkUtils.registerNetworkStatusChangedListener(new NetworkUtils.OnNetworkStatusChangedListener() {
            @Override
            public void onDisconnected() {
                ALog.i(LOG_TAG, "network disconnected");
            }

            @Override
            public void onConnected(NetworkUtils.NetworkType networkType) {
                ALog.i(LOG_TAG, "network onConnected");
                fetchSeatsInfo();
            }
        });
    }

    /**
     * 展示连麦dialog
     */
    private void showConnectDialog() {
        if (ClickUtils.isFastClick()) {
            return;
        }
        redPoint.setVisibility(View.GONE);
        anchorActionView.hide();
        AudienceConnectDialog audienceConnectDialog = new AudienceConnectDialog();
        Bundle bundle = new Bundle();
        bundle.putString(AudienceConnectDialog.ROOM_ID, liveInfo.liveCid);
        audienceConnectDialog.setArguments(bundle);
        audienceConnectDialog.show(getSupportFragmentManager(), "audienceConnectDialog");
    }

    /**
     * 同步麦位信息
     */
    private void fetchSeatsInfo() {
        if (liveInfo == null) {
            return;
        }
        LiveInteraction.queryAnchorRoomInfo(liveInfo.accountId, liveInfo.liveCid).subscribe(
                new ResourceSingleObserver<BaseResponse<AnchorQueryInfo>>() {
                    @Override
                    public void onSuccess(@NonNull BaseResponse<AnchorQueryInfo> response) {
                        if (response.isSuccessful()) {
                            AnchorQueryInfo queryInfo = response.data;
                            List<SeatMemberInfo> tempMembers = new ArrayList<>(seatsView.getMemberList());
                            if (queryInfo.seatList != null && queryInfo.seatList.size() > 0) {
                                //已经不再麦位的观众下麦
                                for (SeatMemberInfo member : tempMembers) {
                                    if (!queryInfo.seatList.contains(member)) {
                                        onUserExitSeat(member);
                                    }
                                }

                                //现有麦位上的观众上麦
                                List<Long> uids = new ArrayList<>();
                                for (SeatMemberInfo member : queryInfo.seatList) {
                                    if (!seatsView.contains(member.accountId)) {
                                        onUserEnterSeat(member);
                                    }
                                    uids.add(member.avRoomUid);
                                }
                                //更新推流信息
                                seatManager.updateSeatsStream(uids);
                            } else {
                                //观众全部下麦
                                for (SeatMemberInfo member : tempMembers) {
                                    onUserExitSeat(member);
                                }
                                seatManager.updateSeatsStream(null);
                            }
                        } else if (response.code == ErrorCode.CREATE_LIVE_NOT_EXIST) {
                            //直播间已经关闭，销毁当前页面
                            finish();
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {

                    }
                }
        );
    }

    /**
     * 初始化麦位相关回调
     */
    private void initSeatDelegate() {
        seatDelegate = new AnchorSeatDelegate() {
            @Override
            public void onSeatApplyRequest(int index, SeatMemberInfo member) {
                if (!isConnectDialogShowing()) {
                    showAudienceApply();
                    redPoint.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void onSeatApplyRequestCanceled(SeatMemberInfo member) {

            }

            @Override
            public void onSeatPickRejected(SeatMemberInfo member) {
                ToastUtils.showLong(R.string.biz_live_audience_reject_link_seats_invited);
            }

            @Override
            public void onSeatEntered(SeatMemberInfo member) {
                onUserEnterSeat(member);
            }

            @Override
            public void onSeatLeft(SeatMemberInfo member) {
                onUserExitSeat(member);
            }

            @Override
            public void onSeatMuteStateChanged(SeatMemberInfo member) {
                seatsView.updateItem(member);
            }
        };
    }

    /**
     * 用户上麦
     *
     * @param member
     */
    private void onUserEnterSeat(SeatMemberInfo member) {
        seatsView.appendItem(member);
        ivPkRequest.setVisibility(View.GONE);
        roomMsgView.appendItem(ChatRoomMsgCreator.createSeatEnter(member.nickName));
    }

    /**
     * 用户离开麦位
     *
     * @param member
     */
    private void onUserExitSeat(SeatMemberInfo member) {
        seatsView.remove(member);
        roomMsgView.appendItem(ChatRoomMsgCreator.createSeatExit(member.nickName));
        if (!seatsView.haveMemberInSeats()) {
            ivPkRequest.setVisibility(View.VISIBLE);
        }
    }

    /**
     * 取消邀请
     */
    private void cancelRequest() {
        pkService.cancelPkRequest(new RequestCallback<Void>() {
            @Override
            public void onSuccess(Void param) {
                cancelSuccess();
            }

            @Override
            public void onFailed(int code) {
                if (code != ResponseCode.RES_INVITE_HAS_ACCEPT) {
                    cancelSuccess();
                } else {
                    ToastUtils.showShort("对方已经接受，请稍等");
                }
            }

            @Override
            public void onException(Throwable exception) {
                cancelSuccess();
            }
        }, true);
    }

    /**
     * 取消成功
     */
    private void cancelSuccess() {
        anchorActionView.hide();
        if (pkRequestDialog != null && pkRequestDialog.isShowing()) {
            pkRequestDialog.dismiss();
        }
    }


    protected void initLiveRoom(NERtcOption option) {
        liveRoom = (NERTCAnchorLiveRoom) NERTCLiveRoom.sharedInstance(true);
        liveRoom.init(this, BuildConfig.APP_KEY, option);
        liveRoom.enableLocalVideo(true);
        liveRoom.setupLocalView(videoView);
    }

    protected void createLiveRoom(int type, String requestAccId, String requestNickname) {
        preview.setCreateEnable(false);
        String accId = ModuleServiceMgr.getInstance().getService(UserCenterService.class).getCurrentUser().accountId;
        String topic = type == LiveType.PK_LIVING ? "" : preview.getTopic();
        String parentLiveCid = type == LiveType.PK_LIVING ? liveInfo.liveCid : "";
        LiveInteraction.createLiveRoom(accId, topic, parentLiveCid, preview.getLiveCoverPic(), type).subscribe(new ResourceSingleObserver<BaseResponse<LiveInfo>>() {
            @Override
            public void onSuccess(BaseResponse<LiveInfo> response) {
                if (response.code == 200) {
                    if (type == LiveType.PK_LIVING) {
                        pkLiveInfo = response.data;
                        ALog.i(LOG_TAG, "pk liveCid = " + pkLiveInfo.liveCid);
                        startPkLive(requestAccId, requestNickname);
                    } else {
                        liveInfo = response.data;
                        ALog.i(LOG_TAG, "single liveCid = " + liveInfo.liveCid);
                        joinChatRoom(liveInfo);
                    }
                } else {
                    ToastUtils.showShort("网络错误： " + response.msg);
                }

            }

            @Override
            public void onError(Throwable e) {
                ToastUtils.showShort("网络错误");
            }
        });
    }


    private void startPkLive(String requestAccid, String requestNickname) {
        if (pkLiveInfo == null) {
            return;
        }
        if (pkRequestDialog == null) {
            pkRequestDialog = new ChoiceDialog(this)
                    .setTitle("邀请PK")
                    .setNegative("取消", null);
            pkRequestDialog.setCancelable(false);
        }
        pkRequestDialog.setContent("确定邀请" + "“" + requestNickname + "”" + "进行PK？")
                .setPositive("确定", v -> {
                    isReceiver = false;
                    pkService.requestPk(pkLiveInfo.imAccid, requestAccid, pkLiveInfo.liveCid, pkLiveInfo.liveConfig.pushUrl, pkLiveInfo.nickname, new LiveRoomCallback<Void>() {
                        @Override
                        public void onSuccess() {
                            anchorActionView.setText("邀请“" + requestNickname + "”PK连线中…")
                                    .setColorButton("取消", v1 -> {
                                        cancelRequest();
                                    }).show();

                        }

                        @Override
                        public void onError(int code, String msg) {
                            ToastUtils.showShort("邀请失败 code：" + code);
                        }
                    });
                });
        if (!pkRequestDialog.isShowing()) {
            pkRequestDialog.show();
        }
    }


    /**
     * 接受请求
     */
    private void acceptPKRequest(InvitedEvent invitedEvent, PkInfo pkInfo) {
        pkService.acceptPk(pkInfo.pkLiveCid, invitedEvent.getFromAccountId(), invitedEvent.getRequestId(),
                invitedEvent.getToAccountId(), new LiveRoomCallback<Void>() {
                    @Override
                    public void onSuccess() {
                        llyPkProgress.setVisibility(View.VISIBLE);
                        //禁止连麦
                        ivConnect.setEnabled(false);
                    }

                    @Override
                    public void onError(int code, String msg) {

                    }
                });
    }

    /**
     * 拒绝邀请
     *
     * @param invitedEvent
     */
    private void rejectPkRequest(InvitedEvent invitedEvent) {
        InviteParamBuilder paramBuilder = new InviteParamBuilder(invitedEvent.getChannelBaseInfo().getChannelId(),
                invitedEvent.getFromAccountId(), invitedEvent.getRequestId());
        pkService.rejectPkRequest(paramBuilder, new LiveRoomCallback<Void>() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onError(int code, String msg) {

            }
        });
    }

    private void stopPk() {
        LiveInteraction.stopPk(liveInfo.liveCid).subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
            @Override
            public void onSuccess(BaseResponse<Boolean> booleanBaseResponse) {
                if (booleanBaseResponse.code != 200) {
                    ToastUtils.showShort("网络错误 code = " + booleanBaseResponse.code);
                }
            }

            @Override
            public void onError(Throwable e) {
                ToastUtils.showShort("stop pk error");
            }
        });
    }

    /**
     * 结束PK dialog
     */
    private void showStopPkDialog() {
        if (stopPkDialog == null) {
            stopPkDialog = new ChoiceDialog(this);
            stopPkDialog.setTitle("结束PK");
            stopPkDialog.setContent("PK尚未结束，强制结束后会返回普通直播模式");
            stopPkDialog.setPositive("立即结束", v -> stopPk());
            stopPkDialog.setNegative("取消", null);
        }

        stopPkDialog.show();
    }

    /**
     * 展示主播列表供选择
     */
    private void showAnchorListDialog() {
        if (anchorListDialog != null && anchorListDialog.isVisible()) {
            return;
        }
        if (anchorListDialog == null) {
            anchorListDialog = new AnchorListDialog();
        }
        anchorListDialog.setSelectAnchorListener(liveInfo -> {
            isReceiver = false;
            createLiveRoom(LiveType.PK_LIVING, liveInfo.imAccid, liveInfo.nickname);
        });
        anchorListDialog.show(getSupportFragmentManager(), "anchorListDialog");
    }



    private void showAudienceApply(){
        if(!anchorActionView.isShowing()) {
            anchorActionView.setText("收到新的连麦申请")
                    .setBlackButton(true, "忽略", v -> {
                        //产品需求修改，不消失小红点
//                        redPoint.setVisibility(View.GONE);
                    })
                    .setColorButton("点击查看", v -> showConnectDialog())
                    .show();
        }
    }


    @Override
    public void onPkStart(MsgPkStart.StartPkBody startPKBody) {
        llyPkProgress.setVisibility(View.GONE);
        String otherNickname;
        String otherAvatar;
        long otherUid;
        if (isReceiver) {
            otherAvatar = startPKBody.inviterAvatar;
            otherNickname = startPKBody.inviterNickname;
            otherUid = startPKBody.inviterRoomUid;
        } else {
            otherAvatar = startPKBody.inviteeAvatar;
            otherNickname = startPKBody.inviteeNickname;
            otherUid = startPKBody.inviteeRoomUid;
        }
        PkStatusAttachment attachment = new PkStatusAttachment(startPKBody.pkStartTime, startPKBody.currentTime, otherNickname, otherAvatar);
        anchor.notifyPkStatus(attachment);


        ImageLoader.with(this).circleLoad(R.drawable.icon_stop_pk, ivPkRequest);
        if (pkVideoView == null) {
            pkVideoView = new PKVideoView(this);
        }
        pkControlView.getVideoContainer().removeAllViews();
        pkControlView.getVideoContainer().addView(pkVideoView);
        liveRoom.setupLocalView(pkVideoView.getLocalVideo());
        liveRoom.setupRemoteView(pkVideoView.getRemoteVideo(), otherUid, true);
        pkVideoView.getRemoteVideo().setMirror(true);
        videoView.setVisibility(View.GONE);
        pkControlView.setVisibility(View.VISIBLE);
        // pk 控制状态重置
        pkControlView.reset();

        // 更新对方主播信息
        pkControlView.updatePkAnchorInfo(otherNickname, otherAvatar);
        // 开始定时器
        if (countDownTimer != null) {
            countDownTimer.stop();
        }
        countDownTimer = pkControlView.createCountDownTimer(LiveTimeDef.TYPE_PK, attachment.getLeftTime(LiveTimeDef.TOTAL_TIME_PK, 0));
        countDownTimer.start();
        //禁止连麦
        ivConnect.setEnabled(false);
    }


    @Override
    public void onPunishStart(MsgPunishStart.PunishBody punishBody) {
        // 发送 pk 结束消息
        int anchorWin;// 当前主播是否 pk 成功
        if(punishBody.inviteeRewards == punishBody.inviterRewards){
            anchorWin = 0;
        } else if (isReceiver) {
            anchorWin = punishBody.inviteeRewards > punishBody.inviterRewards?1:-1;
        } else {
            anchorWin = punishBody.inviteeRewards < punishBody.inviterRewards?1:-1;
        }
        // 展示pk结果
        pkControlView.handleResultFlag(true, anchorWin);

        anchor.notifyPkStatus(new PkStatusAttachment(anchorWin));
        // 发送 惩罚开始消息
        PunishmentStatusAttachment attachment1 = new PunishmentStatusAttachment(punishBody.pkPulishmentTime, punishBody.currentTime,anchorWin);
        anchor.notifyPunishmentStatus(attachment1);
        // 惩罚开始倒计时
        if (countDownTimer != null) {
            countDownTimer.stop();
        }
        if(anchorWin != 0) {
            countDownTimer = pkControlView.createCountDownTimer(LiveTimeDef.TYPE_PUNISHMENT, attachment1.getLeftTime(LiveTimeDef.TOTAL_TIME_PUNISHMENT, 0));
            countDownTimer.start();
        }
    }

    @Override
    public void onPkEnd(boolean isFromUser, String nickname) {
        anchor.notifyPunishmentStatus(new PunishmentStatusAttachment());
        if (countDownTimer != null) {
            countDownTimer.stop();
        }
        ImageLoader.with(this).circleLoad(R.drawable.icon_pk, ivPkRequest);
        pkControlView.getVideoContainer().removeAllViews();
        pkControlView.setVisibility(View.GONE);
        videoView.setVisibility(View.VISIBLE);
        liveRoom.setupLocalView(videoView);
        if (isFromUser && (pkLiveInfo == null || !TextUtils.equals(nickname, pkLiveInfo.nickname))) {
            ToastUtils.showShort("“" + nickname + "”结束了PK");
        }
        if (stopPkDialog != null && stopPkDialog.isShowing()) {
            stopPkDialog.dismiss();
        }
        //打开连麦
        ivConnect.setEnabled(true);
    }

    @Override
    public void onPkRequestCancel(boolean byUser) {
        if (pkInviteedDialog != null && pkInviteedDialog.isShowing()) {
            pkInviteedDialog.dismiss();
            if (byUser) {
                ToastUtils.showShort("对方取消邀请");
            } else {
                ToastUtils.showShort("接听超时");
            }
        }
    }

    @Override
    public void receivePkRequest(InvitedEvent invitedEvent, PkInfo pkInfo) {
        isReceiver = true;
        if (pkLiveInfo == null) {
            pkLiveInfo = new LiveInfo();
        }
        pkLiveInfo.liveCid = pkInfo.pkLiveCid;
        if (pkInviteedDialog == null) {
            pkInviteedDialog = new ChoiceDialog(this)
                    .setTitle("邀请PK");
            pkInviteedDialog.setCancelable(false);
        }
        pkInviteedDialog.setContent("“" + pkInfo.inviterNickname + "”" + "邀请你进行PK，是否接受？")
                .setPositive("接受", v -> acceptPKRequest(invitedEvent, pkInfo))
                .setNegative("拒绝", v -> rejectPkRequest(invitedEvent));
        if (!pkInviteedDialog.isShowing()) {
            pkInviteedDialog.show();
        }
        if (anchorListDialog != null && anchorListDialog.isVisible()) {
            anchorListDialog.dismiss();
        }
        if (pkRequestDialog != null && pkRequestDialog.isShowing()) {
            pkRequestDialog.dismiss();
        }
    }

    @Override
    public void pkRequestRejected(String userId) {
        ToastUtils.showShort("对方拒绝了你的PK邀请");
        anchorActionView.hide();
    }

    @Override
    public void onAccept() {
        anchorActionView.hide();
        llyPkProgress.setVisibility(View.VISIBLE);
        //禁止连麦
        ivConnect.setEnabled(false);
    }


    @Override
    public void onUserReward(MsgReward.RewardBody reward) {
        if (pkService.getLiveCurrentState().getStatus() == LiveState.STATE_PKING) {
            long selfPkCoinCount;
            long otherPkCoinCount;
            long rewardCoinTotal;
            List<AudienceInfo> selfRewardPkList;
            List<AudienceInfo> otherRewardPkList;
            if (isReceiver) {
                selfPkCoinCount = reward.inviteeRewardPKCoinTotal;
                otherPkCoinCount = reward.inviterRewardPKCoinTotal;
                rewardCoinTotal = reward.inviteeRewardCoinTotal;
                selfRewardPkList = reward.inviteeRewardPkList;
                otherRewardPkList = reward.rewardPkList;
            } else {
                selfPkCoinCount = reward.inviterRewardPKCoinTotal;
                otherPkCoinCount = reward.inviteeRewardPKCoinTotal;
                rewardCoinTotal = reward.rewardCoinTotal;
                selfRewardPkList = reward.rewardPkList;
                otherRewardPkList = reward.inviteeRewardPkList;
            }
            // pk 时收到打赏消息发送
            AnchorCoinChangedAttachment attachment2 = new AnchorCoinChangedAttachment(
                    reward.fromUserAvRoomUid,
                    rewardCoinTotal,
                    new RewardGiftInfo((int) reward.giftId, reward.nickname), selfPkCoinCount,
                    otherPkCoinCount, selfRewardPkList, otherRewardPkList);
            anchor.notifyCoinChanged(attachment2);

            pkControlView.updateScore(selfPkCoinCount, otherPkCoinCount);
            pkControlView.updateRanking(selfRewardPkList, otherRewardPkList);
            tvCoinCount.setText(StringUtils.getCoinCount(rewardCoinTotal));
        } else {
            super.onUserReward(reward);
        }
    }

    @Override
    public <T> T getDelegateService(Class<T> tClass) {
        if(tClass.equals(AnchorPkDelegate.class)){
            return (T) this;
        }
        if(tClass.equals(AnchorSeatDelegate.class)) return (T) seatDelegate;
        return null;
    }

    @Override
    public void preJoinRoom(String liveCid, boolean isPk, String parentLiveCid) {
        if (TextUtils.isEmpty(liveCid) || !isPk) {
            liveCid = liveInfo.liveCid;
        }
        ALog.i(LOG_TAG, "preJoinRoom liveCid = " + liveCid + "\n status = " + pkService.getLiveCurrentState().getStatus());
        LiveInteraction.joinLiveRoom(liveCid, parentLiveCid, isPk ? 3 : 2).subscribe(new ResourceSingleObserver<BaseResponse<JoinInfo>>() {
            @Override
            public void onSuccess(BaseResponse<JoinInfo> joinInfoBaseResponse) {
                ALog.i(LOG_TAG, "preJoinRoom sucess code = " + joinInfoBaseResponse.code);
                if (joinInfoBaseResponse.code == 200) {
                    JoinInfo joinInfo = joinInfoBaseResponse.data;
                    liveRoom.joinRtcChannel(joinInfo.avRoomCheckSum, joinInfo.avRoomCName, joinInfo.avRoomUid, joinInfo.avRoomCid);
                } else {
                    ToastUtils.showShort("preJoinRoom failed error code =" + joinInfoBaseResponse.code);
                    preJoinError();
                }
            }

            @Override
            public void onError(Throwable e) {
                ALog.w(LOG_TAG, "preJoinRoom error ", e);
                preJoinError();
            }
        });
    }

    /**
     * 预占位接口访问失败处理逻辑
     */
    private void preJoinError() {
        //单主播切换到pk的场景,保留单主播场景
        if (pkService.getLiveCurrentState().getStatus() != LiveState.STATE_PKING) {
            pkService.getLiveCurrentState().release();
            llyPkProgress.setVisibility(View.GONE);
            ToastUtils.showShort("进入PK直播失败");
        } else {
            ToastUtils.showShort("服务器异常");
            finish();
        }
    }

    @Override
    public void onTimeOut(int code) {
        if (code == ErrorCode.ERROR_CODE_TIME_OUT_ACCEPTED) {
            preJoinError();
            return;
        }
        if (isReceiver) {
            isReceiver = false;
            if (pkInviteedDialog != null && pkInviteedDialog.isShowing()) {
                pkInviteedDialog.dismiss();
                ToastUtils.showShort("对方无响应");
            }
        } else {
            anchorActionView.hide();
            ToastUtils.showShort("对方未接听，请稍后重试");
        }
    }

    @Override
    public void onUserBusy(String userId) {
        ToastUtils.showShort("对方正在进行PK，请稍后重试");
        anchorActionView.hide();
    }

}
