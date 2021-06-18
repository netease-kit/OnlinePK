/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.model.message;

/**
 * PK 结束的消息体
 */
public class MsgPkEnd extends NotificationMessage<MsgPkEnd.PkEndBody> {

    public static class PkEndBody {
        public String operUser;//: 操作者账号,
        public String fromUser;//: 1111,
        public String fromUserAvRoomUid;//: 1111,
        public String roomCid;//:直播房间频道号,
        public String currentTime;//: 111111,
        public String pkEndTime;//: 111111,
        public boolean countdownEnd;//是否是倒计时结束的
        /**
         * 发起者的昵称，如果是countdownEnd true，则为空
         */
        public String closedNickname;
    }
}
