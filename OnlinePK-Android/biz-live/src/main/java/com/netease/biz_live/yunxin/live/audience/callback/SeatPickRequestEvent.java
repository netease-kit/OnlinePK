/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.audience.callback;

import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;

public class SeatPickRequestEvent {
    public int index;
    public SeatMemberInfo member;
    /**
     * 发起者（房主）
     */
    public String applicant;
    public String ext;

    public SeatPickRequestEvent(int index, SeatMemberInfo member, String applicant, String ext) {
        this.index = index;
        this.member = member;
        this.applicant = applicant;
        this.ext = ext;
    }
}
