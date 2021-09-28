/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.bean

/**
 * target anchor user this join rtc channel
 */
data class PkTargetAnchor(
    val roomUid: Long,//	房间用户 UID
    val checkSum: String//	房间校验码
)