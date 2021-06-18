/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom.msg;

import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;

import java.io.Serializable;

/**
 * 服务端定义的麦位变更协议
 */
public class SeatInfo implements Serializable {
    /**
     * 当前麦位状态 0-3，详见麦位状态
     */
    public int status;

    /**
     * 当前麦位0-7
     */
    public int index;

    /**
     * 麦位状态通知type，详见麦位状态变更原因
     */
    public int type;
    /**
     * 消息是谁触发的。
     */
    public String fromUser;

    /**
     * 麦上观众信息
     */
    public SeatMemberInfo member;

}
