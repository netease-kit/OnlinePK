/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.bean

import com.netease.yunxin.lib_live_pk_service.Constants.FailedReason
import com.netease.yunxin.lib_live_pk_service.Constants.PkAction

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
    val targetAnchor: PkTargetAnchor
)