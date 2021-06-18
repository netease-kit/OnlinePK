/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom;

import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;

/**
 * 连麦直播主播端回调
 */
public interface AnchorSeatDelegate {
    /**
     * 观众申请上麦
     * @param index
     * @param member
     */
    void onSeatApplyRequest(int index, SeatMemberInfo member);

    /**
     * 观众取消申请
     * @param member
     */
    void onSeatApplyRequestCanceled(SeatMemberInfo member);

    /**
     * 抱麦申请被拒绝
     * @param member
     */
    void onSeatPickRejected(SeatMemberInfo member);

    /**
     * 观众上麦
     * @param member
     */
    void onSeatEntered(SeatMemberInfo member);

    /**
     * 观众下麦
     *
     * @param member
     */
    void onSeatLeft(SeatMemberInfo member);

    /**
     * 麦位上的观众音视频状态变化
     *
     * @param member
     */
    void onSeatMuteStateChanged(SeatMemberInfo member);
}
