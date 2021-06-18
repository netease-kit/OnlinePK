/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom.impl;

import android.content.Context;
import android.os.CountDownTimer;
import android.text.TextUtils;

import com.blankj.utilcode.util.GsonUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.google.gson.JsonObject;
import com.netease.biz_live.yunxin.live.constant.ErrorCode;
import com.netease.biz_live.yunxin.live.liveroom.AnchorPk;
import com.netease.biz_live.yunxin.live.liveroom.AnchorPkDelegate;
import com.netease.biz_live.yunxin.live.liveroom.AnchorSeatDelegate;
import com.netease.biz_live.yunxin.live.liveroom.AnchorSeatManager;
import com.netease.biz_live.yunxin.live.liveroom.LiveRoomCallback;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAnchorBaseLiveRoomDelegate;
import com.netease.biz_live.yunxin.live.liveroom.model.LiveStreamTaskRecorder;
import com.netease.biz_live.yunxin.live.liveroom.msg.ControlInfo;
import com.netease.biz_live.yunxin.live.liveroom.msg.PkInfo;
import com.netease.biz_live.yunxin.live.liveroom.state.AcceptState;
import com.netease.biz_live.yunxin.live.liveroom.state.CalloutState;
import com.netease.biz_live.yunxin.live.liveroom.state.IdleLiveState;
import com.netease.biz_live.yunxin.live.liveroom.state.InvitedState;
import com.netease.biz_live.yunxin.live.liveroom.state.LiveState;
import com.netease.biz_live.yunxin.live.liveroom.state.OffState;
import com.netease.biz_live.yunxin.live.liveroom.state.PkingState;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.biz_live.yunxin.live.model.message.MsgPkEnd;
import com.netease.biz_live.yunxin.live.model.message.MsgPkStart;
import com.netease.biz_live.yunxin.live.model.message.MsgPunishStart;
import com.netease.biz_live.yunxin.live.model.message.MsgReward;
import com.netease.biz_live.yunxin.live.model.message.NotificationMessage;
import com.netease.lava.nertc.impl.RtcCode;
import com.netease.lava.nertc.sdk.NERtcCallback;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.NERtcOption;
import com.netease.lava.nertc.sdk.live.DeleteLiveTaskCallback;
import com.netease.lava.nertc.sdk.stats.NERtcNetworkQualityInfo;
import com.netease.lava.nertc.sdk.stats.NERtcStatsObserver;
import com.netease.lava.nertc.sdk.video.NERtcRemoteVideoStreamType;
import com.netease.lava.nertc.sdk.video.NERtcVideoConfig;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.RequestCallbackWrapper;
import com.netease.nimlib.sdk.ResponseCode;
import com.netease.nimlib.sdk.avsignalling.SignallingService;
import com.netease.nimlib.sdk.avsignalling.SignallingServiceObserver;
import com.netease.nimlib.sdk.avsignalling.builder.CallParamBuilder;
import com.netease.nimlib.sdk.avsignalling.builder.InviteParamBuilder;
import com.netease.nimlib.sdk.avsignalling.constant.ChannelType;
import com.netease.nimlib.sdk.avsignalling.constant.SignallingEventType;
import com.netease.nimlib.sdk.avsignalling.event.CanceledInviteEvent;
import com.netease.nimlib.sdk.avsignalling.event.ChannelCloseEvent;
import com.netease.nimlib.sdk.avsignalling.event.ChannelCommonEvent;
import com.netease.nimlib.sdk.avsignalling.event.ControlEvent;
import com.netease.nimlib.sdk.avsignalling.event.InviteAckEvent;
import com.netease.nimlib.sdk.avsignalling.event.InvitedEvent;
import com.netease.nimlib.sdk.avsignalling.event.UserJoinEvent;
import com.netease.nimlib.sdk.avsignalling.event.UserLeaveEvent;
import com.netease.nimlib.sdk.avsignalling.model.ChannelFullInfo;
import com.netease.nimlib.sdk.avsignalling.model.MemberInfo;
import com.netease.nimlib.sdk.passthrough.PassthroughServiceObserve;
import com.netease.nimlib.sdk.passthrough.model.PassthroughNotifyData;
import com.netease.yunxin.kit.alog.ALog;

