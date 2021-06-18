/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

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
