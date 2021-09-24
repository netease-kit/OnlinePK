/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.chatroom

import com.google.gson.annotations.SerializedName
import com.netease.nimlib.sdk.msg.attachment.MsgAttachment

/**
 * Created by luc on 2020/11/19.
 */
abstract class BaseCustomAttachment : MsgAttachment {
    @SerializedName(KEY_JSON_TYPE)
    var type = 0

    companion object {
        const val KEY_JSON_TYPE: String = "type"
    }
}