import java.util.ArrayList;

public  class NERTCAnchorInteractionLiveRoomImpl extends NERTCAnchorBaseLiveRoomImpl implements AnchorPk {
    private static final String LOG_TAG = "NERTCAnchorInteractionLiveRoomImpl";

    private AnchorPkDelegate pkDelegate;

    //****************通话状态信息start***********************
    private OffState offState;

    private IdleLiveState idleState;

    private CalloutState callOutState;

    private InvitedState invitedState;

    private AcceptState acceptState;

    private PkingState pkingState;

    private LiveState currentState;

    //****************通话状态信息end***********************

    //****************数据存储于标记start*******************

    private boolean isReceive;//是否是接收方
    //推流标识
    private boolean haveReceiveImNot;//已经收到IM消息通知
    private boolean joinedChannel;//是否加入rtc 房间
    private boolean pushPkStream;//推PK的流

    private InviteParamBuilder invitedRecord;//邀请别人后保留的邀请信息

    private String pkChannelId;//IM渠道号

    private long pkSelfUid;//pk直播房间uid
    private String pkChannelName;//房间名
    private String pkCheckSum;//check sum
    private String pkSelfAccid;//pk自己的IM accid
    private long pKOtherUid;//pk直播时的UID
    private String pkOtherAccid;//pk对方的IM accid
    private String pkLiveCid;//pk直播CId

    private LiveStreamTaskRecorder singleHostLiveRecoder;

    private LiveStreamTaskRecorder pkLiveRecoder;

    MsgPkEnd pkEnd;

    //****************数据存储于标记end*******************

    //************************呼叫超时start********************
    private static final int TIME_OUT_LIMITED = 25 * 1000;//呼叫超时限制

    private int timeOut = TIME_OUT_LIMITED;//呼叫超时，最长2分钟

    private CountDownTimer timer;//呼出倒计时
    //************************呼叫超时end********************

    private static final String BUSY_LINE = "busy_now";

    private static final String TIME_OUT_CANCEL = "time_out_cancel";

    private AnchorSeatManagerImpl anchorSeatManager;

