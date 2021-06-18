/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom.impl;

import android.graphics.Color;
import android.text.TextUtils;

import com.blankj.utilcode.util.GsonUtils;
import com.netease.biz_live.yunxin.live.constant.ErrorCode;
import com.netease.biz_live.yunxin.live.constant.LiveStreamParams;
import com.netease.biz_live.yunxin.live.constant.SeatsActionType;
import com.netease.biz_live.yunxin.live.constant.SeatsMsgType;
import com.netease.biz_live.yunxin.live.liveroom.AnchorSeatDelegate;
import com.netease.biz_live.yunxin.live.liveroom.AnchorSeatManager;
import com.netease.biz_live.yunxin.live.liveroom.LiveRoomCallback;
import com.netease.biz_live.yunxin.live.liveroom.LiveStateService;
import com.netease.biz_live.yunxin.live.liveroom.model.LiveStreamTaskRecorder;
import com.netease.biz_live.yunxin.live.liveroom.msg.SeatInfo;
import com.netease.biz_live.yunxin.live.liveroom.state.LiveState;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.biz_live.yunxin.live.network.SeatsManagerInteraction;
import com.netease.lava.nertc.impl.RtcCode;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.live.NERtcLiveStreamLayout;
import com.netease.lava.nertc.sdk.live.NERtcLiveStreamTaskInfo;
import com.netease.lava.nertc.sdk.live.NERtcLiveStreamUserTranscoding;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.chatroom.ChatRoomServiceObserver;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomMessage;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.kit.alog.ALog;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.annotations.NonNull;
import io.reactivex.observers.ResourceSingleObserver;

/**
 * 主播麦位控制实现类
 */
public class AnchorSeatManagerImpl implements AnchorSeatManager {

    private LiveStateService liveStateService;

    private static final String LOG_TAG = "AnchorSeatManagerImpl";

    private AnchorSeatDelegate seatDelegate;

    private static  AnchorSeatManagerImpl instance;

    private LiveInfo liveInfo;

    /**
     * 推流任务
     */
    private LiveStreamTaskRecorder liveRecoder;

    private AnchorSeatManagerImpl() {

    }

    public static AnchorSeatManagerImpl shareInstance() {
        if (instance == null) {
            instance = new AnchorSeatManagerImpl();
        }
        return instance;
    }

    public AnchorSeatManagerImpl initObserve() {
        NIMClient.getService(ChatRoomServiceObserver.class).observeReceiveMessage(chatRoomMsgObserver, true);
        return this;
    }


    public AnchorSeatManagerImpl setLiveStateService(LiveStateService liveStateService) {
        this.liveStateService = liveStateService;
        return this;
    }

    public AnchorSeatManagerImpl setSeatDelegate(AnchorSeatDelegate seatDelegate) {
        this.seatDelegate = seatDelegate;
        return this;
    }

    public void setLiveRecoder(LiveStreamTaskRecorder liveRecoder) {
        this.liveRecoder = liveRecoder;
    }

    public void setLiveInfo(LiveInfo liveInfo) {
        this.liveInfo = liveInfo;
    }

    /**
     * 聊天室通知消息
     */
    private final Observer<List<ChatRoomMessage>> chatRoomMsgObserver = new Observer<List<ChatRoomMessage>>() {

        @Override
        public void onEvent(List<ChatRoomMessage> chatRoomMessages) {
            if (chatRoomMessages == null || chatRoomMessages.isEmpty()) {
                return;
            }

            for(ChatRoomMessage chatroomMessage:chatRoomMessages){
                // 只接收此聊天室的相应消息
                if ((chatroomMessage.getSessionType() != SessionTypeEnum.ChatRoom)
                        || !TextUtils.equals(liveInfo.chatRoomId,chatroomMessage.getSessionId())) {
                    continue;
                }

                SeatInfo seatInfo = GsonUtils.fromJson(chatroomMessage.getAttachStr(), SeatInfo.class);
                if (seatInfo != null && seatDelegate != null) {
                    switch (seatInfo.type){
                        case SeatsMsgType.LINKED_AUDIENCE_LEAVE_SEATS:
                            liveRecoder.removeUser(seatInfo.member.avRoomUid);
                            updateLiveStreamTask();
                            seatDelegate.onSeatLeft(seatInfo.member);
                            break;
                        case SeatsMsgType.LINKED_AUDIENCE_ENTER_SEATS:
                            liveRecoder.addUser(seatInfo.member.avRoomUid);
                            updateLiveStreamTask();
                            seatDelegate.onSeatEntered(seatInfo.member);
                            break;
                        case SeatsMsgType.AV_CHANGE:
                            seatDelegate.onSeatMuteStateChanged(seatInfo.member);
                            break;
                    }
                }
            }
        }
    };

    @Override
    public void updateSeatsStream(List<Long> members) {
        liveRecoder.fetchUsers(members);
        updateLiveStreamTask();
    }


