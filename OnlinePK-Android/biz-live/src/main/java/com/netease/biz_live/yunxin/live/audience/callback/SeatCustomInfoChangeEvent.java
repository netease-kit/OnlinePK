package com.netease.biz_live.yunxin.live.audience.callback;

public class SeatCustomInfoChangeEvent {
    /**
     * 序号数组
     */
    public int[] indexes;
    /**
     * 操作者
     */
    public long operator;
    public boolean openState;

    public SeatCustomInfoChangeEvent(int[] indexes, long operator, boolean openState) {
        this.indexes = indexes;
        this.operator = operator;
        this.openState = openState;
    }
}
