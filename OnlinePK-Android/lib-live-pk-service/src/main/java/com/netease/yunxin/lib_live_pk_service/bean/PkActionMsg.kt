/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.bean

import com.netease.yunxin.lib_live_pk_service.PkConstants.FailedReason
import com.netease.yunxin.lib_live_pk_service.PkConstants.PkAction

data class PkActionMsg(

    val type:Int,

    /**
     * pk action [PkAction]
     */
    val action: Int,
    /**
     * fail reason [FailedReason]
     */
    val failReason: Int,
    val actionAnchor: PkUserInfo,
    val targetAnchor: PkTargetAnchor,
    val pkId: String,
    val pkConfig: PkConfig?
)