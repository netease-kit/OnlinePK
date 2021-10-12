/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.bean

data class PkEndInfo(
    val pkStartTime: Long,//	PK 开始时间
    val pkEndTime: Long,//	PK 结束时间
    val reason:Int,//1 normal 2 abnormal
    val inviterRewards: Long,//	邀请者打赏总额
    val inviteeRewards: Long,//	被邀请者打赏总额
    val countDownEnd: Boolean//	是否计时结束
)