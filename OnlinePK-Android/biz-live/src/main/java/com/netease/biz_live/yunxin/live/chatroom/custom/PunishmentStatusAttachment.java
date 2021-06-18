/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.chatroom.custom;

import com.google.gson.Gson;

/**
 * Created by luc on 2020/11/18.
 * <p>
 * 自定义消息，惩罚通知
 */
public class PunishmentStatusAttachment extends StateCustomAttachment {


    public PunishmentStatusAttachment() {
        super();
        this.type = CustomAttachmentType.CHAT_ROOM_PUNISHMENT;
    }

    public PunishmentStatusAttachment(long startedTimestamp, long currentTimestamp,int anchorWin) {
        super(false,startedTimestamp, currentTimestamp, null, null,anchorWin);
        this.type = CustomAttachmentType.CHAT_ROOM_PUNISHMENT;
    }

    @Override
    public String toJson(boolean send) {
        return new Gson().toJson(this);
    }
}
