/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.bean

data class PkInfo(
    val appId: Long,//	应用编号
    val pkId: String,//	pk 编号
    val status: Int,//	pk 状态
    val countDown: Int,//剩余时间（s）
    val pkStartTime: Long,//	pk 开始时间
    val pkEndTime: Long,//	pk 结束时间
    val inviter: PkUserInfo,//邀请者信息
    val invitee: PkUserInfo,//被邀请者信息
    val inviterReward: PkReward,//	邀请者打赏信息
    val inviteeReward: PkReward,//被邀请者打赏信息
)