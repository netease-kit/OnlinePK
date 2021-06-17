package com.netease.biz_live.yunxin.live.constant;

/**
 * 麦位枚举
 */
public @interface SeatsStatus {
    /**
     * 麦位初始化（无人，可以上麦）
     */
    int SEATS_INIT = 0;
    /**
     * 麦位正在被申请（无人）
     */
    int SEATS_APPLING = 1;
    /**
     * 麦位上有人
     */
    int SEATS_HAS_JOINED = 2;
    /**
     * 麦位关闭（无人）
     */
    int SEATS_EMPTY = 3;
}
