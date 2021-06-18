/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.audience.utils;

import android.app.Activity;
import android.widget.ImageView;

import androidx.fragment.app.FragmentActivity;

import com.netease.biz_live.R;
import com.netease.biz_live.yunxin.live.audience.ui.dialog.LinkSeatsStatusDialog;
import com.netease.biz_live.yunxin.live.audience.ui.view.DurationStatisticTimer;
import com.netease.biz_live.yunxin.live.liveroom.LiveRoomCallback;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAudienceLiveRoom;
import com.netease.biz_live.yunxin.live.liveroom.NERTCAudienceLiveRoomDelegate;
import com.netease.biz_live.yunxin.live.liveroom.impl.NERTCAudienceLiveRoomImpl;
import com.netease.biz_live.yunxin.live.model.LiveInfo;
import com.netease.biz_live.yunxin.live.ui.BeautyControl;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;
import com.netease.yunxin.nertc.demo.basic.BuildConfig;

/**
 * @author sunkeding
 * 连麦中的观众的相关动作管理
 */
public class LinkedSeatsAudienceActionManager {
    private volatile static LinkedSeatsAudienceActionManager mInstance;
    private NERTCAudienceLiveRoom nertcLiveRoom;
    /**
     * 美颜控制
     */
    private BeautyControl beautyControl;

    /**
     * 连麦状态弹窗，内部包含美颜，滤镜，挂断，摄像头，麦克风等操作
     */
    private LinkSeatsStatusDialog linkSeatsStatusDialog;
    private Activity activity;
    public static boolean enableLocalVideo = true;
    public static boolean enableLocalAudio = true;
    public LiveInfo liveInfo;

    private LinkedSeatsAudienceActionManager(Activity activity) {
        if (nertcLiveRoom == null) {
            this.activity = activity;
            nertcLiveRoom = NERTCAudienceLiveRoom.sharedInstance();
            nertcLiveRoom.init(activity.getApplicationContext(), BuildConfig.APP_KEY, null);
        }
    }

    public static LinkedSeatsAudienceActionManager getInstance(Activity activity) {
        if (mInstance == null) {
            synchronized (LinkedSeatsAudienceActionManager.class) {
                if (mInstance == null) {
                    mInstance = new LinkedSeatsAudienceActionManager(activity);
                }
            }
        }
        return mInstance;
    }

    public void setData(NERTCAudienceLiveRoomDelegate delegate, LiveInfo liveInfo) {
        this.liveInfo = liveInfo;
        nertcLiveRoom.setDelegate(delegate);
        nertcLiveRoom.setLiveInfo(liveInfo);
    }

    public void joinRtcChannel(String token, String channelName, long uid, String roomCid) {
        nertcLiveRoom.joinRtcChannel(token, channelName, uid, roomCid);
    }

    /**
     * 举手申请上麦
     */
    public void applySeat(String avRoomCid, LiveRoomCallback<Void> callback) {
        nertcLiveRoom.applySeat(avRoomCid, callback);
    }

    /**
     * 取消申请上麦
     *
     * @param roomId
     * @param userId
     * @param leaveSeatCallback
     */
    public void cancelSeatApply(String roomId, String userId, LiveRoomCallback<Void> leaveSeatCallback) {
        nertcLiveRoom.cancelSeatApply(roomId, userId, leaveSeatCallback);
    }

    /**
     * 同意主播的抱麦请求
     *
     * @param roomId
     * @param userId
     * @param callback
     */
    public void acceptSeatPick(String roomId, String userId, LiveRoomCallback<Void> callback) {
        nertcLiveRoom.acceptSeatPick(roomId, userId, callback);
    }

    /**
     * 拒绝主播的抱麦请求
     *
     * @param roomId
     * @param userId
     * @param callback
     */
    public void rejectSeatPick(String roomId, String userId, LiveRoomCallback<Void> callback) {
        nertcLiveRoom.rejectSeatPick(roomId, userId, callback);
    }

    /**
     * 设置麦位静音状态
     *
     * @param indexes  序号数组
     * @param state    静音状态
     * @param ext      json扩展
     * @param callback
     */
    public void setSeatAudioMuteState(int[] indexes, boolean state, String ext, LiveRoomCallback<Void> callback) {
        nertcLiveRoom.setSeatAudioMuteState(indexes, state, ext, callback);
    }

    /**
     * 设置麦位视频状态
     *
     * @param indexes
     * @param state    开闭状态
     * @param ext      json扩展
     * @param callback
     */
    public void setSeatVideoMuteState(int[] indexes, boolean state, String ext, LiveRoomCallback<Void> callback) {
        nertcLiveRoom.setSeatVideoMuteState(indexes, state, ext, callback);
    }

    /**
     * 离开麦位
     */
    public void leaveSeat(String roomId, LiveRoomCallback<Void> callback) {
        nertcLiveRoom.leaveSeat(roomId, callback);
    }

    public void leaveChannel(){
        NERTCAudienceLiveRoomImpl liveRoom= (NERTCAudienceLiveRoomImpl) nertcLiveRoom;
        liveRoom.leaveChannel();
    }

    /**
     * 打开连麦状态设置弹窗
     *
     * @param liveInfo
     */
    public void showLinkSeatsStatusDialog(LiveInfo liveInfo) {
        this.liveInfo = liveInfo;
        if (linkSeatsStatusDialog == null) {
            linkSeatsStatusDialog = new LinkSeatsStatusDialog(activity, this);
        }
        linkSeatsStatusDialog.show();
    }

