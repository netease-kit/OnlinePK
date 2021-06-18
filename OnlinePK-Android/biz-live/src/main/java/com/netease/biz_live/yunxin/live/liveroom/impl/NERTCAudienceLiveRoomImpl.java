/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom.impl;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.NonNull;

import com.blankj.utilcode.util.GsonUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.biz_live.yunxin.live.audience.callback.SeatApplyAcceptEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatApplyRejectEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatEnterEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatKickedEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatLeaveEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatMuteStateChangeEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatPickRequestEvent;
import com.netease.biz_live.yunxin.live.audience.ui.view.DurationStatisticTimer;
import com.netease.biz_live.yunxin.live.audience.utils.LinkedSeatsAudienceActionManager;
import com.netease.biz_live.yunxin.live.constant.AudioActionType;
import com.netease.biz_live.yunxin.live.constant.ErrorCode;
import com.netease.biz_live.yunxin.live.constant.SeatLeftReason;
import com.netease.biz_live.yunxin.live.constant.SeatsActionType;
import com.netease.biz_live.yunxin.live.constant.SeatsMsgType;
import com.netease.biz_live.yunxin.live.constant.VideoActionType;
import com.netease.biz_live.yunxin.live.liveroom.LiveRoomCallback;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAudienceLiveRoom;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAudienceLiveRoomDelegate;
import com.netease.biz_live.yunxin.live.liveroom.msg.SeatInfo;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.biz_live.yunxin.live.network.SeatsManagerInteraction;
import com.netease.lava.nertc.sdk.NERtcCallback;
import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.NERtcOption;
import com.netease.lava.nertc.sdk.NERtcParameters;
import com.netease.lava.nertc.sdk.stats.NERtcNetworkQualityInfo;
import com.netease.lava.nertc.sdk.stats.NERtcStatsObserver;
import com.netease.lava.nertc.sdk.video.NERtcRemoteVideoStreamType;
import com.netease.lava.nertc.sdk.video.NERtcVideoCallback;
import com.netease.lava.nertc.sdk.video.NERtcVideoConfig;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.chatroom.ChatRoomServiceObserver;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomMessage;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;
import com.netease.nimlib.sdk.passthrough.PassthroughServiceObserve;
import com.netease.nimlib.sdk.passthrough.model.PassthroughNotifyData;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.demo.basic.BuildConfig;
import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

import java.util.List;

import io.reactivex.observers.ResourceSingleObserver;

/**
 * 观众端使用的LiveRoom实例
 */
public class NERTCAudienceLiveRoomImpl extends NERTCAudienceLiveRoom {

    private static final String LOG_TAG = NERTCAudienceLiveRoomImpl.class.getSimpleName();

    private static NERTCAudienceLiveRoomImpl instance;

    private NERTCAudienceLiveRoomDelegate roomDelegate;

    private NERtcEx neRtcEx;

