/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.bean

data class PkPunishInfo(
    val pkStartTime: Long,//	PK 开始时间
    val pkPenaltyCountDown: Int,//	PK 惩罚时间倒计时，单位：秒（s）
    val inviterRewards: Long,//	邀请者打赏总额
    val inviteeRewards: Long,//	被邀请者打赏总额
)