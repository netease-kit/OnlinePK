package com.netease.biz_live.yunxin.live.constant;

/**
 * 麦克风操作，开启，关闭，强制关闭
 */
public @interface AudioActionType {
    int DEFAULT=-1;
    int CLOSE=0;
    int OPEN=1;
    int FORCE_CLOSE=2;
}
