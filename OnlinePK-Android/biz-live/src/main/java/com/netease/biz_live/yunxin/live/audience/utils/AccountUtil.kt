/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.utils

import android.text.TextUtils
import com.netease.yunxin.login.sdk.AuthorManager

object AccountUtil {
    fun isCurrentUser(accountId: String?): Boolean {
        val currentUser =
            AuthorManager.getUserInfo()
        return currentUser != null && !TextUtils.isEmpty(currentUser.accountId) && currentUser.accountId == accountId
    }
}