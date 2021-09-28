/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.utils

import android.text.TextUtils
import com.netease.yunxin.nertc.demo.user.UserCenterService
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr

object AccountUtil {
    fun isCurrentUser(accountId: String?): Boolean {
        val currentUser =
            ModuleServiceMgr.instance.getService(UserCenterService::class.java).currentUser
        return currentUser != null && !TextUtils.isEmpty(currentUser.accountId) && currentUser.accountId == accountId
    }
}