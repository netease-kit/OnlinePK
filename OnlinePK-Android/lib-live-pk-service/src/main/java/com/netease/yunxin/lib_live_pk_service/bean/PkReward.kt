/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.bean

data class PkReward(
    val rewardCoinTotal: Long,//	打赏总金额
    val rewardTop: List<PkRewardAudience>
)

data class PkRewardAudience(
    val accountId: String,//	用户编号
    val imAccid: String,//	IM 用户编号
    val nickname: String,//	昵称
    val avatar: String,//	头像地址
    val rewardCoin: Long,//	本 PK 直播时段打赏主播总额
)