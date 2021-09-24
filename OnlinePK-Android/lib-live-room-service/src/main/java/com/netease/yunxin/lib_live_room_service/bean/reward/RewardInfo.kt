/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.bean.reward

data class RewardInfo(
    val pkStartTime: Long,//	PK 开始时间
    val rewarderAccountId: String,//	打赏者用户编号
    val rewarderNickname: String,//	打赏者昵称
    val giftId: Int,//	礼物编号
    val memberTotal: Long,//	房间人数
    val anchorReward: AnchorRewardInfo,//	被打赏主播打赏信息
    val otherAnchorReward: AnchorRewardInfo?,//	其他主播打赏信息
)