/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom;

import java.util.List;

/**
 * 主播麦位管理
 */
public interface AnchorSeatManager {

    /**
     * 接受上麦邀请
     * @param userId
     * @param liveRoomCallback
     */
    void acceptSeatApply(String userId,LiveRoomCallback<Void> liveRoomCallback);

    /**
     * 拒绝上麦邀请
     * @param userId
     * @param liveRoomCallback
     */
    void rejectSeatApply(String userId,LiveRoomCallback<Void> liveRoomCallback);

    /**
     * 抱麦
     * @param userId
     * @param callback
     */
    void pickSeat(String userId,LiveRoomCallback<Void> callback);

    /**
     * 踢麦
     * @param userId
     * @param callback
     */
    void kickSeat(String userId, LiveRoomCallback<Void> callback);

    /**
     * 麦位关闭/开启
     * @param openState  true开启，false关闭
     * @param callback
     */
    void setSeatOpenState(boolean openState,LiveRoomCallback<Void> callback);

    /**
     * 麦位音视频变化
     *
     * @param userId
     * @param audio
     * @param video
     * @param callback
     */
    void setSeatMuteState(String userId, int audio, int video, LiveRoomCallback<Void> callback);

    /**
     * 同步麦位推流信息（比如断网case）
     *
     * @param members
     */
    void updateSeatsStream(List<Long> members);
}
