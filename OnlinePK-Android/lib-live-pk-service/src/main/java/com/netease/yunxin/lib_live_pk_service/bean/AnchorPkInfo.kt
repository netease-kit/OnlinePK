/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.bean

data class AnchorPkInfo(
    val pkId: String,
    val pkConfig: PkConfig?
)

data class PkConfig(
    val agreeTaskTime: Int,
    val inviteTaskTime: Int
)