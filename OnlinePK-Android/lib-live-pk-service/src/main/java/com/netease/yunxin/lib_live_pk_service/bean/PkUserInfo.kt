/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.bean

import java.io.Serializable

data class PkUserInfo(
    val roomId: String,//	房间编号
    val channelName: String,//	音视频房间名称
    val accountId: String,//	用户编号
    val nickname: String,//	昵称
    val avatar: String,//	头像地址
    val roomUid: Long,//rtc channel uid
    val rewardTotal: Long,//	打赏总额
) : Serializable