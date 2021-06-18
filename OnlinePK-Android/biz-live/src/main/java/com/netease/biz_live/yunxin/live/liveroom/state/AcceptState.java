/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom.state;


import com.netease.biz_live.yunxin.live.liveroom.impl.NERTCAnchorInteractionLiveRoomImpl;

/**
 * 对方已经接受，或者已经接受对方，即将进入PK状态
 */
public class AcceptState extends LiveState {

    public AcceptState(NERTCAnchorInteractionLiveRoomImpl liveRoom) {
        super(liveRoom);
        status = STATE_ACCEPTED;
    }

    @Override
    public void callPk() {

    }

    @Override
    public void invited() {

    }

    @Override
    public void startPk() {
        this.liveRoom.setState(liveRoom.getPkingState());
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
        liveRoom.setState(liveRoom.getOffState());
    }
}