    /**
     * 更新推流任务(连麦使用)
     *
     * @return
     */
    protected int updateLiveStreamTask() {
        // 初始化推流任务
        NERtcLiveStreamTaskInfo liveTask = new NERtcLiveStreamTaskInfo();
        //taskID 可选字母、数字，下划线，不超过64位
        liveTask.taskId = liveRecoder.taskId;
        // 一个推流地址对应一个推流任务
        liveTask.url = liveRecoder.pushUlr;
        // 不进行直播录制，请注意与音视频服务端录制区分。
        liveTask.serverRecordEnabled = false;
        // 设置推音视频流还是纯音频流
        liveTask.liveMode = NERtcLiveStreamTaskInfo.NERtcLiveStreamMode.kNERtcLsModeVideo;

        //设置整体布局
        NERtcLiveStreamLayout layout = new NERtcLiveStreamLayout();
        layout.userTranscodingList = new ArrayList<>();
        layout.width = LiveStreamParams.SIGNAL_HOST_LIVE_WIDTH;//整体布局宽度
        layout.height = LiveStreamParams.SIGNAL_HOST_LIVE_HEIGHT;//整体布局高度
        layout.backgroundColor = Color.parseColor("#000000"); // 整体背景色
        liveTask.layout = layout;

        // 设置直播成员布局
        if (liveRecoder.anchorUid != 0) {
            NERtcLiveStreamUserTranscoding anchorUser = new NERtcLiveStreamUserTranscoding();
            anchorUser.uid = liveRecoder.anchorUid; // 用户id
            anchorUser.audioPush = true; // 推流是否发布user1 的音频
            anchorUser.videoPush = true; // 推流是否发布user1的视频

            // 如果发布视频，需要设置一下视频布局参数
            // anchorUser 视频的缩放模式， 详情参考NERtcLiveStreamUserTranscoding 的API 文档
            anchorUser.adaption = NERtcLiveStreamUserTranscoding.NERtcLiveStreamVideoScaleMode.kNERtcLsModeVideoScaleCropFill;
            //独自一个人填充满

            anchorUser.width = LiveStreamParams.SIGNAL_HOST_LIVE_WIDTH; // user1 的视频布局宽度
            anchorUser.height = LiveStreamParams.SIGNAL_HOST_LIVE_HEIGHT; //user1 的视频布局高度

            layout.userTranscodingList.add(anchorUser);
        }

        if (liveRecoder.isLinked() && liveRecoder.audienceUids.size() > 0) {
            int i = 0;
            for (Long uid : liveRecoder.audienceUids) {
                NERtcLiveStreamUserTranscoding audienceUser = new NERtcLiveStreamUserTranscoding();
                audienceUser.uid = uid; // 用户id
                audienceUser.audioPush = true; // 推流是否发布user1 的音频
                audienceUser.videoPush = true; // 推流是否发布user1的视频

                // user1 视频的缩放模式， 详情参考NERtcLiveStreamUserTranscoding 的API 文档
                audienceUser.adaption = NERtcLiveStreamUserTranscoding.NERtcLiveStreamVideoScaleMode.kNERtcLsModeVideoScaleCropFill;
                //独自一个人填充满
                audienceUser.x = LiveStreamParams.AUDIENCE_LINKED_LEFT_MARGIN;
                audienceUser.y = LiveStreamParams.AUDIENCE_LINKED_FIRST_TOP_MARGIN
                        + (LiveStreamParams.AUDIENCE_LINKED_HEIGHT + LiveStreamParams.AUDIENCE_LINKED_BETWEEN_MARGIN) * i;
                audienceUser.width = LiveStreamParams.AUDIENCE_LINKED_WIDTH; // user1 的视频布局宽度
                audienceUser.height = LiveStreamParams.AUDIENCE_LINKED_HEIGHT; //user1 的视频布局高度

                layout.userTranscodingList.add(audienceUser);
                i++;
            }
        }

        ALog.i(LOG_TAG, "addLiveStreamTask recoder = " + liveRecoder.toString());

        int ret = NERtcEx.getInstance().updateLiveStreamTask(liveTask, (s, code) -> {
            if (code == RtcCode.LiveCode.OK) {
                ALog.i(LOG_TAG, "updateLiveStreamTask success : taskId " + liveRecoder.taskId);
            } else {
                ALog.i(LOG_TAG, "updateLiveStreamTask failed : taskId " + liveRecoder.taskId + " , code : " + code);
            }
        });

        if (ret != 0) {
            ALog.i(LOG_TAG, "updateLiveStreamTask failed : taskId " + liveRecoder.taskId + " , ret : " + ret);
        }
        return ret;
    }

    public void handleP2pMsg(String info){
        SeatInfo seatInfo = GsonUtils.fromJson(info, SeatInfo.class);
        if (seatInfo != null && seatDelegate != null) {
            switch (seatInfo.type){
                case SeatsMsgType.UNLINKED_AUDIENCE_APPLY_JOIN_SEATS:
                    seatDelegate.onSeatApplyRequest(seatInfo.index,seatInfo.member);
                    break;
                case SeatsMsgType.UNLINKED_AUDIENCE_CANCEL_APPLY_JOIN_SEATS:
                    seatDelegate.onSeatApplyRequestCanceled(seatInfo.member);
                    break;
                case SeatsMsgType.UNLINKED_AUDIENCE_REJECT_JOIN_SEATS:
                    seatDelegate.onSeatPickRejected(seatInfo.member);
                    break;
            }
        }
    }

