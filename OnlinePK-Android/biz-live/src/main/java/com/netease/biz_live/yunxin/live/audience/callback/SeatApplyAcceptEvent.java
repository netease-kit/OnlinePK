package com.netease.biz_live.yunxin.live.audience.callback;

import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;

public class SeatApplyAcceptEvent {
    public int index;
    public SeatMemberInfo member;
    /**
     * 回应者
     */
    public long responder;
    /**
     * acceptSeatApply时传入的JSON扩展
     */
    public String ext;

    public SeatApplyAcceptEvent(int index, SeatMemberInfo member, long responder, String ext) {
        this.index = index;
        this.member = member;
        this.responder = responder;
        this.ext = ext;
    }
}
