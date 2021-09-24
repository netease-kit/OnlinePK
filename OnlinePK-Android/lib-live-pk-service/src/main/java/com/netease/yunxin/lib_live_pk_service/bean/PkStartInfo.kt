/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.bean

data class PkStartInfo(
    val pkStartTime: Long,//	PK 开始时间
    val pkCountDown: Int,//	PK 时间倒计时，单位：秒（s）
    val inviter: PkUserInfo,//	邀请者信息
    val invitee: PkUserInfo//	被邀请者信息
)