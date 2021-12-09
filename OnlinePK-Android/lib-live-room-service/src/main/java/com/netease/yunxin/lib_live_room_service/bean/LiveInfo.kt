/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.bean

import java.io.Serializable

/**
 * 直播间直播信息
 */
class LiveInfo : Serializable {
    var appId: Long = 0//	应用编号
    lateinit var anchor: LiveUser//主播信息
    var joinUserInfo: LiveUser? = null//加入房间的观众信息
    lateinit var live: LiveMsg //房间信息
    override fun toString(): String {
        return "LiveInfo(appId=$appId, anchor=$anchor, joinUserInfo=$joinUserInfo, live=$live)"
    }

}