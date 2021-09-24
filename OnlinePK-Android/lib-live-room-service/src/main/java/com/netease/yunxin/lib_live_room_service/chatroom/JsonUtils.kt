/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.chatroom

import com.google.gson.Gson
import org.json.JSONException
import org.json.JSONObject

/**
 * Created by luc on 2020/11/18.
 */
internal object JsonUtils {
    /**
     * 获取当前结构体类型
     *
     * @param json 结构体
     * @return 类型信息
     */
    fun getType(json: String): Int {
        var type: Int = CustomAttachmentType.UNKNOWN
        try {
            val `object` = JSONObject(json)
            type = `object`.optInt(
                BaseCustomAttachment.KEY_JSON_TYPE,
                CustomAttachmentType.UNKNOWN
            )
        } catch (e: JSONException) {
            e.printStackTrace()
        }
        return type
    }

    fun <T : BaseCustomAttachment> toMsgAttachment(json: String?, clazz: Class<T>): T {
        return Gson().fromJson(json, clazz)
    }
}