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