    /**
     * 音频设备{@link NERtcConstants.AudioDevice }
     */
    private int audioDevice;
    private LiveInfo liveInfo;
    private static final int ERROR_CODE = -1;
    private static final String NETWORK_ERROR_MSG = "网络异常";

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
                if (networkQualityInfo.upStatus >= 4) {
//                    ToastUtils.showShort("对方主播网络较差");
                } else if (networkQualityInfo.upStatus == 0) {
                    if (showErrorNetWork) {
//                        ToastUtils.showShort("对方主播网络状态未知");
                    }
                }
                showErrorNetWork = true;
            }
        }
    };

    /**
     * Nertc的回调
     */
    private NERtcCallback rtcCallback = new NERtcCallbackExTemp() {

        @Override
        public void onAudioDeviceChanged(int i) {
            ALog.i(LOG_TAG, "onAudioDeviceChanged i " + i);
            audioDevice = i;
        }

        @Override
        public void onAudioMixingStateChanged(int i) {
            ALog.d(LOG_TAG, "onAudioMixingStateChanged i:" + i);
        }

        @Override
        public void onAudioEffectFinished(int effectId) {
            ALog.d(LOG_TAG, "onAudioEffectFinished effectId:" + effectId);
        }

        @Override
        public void onJoinChannel(int result, long channelId, long elapsed) {
            if (result != 0) {
                //https://dev.yunxin.163.com/docs/interface/%E9%9F%B3%E8%A7%86%E9%A2%912.0Android%E7%AB%AF/com/netease/lava/nertc/sdk/NERtcCallback.html#onJoinChannel-int-long-long-
                if (roomDelegate != null) {
                    roomDelegate.onError(true, ERROR_CODE, "onJoinChannel异常，错误码为："+result);
                    StringBuilder stringBuilder = new StringBuilder();
                    stringBuilder.append("onJoinChannel failed,")
                            .append("result:")
                            .append(result)
                            .append(",")
                            .append("channelId:")
                            .append(channelId)
                            .append(",")
                            .append("elapsed:")
                            .append(elapsed);
                    ALog.d(LOG_TAG, stringBuilder.toString());
                }
                return;
            }
        }

        /**
         * 退出房间回调。 App 调用 leaveChannel 方法后，SDK 提示 App 退出房间是否成功。
         * @param result 0 表示成功；其他值表示退出房间失败
         */
        @Override
        public void onLeaveChannel(int result) {
            ALog.d(LOG_TAG, "onLeaveChannel result:" + result);
            if (roomDelegate!=null&&result!=0){
                roomDelegate.onError(false,ERROR_CODE,"onLeaveChannel异常,错误码为："+result);
            }
        }

        @Override
        public void onUserJoined(long userId) {
            ALog.d(LOG_TAG, "onUserJoined userId:" + userId);
        }


        @Override
        public void onUserAudioStart(long userId) {
            NERtcEx.getInstance().subscribeRemoteAudioStream(userId, true);
            ALog.d(LOG_TAG, "onUserAudioStart userId:" + userId);
        }

        @Override
        public void onUserVideoStart(long userId, int i) {
            NERtcEx.getInstance().subscribeRemoteVideoStream(userId, NERtcRemoteVideoStreamType.kNERtcRemoteVideoStreamTypeHigh, true);
            ALog.d(LOG_TAG, "onUserVideoStart userId:" + userId);
        }


        @Override
        public void onDisconnect(int i) {
            if (roomDelegate != null) {
                roomDelegate.onError(false, ErrorCode.ERROR_CODE_DISCONNECT, "");
            }
            ALog.d(LOG_TAG, "onDisconnect i:" + i);
        }
    };


    public static synchronized NERTCAudienceLiveRoomImpl sharedInstance() {
        if (instance == null) {
            instance = new NERTCAudienceLiveRoomImpl();
        }
        return instance;
    }

    @Override
    public void setDelegate(NERTCAudienceLiveRoomDelegate delegate) {
        roomDelegate = delegate;
    }

    @Override
    public void setLiveInfo(LiveInfo liveInfo) {
        this.liveInfo = liveInfo;
    }

    public static synchronized void destroySharedInstance() {
        if (instance != null) {
            instance.destroy();
            instance = null;
        }
    }

    @Override
    public void applySeat(String roomId, LiveRoomCallback<Void> callback) {
        SeatsManagerInteraction.operateSeats(roomId, getCurrentAccid(), SeatsActionType.UNLINKED_AUDIENCE_APPLY_JOIN_SEATS)
                .subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
                    @Override
                    public void onSuccess(@NonNull BaseResponse<Boolean> response) {
                        if (response.isSuccessful() && response.data) {
                            callback.onSuccess(null);
                        } else {
                            callback.onError(response.code, response.msg);
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        e.printStackTrace();
                        callback.onError(ERROR_CODE, NETWORK_ERROR_MSG);
                    }
                });
    }

    @Override
    public void leaveSeat(String roomId, LiveRoomCallback<Void> callback) {

        SeatsManagerInteraction.operateSeats(roomId, getCurrentAccid(), SeatsActionType.LINKED_AUDIENCE_LEAVE_SEATS)
                .subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
                    @Override
                    public void onSuccess(@NonNull BaseResponse<Boolean> response) {
                        if (response.isSuccessful() && response.data) {
                            callback.onSuccess(null);
                        } else {
                            callback.onError(response.code, response.msg);
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        e.printStackTrace();
                        callback.onError(ERROR_CODE, NETWORK_ERROR_MSG);
                    }
                });

        //离开RTC房间
        leaveChannel();
        DurationStatisticTimer.DurationUtil.reset();
        LinkedSeatsAudienceActionManager.enableLocalVideo=true;
        LinkedSeatsAudienceActionManager.enableLocalAudio=true;
    }

    @Override
    public void cancelSeatApply(String roomId, String userId, LiveRoomCallback<Void> callback) {
        SeatsManagerInteraction.operateSeats(roomId, userId, SeatsActionType.UNLINKED_AUDIENCE_CANCEL_APPLY_JOIN_SEATS)
                .subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
                    @Override
                    public void onSuccess(@NonNull BaseResponse<Boolean> response) {
                        if (response.isSuccessful() && response.data) {
                            callback.onSuccess(null);
                        } else {
                            callback.onError(response.code, response.msg);
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        e.printStackTrace();
                        callback.onError(ERROR_CODE, NETWORK_ERROR_MSG);
                    }
                });
    }

    @Override
    public void acceptSeatPick(String roomId, String userId, LiveRoomCallback<Void> callback) {
        SeatsManagerInteraction.operateSeats(roomId, userId, SeatsActionType.UNLINKED_AUDIENCE_ACCEPT_JOIN_SEATS)
                .subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
                    @Override
                    public void onSuccess(@NonNull BaseResponse<Boolean> response) {
                        if (response.isSuccessful() && response.data) {
                            callback.onSuccess(null);
                        } else {
                            callback.onError(response.code, response.msg);
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        e.printStackTrace();
                        callback.onError(ERROR_CODE, NETWORK_ERROR_MSG);
                    }
                });
    }

    @Override
    public void rejectSeatPick(String roomId, String userId, LiveRoomCallback<Void> callback) {
        SeatsManagerInteraction.operateSeats(roomId, userId, SeatsActionType.UNLINKED_AUDIENCE_REJECT_JOIN_SEATS)
                .subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
                    @Override
                    public void onSuccess(@NonNull BaseResponse<Boolean> response) {
                        if (response.isSuccessful() && response.data) {
                            callback.onSuccess(null);
                        } else {
                            callback.onError(response.code, response.msg);
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        e.printStackTrace();
                        callback.onError(ERROR_CODE, NETWORK_ERROR_MSG);
                    }
                });
    }

    @Override
    public void setSeatAudioMuteState(int[] indexes, boolean state, String ext, LiveRoomCallback<Void> callback) {
        SeatsManagerInteraction.changeSeatAV(liveInfo.liveCid, getCurrentAccid(), VideoActionType.DEFAULT, state ? AudioActionType.OPEN : AudioActionType.CLOSE)
                .subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
                    @Override
                    public void onSuccess(@NonNull BaseResponse<Boolean> response) {
                        if (response.isSuccessful() && response.data) {
                            callback.onSuccess(null);
                        } else {
                            callback.onError(response.code, response.msg);
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        e.printStackTrace();
                        callback.onError(ERROR_CODE, NETWORK_ERROR_MSG);
                    }
                });
    }

    @Override
    public void setSeatVideoMuteState(int[] indexes, boolean state, String ext, LiveRoomCallback<Void> callback) {
        SeatsManagerInteraction.changeSeatAV(liveInfo.liveCid, getCurrentAccid(), state ? VideoActionType.OPEN : VideoActionType.CLOSE, AudioActionType.DEFAULT)
                .subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
                    @Override
                    public void onSuccess(@NonNull BaseResponse<Boolean> response) {
                        if (response.isSuccessful() && response.data) {
                            callback.onSuccess(null);
                        } else {
                            callback.onError(response.code, response.msg);
                        }
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        e.printStackTrace();
                        callback.onError(ERROR_CODE, NETWORK_ERROR_MSG);
                    }
                });
    }


    private NERTCAudienceLiveRoomImpl() {

    }

    private void destroy() {
        if (neRtcEx != null) {
            neRtcEx.release();
        }
    }

    public void registerMsgCallback(boolean register){
        NIMClient.getService(PassthroughServiceObserve.class).observePassthroughNotify(p2pMsg, register);
        NIMClient.getService(ChatRoomServiceObserver.class).observeReceiveMessage(chatRoomMsgObserver, register);
    }

    @Override
    public void init(Context context, String appKey,
                     NERtcOption option) {
        if (neRtcEx != null) {
            neRtcEx.release();
        }

        neRtcEx = NERtcEx.getInstance();
        NERtcVideoConfig videoConfig = new NERtcVideoConfig();
        videoConfig.frontCamera = true;//默认是前置摄像头
        neRtcEx.setLocalVideoConfig(videoConfig);

        try {
            neRtcEx.init(context, appKey, rtcCallback, option);
        } catch (Exception e) {
            ALog.w(LOG_TAG, "first nertc init failed exception", e);
            // 可能由于没有release导致初始化失败，release后再试一次
            NERtcEx.getInstance().release();
            try {
                NERtcEx.getInstance().init(context, BuildConfig.APP_KEY, rtcCallback, null);
            } catch (Exception exception) {
                exception.printStackTrace();
                ALog.w(LOG_TAG, "second nertc init failed exception", e);
            }
            return;
        }
        NERtcParameters parameters = new NERtcParameters();
        parameters.set(NERtcParameters.KEY_PUBLISH_SELF_STREAM, true);
        neRtcEx.setParameters(parameters);
        neRtcEx.setStatsObserver(statsObserver);
    }

    /**
     * 点对点消息
     */
    private Observer<PassthroughNotifyData> p2pMsg = (Observer<PassthroughNotifyData>) eventData -> {
        if (neRtcEx == null) {
            if (roomDelegate != null) {
                roomDelegate.onError(true, ErrorCode.ERROR_CODE_ENGINE_NULL, "rtc have released");
            }
            return;
        }
        ALog.d(LOG_TAG,"p2pMsg:"+liveInfo.toString());
        SeatInfo seatInfo = GsonUtils.fromJson(eventData.getBody(), SeatInfo.class);
        ALog.d(LOG_TAG, "p2pMsg:" + eventData.getBody());
        if (seatInfo==null){
            return;
        }
        if (!liveInfo.accountId.equals(seatInfo.fromUser)){
            ALog.d(LOG_TAG,"观众同账号多端登录进入不同直播间时收到主播端麦位操作的信息");
            return;
        }
        if (roomDelegate != null) {
            switch (seatInfo.type) {
                case SeatsMsgType.ADMIN_ACCEPT_JOIN_SEATS:
                    //管理员同意上麦
                    roomDelegate.onSeatApplyAccepted(new SeatApplyAcceptEvent(seatInfo.index, seatInfo.member, 0, ""));
                    break;
                case SeatsMsgType.ADMIN_REJECT_UNLINKED_AUDIENCE_JOIN_SEATS:
                    //管理员拒绝观众上麦申请
                    roomDelegate.onSeatApplyRejected(new SeatApplyRejectEvent(seatInfo.index, seatInfo.member, 0, ""));
                    break;
                case SeatsMsgType.ADMIN_INVITE_JOIN_SEATS:
                    //主播发起抱麦请求
                    roomDelegate.onSeatPickRequest(new SeatPickRequestEvent(seatInfo.index, seatInfo.member, "", ""));
                    break;

                case SeatsMsgType.ADMIN_KICK_SEATS:
                    //管理员踢下麦
                    roomDelegate.onSeatKicked(new SeatKickedEvent(seatInfo.index, seatInfo.member, SeatLeftReason.KICKED));
//                    leaveChannel();
                    break;
                default:
                    break;
            }
        }
    };

    /**
     * 聊天室通知消息
     */
    private final Observer<List<ChatRoomMessage>> chatRoomMsgObserver = new Observer<List<ChatRoomMessage>>() {

        @Override
        public void onEvent(List<ChatRoomMessage> chatRoomMessages) {
            if (chatRoomMessages == null || chatRoomMessages.isEmpty()) {
                return;
            }

            for (ChatRoomMessage chatroomMessage : chatRoomMessages) {
                // 只接收此聊天室的相应消息
                if ((chatroomMessage.getSessionType() != SessionTypeEnum.ChatRoom)
                        || !TextUtils.equals(liveInfo.chatRoomId, chatroomMessage.getSessionId())) {
                    continue;
                }

                SeatInfo seatInfo = GsonUtils.fromJson(chatroomMessage.getAttachStr(), SeatInfo.class);
                ALog.d(LOG_TAG, "chatRoomMsgObserver:" + chatroomMessage.getAttachStr());
                if (seatInfo != null && roomDelegate != null) {
                    switch (seatInfo.type) {
                        case SeatsMsgType.LINKED_AUDIENCE_LEAVE_SEATS:
                            // 上麦者下麦
                            roomDelegate.onSeatLeft(new SeatLeaveEvent(seatInfo.index, seatInfo.member, SeatLeftReason.NORMAL));
                            break;
                        case SeatsMsgType.LINKED_AUDIENCE_ENTER_SEATS:
                            // 观众上麦
                            roomDelegate.onSeatEntered(new SeatEnterEvent(seatInfo.index, seatInfo.member, ""));
                            break;
                        case SeatsMsgType.AV_CHANGE:
                            if (seatInfo.member!=null){
                                roomDelegate.onSeatMuteStateChanged(new SeatMuteStateChangeEvent(seatInfo.fromUser , seatInfo.member, seatInfo.member.audio));
                            }
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    };


    @Override
    public void setupLocalView(NERtcVideoView videoRender) {
        if (neRtcEx == null) {
            return;
        }
        if (videoRender == null) {
            neRtcEx.setupLocalVideoCanvas(null);
            return;
        }
        neRtcEx.enableLocalAudio(true);
        neRtcEx.enableLocalVideo(true);
        videoRender.setZOrderMediaOverlay(true);
        videoRender.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_BALANCED);
        int result = neRtcEx.setupLocalVideoCanvas(videoRender);
        ALog.i(LOG_TAG, "setupLocalView result = " + result);
    }

    @Override
    public void setupRemoteView(NERtcVideoView videoRender, long uid, boolean isTop) {
        if (neRtcEx == null) {
            return;
        }
        videoRender.setZOrderMediaOverlay(isTop);
        videoRender.setMirror(true);
        videoRender.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_FIT);
        neRtcEx.setupRemoteVideoCanvas(videoRender, uid);
        videoRender.setVisibility(View.VISIBLE);
        ALog.i(LOG_TAG, "uid = " + uid);
    }

    @Override
    public void setVideoCallback(NERtcVideoCallback callback, boolean needI420) {
        if (neRtcEx != null) {
            neRtcEx.setVideoCallback(callback, needI420);
        }
    }


    @Override
    public void joinRtcChannel(String token, String channelName, long uid, String roomCid) {
        if (neRtcEx != null) {
            neRtcEx.joinChannel(token, channelName, uid);
        }
    }


    @Override
    public boolean switchCamera() {
        return NERtcEx.getInstance().switchCamera() == 0;
    }

    @Override
    public boolean enableLocalVideo(boolean enable) {
        return NERtcEx.getInstance().enableLocalVideo(enable) == 0;
    }

    @Override
    public boolean muteLocalAudio(boolean isMute) {
        return NERtcEx.getInstance().muteLocalAudioStream(isMute) == 0;
    }

    @Override
    public boolean enableEarback(boolean enable, int volume) {
        if (audioDevice == NERtcConstants.AudioDevice.BLUETOOTH_HEADSET ||
                audioDevice == NERtcConstants.AudioDevice.WIRED_HEADSET) {
            return NERtcEx.getInstance().enableEarback(enable, volume) == 0;
        } else {
            ToastUtils.showShort("打开耳返功能前，请先插入耳机！");
            return false;
        }

    }

    public void leaveChannel(){
        if (neRtcEx!=null){
            neRtcEx.leaveChannel();
        }
    }

    @Override
    public <T> T getService(Class<T> tClass) {
        return null;
    }

    private String getCurrentAccid() {
        UserCenterService userCenterService = ModuleServiceMgr.getInstance().getService(UserCenterService.class);
        return userCenterService.getCurrentUser().accountId;
    }
}
