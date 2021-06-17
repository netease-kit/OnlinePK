package com.netease.biz_live.yunxin.live.liveroom;

import com.netease.biz_live.yunxin.live.liveroom.state.LiveState;

public interface LiveStateService {
    /**
     * 获取当前的状态
     *
     * @return
     */
    LiveState getLiveCurrentState();
}