    /**
     * 信令在线消息的回调
     */
    private Observer<ChannelCommonEvent> nimOnlineObserver = new Observer<ChannelCommonEvent>() {
        @Override
        public void onEvent(ChannelCommonEvent event) {

            SignallingEventType eventType = event.getEventType();
            ALog.i(LOG_TAG, "receive event = " + eventType);
            switch (eventType) {
                case CLOSE:
                    //信令channel被关闭
                    ChannelCloseEvent channelCloseEvent = (ChannelCloseEvent) event;
                    break;
                case JOIN:
                    UserJoinEvent userJoinEvent = (UserJoinEvent) event;
                    break;
                case INVITE:
                    InvitedEvent invitedEvent = (InvitedEvent) event;
                    ALog.i(LOG_TAG, "receive invite signaling request Id = " + invitedEvent.getRequestId() + " status = " + currentState.getStatus());
                    if (currentState.getStatus() != LiveState.STATE_LIVE_ON) {
                        InviteParamBuilder paramBuilder = new InviteParamBuilder(invitedEvent.getChannelBaseInfo().getChannelId(),
                                invitedEvent.getFromAccountId(), invitedEvent.getRequestId());
                        paramBuilder.customInfo(BUSY_LINE);
                        reject(paramBuilder, false, null);
                        break;
                    }
                    pkChannelId = invitedEvent.getChannelBaseInfo().getChannelId();
                    PkInfo pkInfo = GsonUtils.fromJson(invitedEvent.getCustomInfo(), PkInfo.class);
                    if (pkDelegate != null && pkInfo != null) {
                        currentState.invited();
                        startCount(currentState);
                        pkDelegate.receivePkRequest(invitedEvent, pkInfo);
                    }
                    break;
                case CANCEL_INVITE:
                    CanceledInviteEvent canceledInviteEvent = (CanceledInviteEvent) event;
                    ALog.i(LOG_TAG, "receive cancel signaling request Id = " + canceledInviteEvent.getRequestId());
                    if (pkDelegate != null) {
                        pkDelegate.onPkRequestCancel(!TextUtils.equals(canceledInviteEvent.getCustomInfo(), TIME_OUT_CANCEL));
                    }
                    currentState.release();
                    break;
                case REJECT:
                    InviteAckEvent rejectEvent = (InviteAckEvent) event;
                    ALog.i(LOG_TAG, "receive reject signaling request Id = " + rejectEvent.getRequestId());
                    currentState.release();
                    if (pkDelegate != null) {
                        if (TextUtils.equals(rejectEvent.getCustomInfo(), BUSY_LINE)) {
                            pkDelegate.onUserBusy(rejectEvent.getFromAccountId());
                        } else {
                            pkDelegate.pkRequestRejected(rejectEvent.getFromAccountId());
                        }
                    }
                    break;
                case ACCEPT:
                    handleAccept();
                    break;
                case LEAVE:
                    UserLeaveEvent userLeaveEvent = (UserLeaveEvent) event;
                    break;
                case CONTROL:
                    ControlEvent controlEvent = (ControlEvent) event;
                    ControlInfo controlInfo = GsonUtils.fromJson(controlEvent.getCustomInfo(), ControlInfo.class);
                    if (controlInfo != null && controlInfo.cid == 1) {
                        startJoinPkRoom();
                    }
                    break;
            }
        }
    };

    /**
     * 处理接受
     */
    private void handleAccept() {
        ALog.i(LOG_TAG, "handle accept status = " + currentState.getStatus());
        if (currentState.getStatus() == LiveState.STATE_CALL_OUT && pkDelegate != null) {
            pkDelegate.onAccept();
        }
        currentState.accept();
        startCount(currentState);
        isReceive = false;
    }

    /**
     * rtc 状态监控
     */
    private NERtcStatsObserver statsObserver = new NERtcStatsObserverTemp() {

        boolean showErrorNetWork = false;

        @Override
        public void onNetworkQuality(NERtcNetworkQualityInfo[] stats) {
            /**
             *             0	网络质量未知
             *             1	网络质量极好
             *             2	用户主观感觉和极好差不多，但码率可能略低于极好
             *             3	能沟通但不顺畅
             *             4	网络质量差
             *             5	完全无法沟通
             */
            if (stats == null || stats.length == 0) {
                return;
            }

            for (NERtcNetworkQualityInfo networkQualityInfo : stats) {
                if (currentState.getStatus() == LiveState.STATE_PKING &&
                        networkQualityInfo.userId != pkSelfUid) {
                    ALog.i(LOG_TAG, "network state is " + networkQualityInfo.upStatus);
                    if (networkQualityInfo.upStatus >= 4) {
                        ToastUtils.showShort("对方主播网络较差");
                    } else if (networkQualityInfo.upStatus == 0) {
                        if (showErrorNetWork) {
                            ToastUtils.showShort("对方主播网络状态未知");
                        }
                    }
                    showErrorNetWork = true;
                }
            }
        }
    };

