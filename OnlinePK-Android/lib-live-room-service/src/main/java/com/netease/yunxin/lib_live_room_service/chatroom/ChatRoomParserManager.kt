/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.chatroom

import com.netease.nimlib.sdk.msg.attachment.MsgAttachment
import com.netease.nimlib.sdk.msg.attachment.MsgAttachmentParser

/**
 * Chat room parser manager
 * 聊天室消息解析管理器，这个管理器在加入聊天室的时候注册给聊天室，其他解析器使用时加入管理器，不使用时remove
 * @constructor Create empty Chat room parser manager
 */
object ChatRoomParserManager : MsgAttachmentParser {

    private val parsers: ArrayList<MsgAttachmentParser> = ArrayList()


    /**
     * 将一个字符串解析为一个云信消息附件。一般而言，该字符串是一个json字符串。
     * @param attach 附件序列化后的字符串内容
     * @return 解析结果
     */
    override fun parse(attach: String?): MsgAttachment? {
        var result: MsgAttachment? = null
        for (parser in parsers) {
            result = parser.parse(attach)
            if (result != null) {
                return result
            }
        }
        return result
    }

    fun addParser(parser: MsgAttachmentParser) {
        parsers.add(parser)
    }

    fun remove(parser: MsgAttachmentParser) {
        parsers.remove(parser)
    }

}