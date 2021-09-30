/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.bean.reward

import java.io.Serializable

data class AnchorRewardInfo(
    val accountId: String,//	用户编号
    val pkRewardTotal: Long,//	PK 时段打赏总额
    val rewardTotal: Long,//	直播打赏总额
    val pkRewardTop: List<RewardAudience>?//	PK 直播时段打赏排行（前三）
) : Serializable