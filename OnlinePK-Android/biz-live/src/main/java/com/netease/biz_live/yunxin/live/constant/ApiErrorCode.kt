/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.constant

interface ApiErrorCode {
    companion object {
        /**
         * 用户已经申请麦位
         */
        const val HAD_APPLIED_SEAT = 700

        /**
         * 用户没有申请麦位
         */
        const val DONT_APPLY_SEAT = 701
    }
}