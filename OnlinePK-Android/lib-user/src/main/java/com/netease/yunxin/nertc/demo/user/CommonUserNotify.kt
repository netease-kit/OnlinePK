/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user

/**
 * Created by luc on 2020/11/16.
 */
abstract class CommonUserNotify : UserCenterServiceNotify {
    override fun onUserLogin(success: Boolean, code: Int) {}
    override fun onUserLogout(success: Boolean, code: Int) {}
    override fun onError(exception: Throwable?) {}
    override fun onUserInfoUpdate(model: UserModel?) {}
}