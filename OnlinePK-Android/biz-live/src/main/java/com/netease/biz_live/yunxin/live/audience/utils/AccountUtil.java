/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.audience.utils;

import android.text.TextUtils;

import com.netease.yunxin.nertc.demo.user.UserCenterService;
import com.netease.yunxin.nertc.demo.user.UserModel;
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr;

public class AccountUtil {
    public static boolean isCurrentUser(String accountId){
        UserModel currentUser = ModuleServiceMgr.getInstance().getService(UserCenterService.class).getCurrentUser();
        return currentUser != null && !TextUtils.isEmpty(currentUser.accountId) && currentUser.accountId.equals(accountId);
    }
}