    @Override
    public void acceptSeatApply(String userId,  LiveRoomCallback<Void> liveRoomCallback) {
        if (!checkState(liveRoomCallback)) {
            return;
        }
        SeatsManagerInteraction.operateSeats(liveInfo.liveCid, userId, SeatsActionType.ADMIN_ACCEPT_JOIN_SEATS).subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
            @Override
            public void onSuccess(@NonNull BaseResponse<Boolean> booleanBaseResponse) {
                if (booleanBaseResponse.isSuccessful() && booleanBaseResponse.data) {
                    liveRoomCallback.onSuccess(null);
                } else {
                    liveRoomCallback.onError(booleanBaseResponse.code, booleanBaseResponse.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {

            }
        });
    }

    @Override
    public void rejectSeatApply( String userId,  LiveRoomCallback<Void> liveRoomCallback) {
        if (!checkState(liveRoomCallback)) {
            return;
        }
        SeatsManagerInteraction.operateSeats(liveInfo.liveCid, userId, SeatsActionType.ADMIN_REJECT_UNLINKED_AUDIENCE_JOIN_SEATS).subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
            @Override
            public void onSuccess(@NonNull BaseResponse<Boolean> booleanBaseResponse) {
                if (booleanBaseResponse.isSuccessful() && booleanBaseResponse.data) {
                    liveRoomCallback.onSuccess(null);
                } else {
                    liveRoomCallback.onError(booleanBaseResponse.code, booleanBaseResponse.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {

            }
        });
    }

    @Override
    public void pickSeat( String userId,  LiveRoomCallback<Void> callback) {
        if (!checkState(callback)) {
            return;
        }
        SeatsManagerInteraction.operateSeats(liveInfo.liveCid, userId, SeatsActionType.ADMIN_INVITE_JOIN_SEATS).subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
            @Override
            public void onSuccess(@NonNull BaseResponse<Boolean> booleanBaseResponse) {
                if (booleanBaseResponse.isSuccessful() && booleanBaseResponse.data) {
                    callback.onSuccess(null);
                } else {
                    callback.onError(booleanBaseResponse.code, booleanBaseResponse.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {

            }
        });
    }

    @Override
    public void kickSeat( String userId,  LiveRoomCallback<Void> callback) {
        if (!checkState(callback)) {
            return;
        }
        SeatsManagerInteraction.operateSeats(liveInfo.liveCid, userId, SeatsActionType.ADMIN_KICK_SEATS).subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
            @Override
            public void onSuccess(@NonNull BaseResponse<Boolean> booleanBaseResponse) {
                if (booleanBaseResponse.isSuccessful() && booleanBaseResponse.data) {
                    callback.onSuccess(null);
                } else {
                    callback.onError(booleanBaseResponse.code, booleanBaseResponse.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {

            }
        });
    }

    @Override
    public void setSeatOpenState( boolean openState, LiveRoomCallback<Void> callback) {
        int action = openState?SeatsActionType.ADMIN_REOPEN_SEATS:SeatsActionType.ADMIN_CLOSE_SEATS;
        SeatsManagerInteraction.enableSeat(liveInfo.liveCid, action).subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
            @Override
            public void onSuccess(@NonNull BaseResponse<Boolean> booleanBaseResponse) {
                if(booleanBaseResponse.isSuccessful() && booleanBaseResponse.data){
                    callback.onSuccess(null);
                }else {
                    callback.onError(booleanBaseResponse.code,booleanBaseResponse.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {

            }
        });
    }

    @Override
    public void setSeatMuteState(String userId, int audio, int video, LiveRoomCallback<Void> callback) {
        if (!checkState(callback)) {
            return;
        }
        SeatsManagerInteraction.changeSeatAV(liveInfo.liveCid, userId, video, audio).subscribe(new ResourceSingleObserver<BaseResponse<Boolean>>() {
            @Override
            public void onSuccess(@NonNull BaseResponse<Boolean> booleanBaseResponse) {
                if (booleanBaseResponse.isSuccessful() && booleanBaseResponse.data) {
                    callback.onSuccess(null);
                } else {
                    callback.onError(booleanBaseResponse.code, booleanBaseResponse.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {

            }
        });
    }

    private boolean checkState(LiveRoomCallback callback) {
        if (liveStateService.getLiveCurrentState().getStatus() == LiveState.STATE_PKING) {
            callback.onError(ErrorCode.ERROR_CODE_STATE_ERROR, "稍后再试");
            return false;
        }
        return true;
    }

    public void releaseObserve() {
        NIMClient.getService(ChatRoomServiceObserver.class).observeReceiveMessage(chatRoomMsgObserver, false);
    }
}
