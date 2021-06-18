/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom.state;

import com.netease.biz_live.yunxin.live.liveroom.impl.NERTCAnchorInteractionLiveRoomImpl;

public class OffState extends LiveState {
    public OffState(NERTCAnchorInteractionLiveRoomImpl liveRoom) {
        super(liveRoom);
        status = LiveState.STATE_LIVE_OFF;
    }

    @Override
    public void callPk() {

    }

    @Override
    public void invited() {

    }

    @Override
    public void startPk() {

    }

    @Override
    public void accept() {

    }

    @Override
    public void release() {
        this.liveRoom.setState(liveRoom.getIdleState());
    }

    @Override
    public void offLive() {

    }
}