    /**
     * 点对点消息
     */
    private Observer<PassthroughNotifyData> p2pMsg = (Observer<PassthroughNotifyData>) eventData -> {
        ALog.i(LOG_TAG, "IM MSG receive = " + eventData.getBody() + " \n state = " + currentState.getStatus()
                + " roomCid = " + roomCid);
        if (neRtcEx == null) {
            currentState.offLive();
            if (roomDelegate != null) {
                roomDelegate.onError(true, ErrorCode.ERROR_CODE_ENGINE_NULL, "rtc have released");
            }
        }
        if(singleLiveInfo == null){//同一个账号其他端开播case
            return;
        }
        JsonObject jsonObject = GsonUtils.fromJson(eventData.getBody(), JsonObject.class);
        String type = jsonObject.get("type").toString();
        switch (type) {
            case NotificationMessage.TYPE_LIVE_START:
                if (currentState.getStatus() == LiveState.STATE_PKING && pkDelegate != null) {
                    pkDelegate.onPkEnd(!pkEnd.data.countdownEnd, pkEnd.data.closedNickname);
                    pkEnd = null;
                } else if (currentState.getStatus() == LiveState.STATE_LIVE_OFF && roomDelegate != null) {
                    roomDelegate.onRoomLiveStart();
                }
                currentState.release();
                haveReceiveImNot = true;
                pushPkStream = false;
                if (joinedChannel) {
                    startLiveStreamTask();
                }
                break;
            case NotificationMessage.TYPE_AUDIENCE_REWARD:
                MsgReward rewardNotification = GsonUtils.fromJson(eventData.getBody(), MsgReward.class);
                if (roomDelegate != null) {
                    roomDelegate.onUserReward(rewardNotification.data);
                }
                break;
            case NotificationMessage.TYPE_PK_START:
                MsgPkStart pkStart = GsonUtils.fromJson(eventData.getBody(), MsgPkStart.class);
                //存储对方uid
                if(currentState.getStatus() != LiveState.STATE_ACCEPTED){
                    break;
                }
                if (isReceive) {
                    pKOtherUid = pkStart.data.inviterRoomUid;
                } else {
                    pKOtherUid = pkStart.data.inviteeRoomUid;
                }
                currentState.startPk();
                haveReceiveImNot = true;
                pushPkStream = true;
                if (pkDelegate != null) {
                    pkDelegate.onPkStart(pkStart.data);
                }
                if (joinedChannel) {
                    startLiveStreamTask();
                }
                break;
            case NotificationMessage.TYPE_PUNISH_START:
                MsgPunishStart punishStart = GsonUtils.fromJson(eventData.getBody(), MsgPunishStart.class);
                if (punishStart == null || punishStart.data == null || !TextUtils.equals(punishStart.data.roomCid, roomCid)) {
                    break;
                }
                if (pkDelegate != null) {
                    pkDelegate.onPunishStart(punishStart.data);
                }
                break;
            case NotificationMessage.TYPE_PK_END:
                if (currentState.getStatus() != LiveState.STATE_PKING) {
                    break;
                }
                MsgPkEnd msgPkEnd = GsonUtils.fromJson(eventData.getBody(), MsgPkEnd.class);
                if (msgPkEnd == null || msgPkEnd.data == null || !TextUtils.equals(msgPkEnd.data.roomCid, roomCid)) {
                    break;
                }
                pkEnd = msgPkEnd;
                if (pkDelegate != null) {
                    pkDelegate.preJoinRoom(singleLiveInfo.liveCid, false, null);
                }
                break;
            default:
                if(anchorSeatManager != null){
                    anchorSeatManager.handleP2pMsg(eventData.getBody());
                }
                break;
        }
    };





    public NERTCAnchorInteractionLiveRoomImpl(){
        super();
    }

    public OffState getOffState() {
        return offState;
    }

    public IdleLiveState getIdleState() {
        return idleState;
    }

    public InvitedState getInvitedState() {
        return invitedState;
    }

    public AcceptState getAcceptState() {
        return acceptState;
    }

    public PkingState getPkingState() {
        return pkingState;
    }

    public CalloutState getCallOutState() {
        return callOutState;
    }

    public LiveState getCurrentState() {
        return currentState;
    }

    public void setState(LiveState liveState) {
        this.currentState = liveState;
    }

    @Override
    public void init(Context context, String appKey,
                     NERtcOption option) {
        super.init(context,appKey,option);
    }

