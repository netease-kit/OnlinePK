/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.impl

import com.blankj.utilcode.util.GsonUtils
import com.google.gson.JsonObject
import com.netease.nimlib.sdk.msg.attachment.MsgAttachment
import com.netease.nimlib.sdk.msg.attachment.MsgAttachmentParser
import com.netease.yunxin.lib_live_pk_service.Constants
import com.netease.yunxin.lib_live_pk_service.bean.PkEndInfo
import com.netease.yunxin.lib_live_pk_service.bean.PkPunishInfo
import com.netease.yunxin.lib_live_pk_service.bean.PkStartInfo

/**
 * Pk attach parser
 *
 * @constructor Create empty Pk attach parser
 */
object PkAttachParser : MsgAttachmentParser {
    override fun parse(json: String): MsgAttachment? {
        var result: MsgAttachment? = null
        when (getType(json)) {
            Constants.PkMsgType.PK_START -> {
                result = GsonUtils.fromJson(json, PkStartInfo::class.java)
            }
            Constants.PkMsgType.PK_PUNISH -> {
                result = GsonUtils.fromJson(json, PkPunishInfo::class.java)
            }
            Constants.PkMsgType.PK_STOP -> {
                result = GsonUtils.fromJson(json, PkEndInfo::class.java)
            }
        }
        return result
    }

    private fun getType(json: String): Int? {
        val jsonObject: JsonObject = GsonUtils.fromJson(
            json,
            JsonObject::class.java
        )
        return jsonObject["type"]?.asInt
    }
}