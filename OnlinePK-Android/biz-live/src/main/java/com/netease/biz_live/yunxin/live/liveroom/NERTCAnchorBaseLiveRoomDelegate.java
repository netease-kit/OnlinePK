/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom;

import com.netease.biz_live.yunxin.live.model.message.MsgReward;

public interface NERTCAnchorBaseLiveRoomDelegate {

    /**
     * 主播开启直播，收到服务端消息，正式开始直播（由IM消息触发）
     */
    void onRoomLiveStart();


    /**
     * 观众打赏（由IM消息触发）
     *
     * @param reward
     */
    void onUserReward(MsgReward.RewardBody reward);

    /**
     * 音效结束回调
     * @param effectId 指定音效的 ID。每个音效均有唯一的 ID
     */
    void onAudioEffectFinished(int effectId);

    /**
     * 背景音乐结束回调
     */
    void onAudioMixingFinished();

    /**
     * 错误回调
     *
     * @param serious 是否严重
     * @param code    错误码
     * @param msg     错误信息
     */
    void onError(boolean serious, int code, String msg);

    /**
     * 获取服务，如PK
     * @param tClass
     * @param <T>
     * @return
     */
     <T> T getDelegateService(Class<T> tClass);
}