    @Override
    public void setDelegate(NERTCAnchorBaseLiveRoomDelegate delegate) {
        super.setDelegate(delegate);
        if(delegate != null){
            pkDelegate = delegate.getDelegateService(AnchorPkDelegate.class);
            if (anchorSeatManager == null) {
                anchorSeatManager = AnchorSeatManagerImpl.shareInstance();
            }
            anchorSeatManager.setSeatDelegate(delegate.getDelegateService(AnchorSeatDelegate.class));
        }
    }

    @Override
    protected void initDetail() {
        neRtcEx.setStatsObserver(statsObserver);
        initState();
        NIMClient.getService(SignallingServiceObserver.class).observeOnlineNotification(nimOnlineObserver, true);
        NIMClient.getService(PassthroughServiceObserve.class).observePassthroughNotify(p2pMsg, true);
        anchorSeatManager = AnchorSeatManagerImpl.shareInstance().initObserve();
        anchorSeatManager.setLiveStateService(this);
    }

    @Override
    public void createRoom(LiveInfo liveInfo, int profile, NERtcVideoConfig.NERtcVideoFrameRate frameRate, int mAudioScenario, boolean isFrontCam, LiveRoomCallback callback) {
        super.createRoom(liveInfo, profile, frameRate, mAudioScenario, isFrontCam, callback);
        anchorSeatManager.setLiveInfo(liveInfo);
    }

    @Override
    public <T> T getService(Class<T> tClass) {
        if(tClass.equals(AnchorPk.class)){
            return (T) this;
        }
        if (tClass.equals(AnchorSeatManager.class)){
            return (T) anchorSeatManager;
        }
        return null;
    }

    @Override
    protected NERtcCallback initNERtcCallback() {
        return new NERtcCallbackExTemp() {

            @Override
            public void onAudioDeviceChanged(int i) {
                ALog.i(LOG_TAG, "onAudioDeviceChanged i " + i);
                audioDevice = i;
            }

            @Override
            public void onAudioMixingStateChanged(int i) {
                if(roomDelegate != null){
                    roomDelegate.onAudioMixingFinished();
                }
            }

            @Override
            public void onAudioEffectFinished(int effectId) {
                if (roomDelegate != null) {
                    roomDelegate.onAudioEffectFinished(effectId);
                }
            }

            @Override
            public void onJoinChannel(int i, long l, long l1) {
                ALog.i(LOG_TAG, "onJoinChannel state = " + currentState.getStatus());
                if (currentState.getStatus() == LiveState.STATE_ACCEPTED && isReceive) { //受邀者加入房间不推流
                    sendControlEvent(pkChannelId, pkOtherAccid, new ControlInfo(1));
                } else if (haveReceiveImNot) {
                    ALog.i(LOG_TAG, "onJoinChannel push Stream ");
                    startLiveStreamTask();
                }
                joinedChannel = true;

            }

            @Override
            public void onLeaveChannel(int i) {
                ALog.i(LOG_TAG, "onLeaveChannel state = " + currentState.getStatus());
                if (currentState.getStatus() == LiveState.STATE_ACCEPTED) {
                    joinChannel(pkCheckSum, pkChannelName, pkSelfUid);
                } else if (currentState.getStatus() == LiveState.STATE_PKING) {
                    joinChannel(singleLiveInfo.avRoomCheckSum, singleLiveInfo.avRoomCName, singleLiveInfo.avRoomUid);
                }
                haveReceiveImNot = false;
                joinedChannel = false;
            }

            @Override
            public void onUserJoined(long userId) {
                pKOtherUid = userId;
            }


            @Override
            public void onUserAudioStart(long l) {
                NERtcEx.getInstance().subscribeRemoteAudioStream(l, true);
            }

            @Override
            public void onUserVideoStart(long l, int i) {
                NERtcEx.getInstance().subscribeRemoteVideoStream(l, NERtcRemoteVideoStreamType.kNERtcRemoteVideoStreamTypeHigh, true);

            }


            @Override
            public void onDisconnect(int i) {
                currentState.offLive();
                if (roomDelegate != null) {
                    roomDelegate.onError(true, ErrorCode.ERROR_CODE_DISCONNECT, "网络连接断开");
                }
            }
        };
    }

