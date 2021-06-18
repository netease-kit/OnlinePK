/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom;

import com.netease.biz_live.yunxin.live.audience.callback.SeatApplyAcceptEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatApplyRejectEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatMuteStateChangeEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatCustomInfoChangeEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatEnterEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatKickedEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatLeaveEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatPickRequestEvent;
import com.netease.biz_live.yunxin.live.audience.callback.SeatVideoOpenStateChangeEvent;

public interface NERTCAudienceLiveRoomDelegate {

    /**
     * 错误回调
     *
     * @param serious 是否严重
     * @param code    错误码
     * @param msg     错误信息
     */
    void onError(boolean serious, int code, String msg);

    /**
     * 麦位加入的回调
     */
    void onSeatEntered(SeatEnterEvent event);

    /**
     * 麦位离开的回调
     */
    void onSeatLeft(SeatLeaveEvent event);

    /**
     * 麦位被踢的回调
     */
    void onSeatKicked(SeatKickedEvent event);

    /**
     * 收到主播抱麦申请
     */
    void onSeatPickRequest(SeatPickRequestEvent event);

    /**
     * 申请上麦被同意
     */
    void onSeatApplyAccepted(SeatApplyAcceptEvent event);

    /**
     * 申请上麦被拒绝
     */
    void onSeatApplyRejected(SeatApplyRejectEvent event);

    /**
     * 麦位音视频状态回调
     */
    void onSeatMuteStateChanged(SeatMuteStateChangeEvent event);

    /**
     * 麦位开关状态回调,多人连麦用不到
     */
    void onSeatOpenStateChanged(SeatVideoOpenStateChangeEvent event);

    /**
     * 自定义状态变更的回调，多人连麦暂时还用不到
     */
    void onSeatCustomInfoChanged(SeatCustomInfoChangeEvent event);
}
