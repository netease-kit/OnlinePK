package com.netease.biz_live.yunxin.live.audience.callback;

import com.netease.biz_live.yunxin.live.model.SeatMemberInfo;

public class SeatEnterEvent {
    public int index;
    public SeatMemberInfo member;
    public String ext;

    public SeatEnterEvent(int index, SeatMemberInfo member, String ext) {
        this.index = index;
        this.member = member;
        this.ext = ext;
    }
}