    private void initState() {
        offState = new OffState(this);
        idleState = new IdleLiveState(this);
        callOutState = new CalloutState(this);
        invitedState = new InvitedState(this);
        pkingState = new PkingState(this);
        acceptState = new AcceptState(this);
        currentState = offState;
    }

    @Override
    public void requestPk(String selfAccid, String accountId, String pkLiveCid, String cdnURL, String selfNickname, LiveRoomCallback pkRequestCallback) {
        pkSelfAccid = selfAccid;
        this.pkLiveCid = pkLiveCid;
        currentState.callPk();
        startCount(currentState);//启动倒计时
        callOtherPk(ChannelType.CUSTOM, accountId, selfNickname, pkLiveCid, pkRequestCallback);
    }

    /**
     * 加入PK房间前站位
     */
    private void startJoinPkRoom() {
        ALog.i(LOG_TAG, "startJoinPkRoom");
        if (pkDelegate != null) {
            pkDelegate.preJoinRoom(pkLiveCid, true, singleLiveInfo.liveCid);
        }
    }

    /**
     * 发送控制信息
     *
     * @param controlInfo
     */
    private void sendControlEvent(String channelId, String accountId, ControlInfo controlInfo) {
        NIMClient.getService(SignallingService.class).sendControl(channelId, accountId, GsonUtils.toJson(controlInfo));
    }

    /**
     * 设置推流
     */
    private void startLiveStreamTask() {
        ALog.i(LOG_TAG, "startLiveStreamTask isPk  = " + pushPkStream);
        haveReceiveImNot = false;
        if (!pushPkStream) {
            //单主播直播设置推流
            singleHostLiveRecoder = new LiveStreamTaskRecorder(singleLiveInfo.liveConfig.pushUrl, singleLiveInfo.avRoomUid);
            int streamResult = addLiveStreamTask(singleHostLiveRecoder);
            anchorSeatManager.setLiveRecoder(singleHostLiveRecoder);
            if (streamResult != 0) {
                //todo error
                ALog.i(LOG_TAG, "single task failed result = " + streamResult);
            }
        } else {
            pkLiveRecoder = new LiveStreamTaskRecorder(singleLiveInfo.liveConfig.pushUrl, LiveStreamTaskRecorder.TYPE_PK, pkSelfUid, pKOtherUid);
            int result = addLiveStreamTask(pkLiveRecoder);
            if (result != 0) {
                //todo error
                ALog.i(LOG_TAG, "pk task failed result = " + result);
            }
        }
    }


    /**
     * 删除推流任务
     *
     * @param callback
     * @return
     */
    private int removeLiveTask(LiveStreamTaskRecorder liveRecoder, DeleteLiveTaskCallback callback) {
        if (neRtcEx == null) {
            return -1;
        }
        return neRtcEx.removeLiveStreamTask(liveRecoder.taskId, callback);
    }

    /**
     * 创建IM信令房间并加入
     *
     * @param type
     * @param callUserId
     * @param callback
     */
    private void callOtherPk(ChannelType type, String callUserId, String selfNickname, String pkLiveCid, LiveRoomCallback callback) {
        String requestId = getRequestId();
        CallParamBuilder callParam = new CallParamBuilder(type, callUserId, requestId);
        callParam.offlineEnabled(true);
        String custom = GsonUtils.toJson(new PkInfo(pkLiveCid, selfNickname));
        callParam.customInfo(custom);
        NIMClient.getService(SignallingService.class).call(callParam).setCallback(new RequestCallback<ChannelFullInfo>() {
            @Override
            public void onSuccess(ChannelFullInfo param) {
                //保留邀请信息，取消用
                invitedRecord = new InviteParamBuilder(param.getChannelId(), callUserId, requestId);
                pkChannelId = param.getChannelId();
                callback.onSuccess(null);
                ALog.i(LOG_TAG, "send pk request success request Id = " + requestId);
            }

            @Override
            public void onFailed(int code) {
                ALog.i(LOG_TAG, "im call failed code = " + code);
                callback.onError(code, "im call failed code");
                currentState.release();
            }

            @Override
            public void onException(Throwable exception) {
                ALog.w(LOG_TAG, "call exception", exception);
                currentState.release();
            }
        });

    }

