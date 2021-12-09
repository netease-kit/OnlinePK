/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.bean

import java.io.Serializable

data class LiveUser(
    val accountId: String,//	用户编号
    val imAccid: String,//	IM 用户编号
    val roomUid: Long?,//	房间用户编号
    val nickname: String,//	昵称
    val avatar: String,//	头像地址
    val roomCheckSum: String?,//	房间校验码
) : Serializable {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        val that = other as LiveUser?
        if (imAccid != that?.imAccid) return false
        return if (accountId != null) accountId == that.accountId else that.accountId == null
    }

    override fun hashCode(): Int {
        return accountId.hashCode()
    }

    override fun toString(): String {
        return "LiveUser(accountId='$accountId', imAccid='$imAccid', roomUid=$roomUid, nickname='$nickname', avatar='$avatar', roomCheckSum=$roomCheckSum)"
    }

}