/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.model.response;

import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;

import java.io.Serializable;
import java.util.List;

public class SeatsResponse implements Serializable {

    /**
     * 观众列表
     */
    public List<SeatMemberInfo> seatList;

    /**
     * 申请人数
     */
    public int applyCount;

    /**
     * 麦上人数
     */
    public int seatCount;
}