    /**
     * 启动倒计时，用于实现timeout
     */
    private void startCount(LiveState startState) {
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
        timer = new CountDownTimer(timeOut, 1000) {
            @Override
            public void onTick(long l) {
                if (currentState.getStatus() != startState.getStatus()) {
                    timer.cancel();
                }
            }

            @Override
            public void onFinish() {
                ALog.i(LOG_TAG, "time out status = " + currentState.getStatus());
                int code = 0;
                if (currentState.getStatus() == LiveState.STATE_ACCEPTED) {
                    code = ErrorCode.ERROR_CODE_TIME_OUT_ACCEPTED;
                    currentState.release();
                } else if (currentState.getStatus() == LiveState.STATE_CALL_OUT) {
                    NERTCAnchorInteractionLiveRoomImpl.this.cancelPkRequest(null, false);
                    code = ErrorCode.ERROR_CODE_TIME_OUT_CALL_OUT;
                } else if (currentState.getStatus() == LiveState.STATE_INVITED) {
                    currentState.release();
                    code = ErrorCode.ERROR_CODE_TIME_OUT_ACCEPT;
                }
                if (pkDelegate != null) {
                    pkDelegate.onTimeOut(code);
                    if(!joinedChannel){
                        pkDelegate.preJoinRoom(singleLiveInfo.liveCid, false, null);
                    }
                }
            }
        };

        timer.start();
    }

    /**
     * 生成随机数座位requestID
     *
     * @return
     */
    private String getRequestId() {
        int randomInt = (int) (Math.random() * 100);
        ALog.i(LOG_TAG, "random int = " + randomInt);
        return System.currentTimeMillis() + randomInt + "_id";
    }


    @Override
    public void acceptPk(String pkLiveCid, String imAccid, String requestId, String accId, LiveRoomCallback pkCallback) {
        this.pkSelfAccid = accId;
        this.pkOtherAccid = imAccid;
        this.pkLiveCid = pkLiveCid;
        if (timer != null) {
            timer.cancel();
        }
        InviteParamBuilder inviteParam = new InviteParamBuilder(pkChannelId, imAccid, requestId);
        NIMClient.getService(SignallingService.class).acceptInviteAndJoin(inviteParam, 0).setCallback(
                new RequestCallbackWrapper<ChannelFullInfo>() {

                    @Override
                    public void onResult(int code, ChannelFullInfo channelFullInfo, Throwable throwable) {
                        if (code == ResponseCode.RES_SUCCESS) {
                            currentState.accept();
                            startCount(currentState);
                            isReceive = true;
                            storeUid(channelFullInfo.getMembers(), accId);
                            startJoinPkRoom();
                            pkCallback.onSuccess(null);
                            ALog.i(LOG_TAG, "pk accept success");
                        } else {
                            ALog.i(LOG_TAG, "pk accept failed code = " + code);
                            pkCallback.onError(code, "accept pk error");
                        }
                    }
                });
    }

    /**
     * 保存自己再rtc channel 中的uid
     *
     * @param memberInfos
     * @param selfAccid
     */
    private void storeUid(ArrayList<MemberInfo> memberInfos, String selfAccid) {
        for (MemberInfo member : memberInfos) {
            if (TextUtils.equals(member.getAccountId(), selfAccid)) {
                pkSelfUid = member.getUid();
            }
        }
    }

