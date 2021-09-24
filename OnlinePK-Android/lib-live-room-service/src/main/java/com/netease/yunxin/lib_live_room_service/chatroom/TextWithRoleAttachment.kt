/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.chatroom

import com.google.gson.Gson
import com.google.gson.annotations.SerializedName

/**
 * Created by luc on 2020/11/26.
 * 附带是否主播信息的文本自定义消息
 */
class TextWithRoleAttachment(
    /**
     * 消息发送方是否为主播
     */
    @field:SerializedName("isAnchor") var isAnchor: Boolean,
    /**
     * 实际传输的文本消息
     */
    @field:SerializedName("message") var msg: String?
) : BaseCustomAttachment() {
    override fun toJson(send: Boolean): String? {
        return Gson().toJson(this)
    }

    init {
        type = CustomAttachmentType.CHAT_ROOM_TEXT
    }
}