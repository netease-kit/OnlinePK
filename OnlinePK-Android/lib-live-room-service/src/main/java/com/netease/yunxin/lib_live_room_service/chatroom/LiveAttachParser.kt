/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.chatroom

import com.netease.nimlib.sdk.msg.attachment.MsgAttachment
import com.netease.nimlib.sdk.msg.attachment.MsgAttachmentParser

/**
 * Created by luc on 2020/11/18.
 *
 *
 * 直播自定义消息解析
 */
object LiveAttachParser : MsgAttachmentParser {
    override fun parse(json: String): MsgAttachment? {
        var result: MsgAttachment? = null
        when (JsonUtils.getType(json)) {
            CustomAttachmentType.CHAT_ROOM_TEXT -> {
                result = JsonUtils.toMsgAttachment(json, TextWithRoleAttachment::class.java)
            }
            CustomAttachmentType.CHAT_ROOM_REWARD -> {
                result = JsonUtils.toMsgAttachment(json, RewardMsg::class.java)
            }
            else -> {
            }
        }
        return result
    }
}