    @Override
    protected void releaseObserve() {
        currentState.offLive();
        NIMClient.getService(SignallingServiceObserver.class).observeOnlineNotification(nimOnlineObserver, false);
        NIMClient.getService(PassthroughServiceObserve.class).observePassthroughNotify(p2pMsg, false);
        anchorSeatManager.releaseObserve();
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
    }

    @Override
    public void rejectPkRequest(InviteParamBuilder inviteParam, LiveRoomCallback callback) {
        reject(inviteParam, true, callback);
    }

    @Override
    public void joinRtcChannel(String checkSum, String channelName, long uid, String avRoomCid) {
        ALog.i(LOG_TAG, "joinRtcChannel ");
        if (currentState.getStatus() == LiveState.STATE_ACCEPTED) {
            pkSelfUid = uid;
            pkCheckSum = checkSum;
            pkChannelName = channelName;
        }
        if (currentState == pkingState) {
            singleLiveInfo.avRoomCheckSum = checkSum;
            singleLiveInfo.avRoomUid = uid;
            singleLiveInfo.avRoomCName = channelName;
        }
        roomCid = avRoomCid;
        if (currentState.getStatus() == LiveState.STATE_PKING) {
            removeLiveTask(pkLiveRecoder, (s, code) -> {
                if (code != RtcCode.LiveCode.OK) {
                    ALog.i(LOG_TAG, "remove Live Task failed code = " + code + " s =" + s);
                }
                neRtcEx.leaveChannel();
            });
        } else {
            removeLiveTask(singleHostLiveRecoder, (s, code) -> {
                if (code != RtcCode.LiveCode.OK) {
                    ALog.i(LOG_TAG, "remove Live Task failed code = " + code + " s =" + s);
                }
                neRtcEx.leaveChannel();
            });
        }
    }

    /**
     * 拒绝
     *
     * @param inviteParam
     * @param byUser
     */
    private void reject(InviteParamBuilder inviteParam, boolean byUser, LiveRoomCallback callback) {
        ALog.i(LOG_TAG, "reject by user = " + byUser);
        NIMClient.getService(SignallingService.class).rejectInvite(inviteParam).setCallback(new RequestCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                if (byUser) {
                    currentState.release();
                }
                if (callback != null) {
                    callback.onSuccess(null);
                }
            }

            @Override
            public void onFailed(int i) {
                if (byUser) {
                    currentState.release();
                }
                if (callback != null) {
                    callback.onError(i, "reject error");
                }
            }

            @Override
            public void onException(Throwable throwable) {
                if (callback != null) {
                    callback.onError(-1, "reject on exception");
                }
                if (byUser) {
                    currentState.release();
                }
            }
        });

    }

    @Override
    public LiveState getLiveCurrentState() {
        return currentState;
    }

    @Override
    public void cancelPkRequest(RequestCallback<Void> callback, boolean byUser) {
        if (invitedRecord != null) {
            invitedRecord.customInfo(byUser ? "" : TIME_OUT_CANCEL);
            NIMClient.getService(SignallingService.class).cancelInvite(invitedRecord).setCallback(new RequestCallback<Void>() {
                @Override
                public void onSuccess(Void param) {
                    if (callback != null) {
                        callback.onSuccess(param);
                    }
                    invitedRecord = null;
                    currentState.release();
                }

                @Override
                public void onFailed(int code) {
                    if (callback != null) {
                        callback.onFailed(code);
                    }
                    if (code != ResponseCode.RES_INVITE_HAS_ACCEPT) {//不是用户已经接受的情况，重新加入之前的单主播房间
                        currentState.release();
                    } else {
                        handleAccept();
                    }
                }

                @Override
                public void onException(Throwable exception) {
                    if (callback != null) {
                        callback.onException(exception);
                    }
                    invitedRecord = null;
                    currentState.release();
                }
            });
        } else {
            if (callback != null) {
                callback.onFailed(-1);
            }
            currentState.release();
        }
    }
}
