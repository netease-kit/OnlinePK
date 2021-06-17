package com.netease.biz_live.yunxin.live.audience.callback;

import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;

public class SeatApplyRejectEvent {
    public int index;
    public SeatMemberInfo member;
    public long responder;
    /**
     * rejectSeatApply时传入的JSON扩展
     */
    public String ext;

    public SeatApplyRejectEvent(int index, SeatMemberInfo member, long responder, String ext) {
        this.index = index;
        this.member = member;
        this.responder = responder;
        this.ext = ext;
    }

}
