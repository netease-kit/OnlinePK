package com.netease.biz_live.yunxin.live.liveroom.state;

import com.netease.biz_live.yunxin.live.liveroom.impl.NERTCAnchorInteractionLiveRoomImpl;

public class InvitedState extends LiveState {

    public InvitedState(NERTCAnchorInteractionLiveRoomImpl liveRoom) {
        super(liveRoom);
        status = STATE_INVITED;
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
        liveRoom.setState(liveRoom.getAcceptState());
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