    public void refreshLinkSeatDialog(int position,int openState) {
        if (linkSeatsStatusDialog != null && linkSeatsStatusDialog.isShowing()) {
            linkSeatsStatusDialog.refreshLinkSeatDialog(position,openState);
        }
    }

    public void switchCamera(ImageView iv) {
        setSeatVideoMuteState(new int[]{0}, !enableLocalVideo, "", new LiveRoomCallback<Void>() {
            @Override
            public void onSuccess(Void parameter) {
                super.onSuccess(parameter);
                enableLocalVideo = !enableLocalVideo;
                nertcLiveRoom.enableLocalVideo(enableLocalVideo);
                if (enableLocalVideo) {
                    iv.setImageResource(R.drawable.biz_live_camera);
                } else {
                    iv.setImageResource(R.drawable.biz_live_camera_close);
                }
            }

            @Override
            public void onError(int code, String msg) {
                if (enableLocalVideo) {
                    iv.setImageResource(R.drawable.biz_live_camera);
                } else {
                    iv.setImageResource(R.drawable.biz_live_camera_close);
                }
            }
        });
    }

    public void switchMicrophone(ImageView iv) {

        setSeatAudioMuteState(new int[]{0}, !enableLocalAudio, "", new LiveRoomCallback<Void>() {
            @Override
            public void onSuccess(Void parameter) {
                super.onSuccess(parameter);
                enableLocalAudio = !enableLocalAudio;
                nertcLiveRoom.muteLocalAudio(!enableLocalAudio);
                if (enableLocalAudio) {
                    iv.setImageResource(R.drawable.biz_live_microphone);
                } else {
                    iv.setImageResource(R.drawable.biz_live_microphone_close);
                }
            }

            @Override
            public void onError(int code, String msg) {
                if (enableLocalAudio) {
                    iv.setImageResource(R.drawable.biz_live_microphone);
                } else {
                    iv.setImageResource(R.drawable.biz_live_microphone_close);
                }
            }
        });
    }

    public void setupRemoteView(NERtcVideoView neRtcVideoView, long uid) {
        nertcLiveRoom.setupRemoteView(neRtcVideoView, uid, false);
    }

    /**
     * 打开美颜设置弹窗
     */
    public void showBeautySettingDialog() {
        if (beautyControl == null) {
            beautyControl = new BeautyControl((FragmentActivity) activity);
            beautyControl.initFaceUI();
            beautyControl.openBeauty();
        }
        beautyControl.showBeautyDialog();
        if (linkSeatsStatusDialog != null && linkSeatsStatusDialog.isShowing()) {
            linkSeatsStatusDialog.dismiss();
        }
    }

    /**
     * 打开滤镜设置弹窗
     */
    public void showFilterSettingDialog() {
        if (beautyControl == null) {
            beautyControl = new BeautyControl((FragmentActivity) activity);
            beautyControl.initFaceUI();
            beautyControl.openBeauty();
        }
        beautyControl.showFilterDialog();
        if (linkSeatsStatusDialog != null && linkSeatsStatusDialog.isShowing()) {
            linkSeatsStatusDialog.dismiss();
        }
    }


    /**
     * 销毁资源,会在 {@link com.netease.biz_live.yunxin.live.audience.ui.LiveAudienceActivity#finish()}触发
     */
    public void onDestory() {
        if (linkSeatsStatusDialog != null) {
            if (linkSeatsStatusDialog.isShowing()) {
                linkSeatsStatusDialog.dismiss();
            }
            linkSeatsStatusDialog = null;
        }
        // 销毁美颜、滤镜相关资源
        if (beautyControl != null) {
            beautyControl.onDestroy();
            beautyControl = null;
        }
        DurationStatisticTimer.DurationUtil.reset();
        enableLocalVideo=true;
        enableLocalAudio=true;
    }

    public void dismissAllDialog(){
        if (linkSeatsStatusDialog != null) {
            if (linkSeatsStatusDialog.isShowing()) {
                linkSeatsStatusDialog.dismiss();
            }
        }
        // 销毁美颜、滤镜相关资源
        if (beautyControl != null) {
            beautyControl.dismissAllDialog();
        }
    }

    public void enableVideo(boolean open) {
        nertcLiveRoom.enableLocalVideo(open);
    }

    public void enableAudio(boolean oepn) {
        nertcLiveRoom.muteLocalAudio(!oepn);
    }
    public void destoryInstance(){
        NERTCAudienceLiveRoomImpl liveRoomImpl= (NERTCAudienceLiveRoomImpl) NERTCAudienceLiveRoom.sharedInstance();
        liveRoomImpl.registerMsgCallback(false);
        liveRoomImpl.setVideoCallback(null, false);
        NERTCAudienceLiveRoom.destroySharedInstance();
        if (mInstance!=null){
            mInstance=null;
        }
        if (linkSeatsStatusDialog!=null){
            linkSeatsStatusDialog=null;
        }
        if (beautyControl!=null){
            beautyControl=null;
        }
        if (activity!=null){
            activity=null;
        }
        if (liveInfo!=null){
            liveInfo=null;
        }
    }
}
