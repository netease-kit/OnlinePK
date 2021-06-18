/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.chatroom.custom;

import com.google.gson.Gson;

/**
 * Created by luc on 2020/11/18.
 * <p>
 * 自定义消息，pk 状态
 */
public class PkStatusAttachment extends StateCustomAttachment {


    public PkStatusAttachment(int anchorWin) {
        super(anchorWin);
        this.type = CustomAttachmentType.CHAT_ROOM_PK;
    }

    public PkStatusAttachment(long startedTimestamp, long currentTimestamp, String otherAnchorNickname, String otherAnchorAvatar) {
        super(startedTimestamp, currentTimestamp, otherAnchorNickname, otherAnchorAvatar);
        this.type = CustomAttachmentType.CHAT_ROOM_PK;
    }

    @Override
    public String toJson(boolean send) {
        return new Gson().toJson(this);
    }
}
