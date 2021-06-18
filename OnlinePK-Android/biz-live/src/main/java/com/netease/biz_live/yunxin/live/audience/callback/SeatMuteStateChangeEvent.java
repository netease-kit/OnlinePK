/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.audience.callback;

import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;

public class SeatMuteStateChangeEvent {
    /**
     * 消息是谁触发的
     */
    public String fromUser;
    /**
     * 音视频状态变化的member
     */
    public SeatMemberInfo member;
    /**
     * 静音状态, 开启/静音/强制静音
     */
    public int state;

    public SeatMuteStateChangeEvent(String fromUser, SeatMemberInfo member, int state) {
        this.fromUser = fromUser;
        this.member = member;
        this.state = state;
    }

}
