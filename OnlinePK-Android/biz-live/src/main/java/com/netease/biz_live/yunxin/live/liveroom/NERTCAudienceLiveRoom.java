/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom;

import com.netease.biz_live.yunxin.live.liveroom.impl.NERTCAudienceLiveRoomImpl;
import com.netease.biz_live.yunxin.live.model.LiveInfo;

/**
 * 观众端LiveRoom
 */
public abstract class NERTCAudienceLiveRoom extends NERTCLiveRoom {

    public static NERTCAudienceLiveRoom sharedInstance() {

        return NERTCAudienceLiveRoomImpl.sharedInstance();
    }

    /**
     * 设置组件回调接口
     * <p>
     * 您可以通过 NERTCAudienceLiveRoomDelegate 获得 NERTCLiveRoom 的各种状态通知
     *
     * @param delegate 回调接口
     */
    public abstract void setDelegate(NERTCAudienceLiveRoomDelegate delegate);

    /**
     * 结束直播后调用
     */
    public static void destroySharedInstance() {
        NERTCAudienceLiveRoomImpl.destroySharedInstance();
    }

    /**
     * 申请上麦
     *
     * @param roomId
     * @param applySeatCallback 回调
     */
    public abstract void applySeat(String roomId, LiveRoomCallback<Void> applySeatCallback);

    /**
     * 离开麦位
     * @param leaveSeatCallback 回调
     */
    public abstract void leaveSeat(String roomId, LiveRoomCallback<Void> leaveSeatCallback);

    /**
     * 取消申请
     *
     * @param leaveSeatCallback
     */
    public abstract void cancelSeatApply(String roomId, String userId, LiveRoomCallback<Void> leaveSeatCallback);

    /**
     * 同意主播的抱麦请求
     *
     * @param roomId
     * @param userId
     * @param leaveSeatCallback
     */
    public abstract void acceptSeatPick(String roomId, String userId, LiveRoomCallback<Void> leaveSeatCallback);

    /**
     * 拒绝主播的抱麦请求
     *
     * @param roomId
     * @param userId
     * @param leaveSeatCallback
     */
    public abstract void rejectSeatPick(String roomId, String userId, LiveRoomCallback<Void> leaveSeatCallback);

    /**
     * 设置麦位静音状态
     *
     * @param indexes           序号数组
     * @param state             静音状态
     * @param ext               json扩展
     * @param leaveSeatCallback
     */
    public abstract void setSeatAudioMuteState(int[] indexes, boolean state, String ext, LiveRoomCallback<Void> leaveSeatCallback);

    /**
     * 设置麦位视频状态
     *
     * @param indexes
     * @param state             开闭状态
     * @param ext               json扩展
     * @param leaveSeatCallback
     */
    public abstract void setSeatVideoMuteState(int[] indexes, boolean state, String ext, LiveRoomCallback<Void> leaveSeatCallback);

    /**
     * 设置直播间信息
     * @param liveInfo
     */
    public abstract void setLiveInfo(LiveInfo liveInfo);
}
