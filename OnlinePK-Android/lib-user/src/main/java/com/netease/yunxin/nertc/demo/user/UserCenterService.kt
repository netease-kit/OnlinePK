/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user

import android.app.Activity
import android.content.Context
import com.netease.yunxin.nertc.module.base.ModuleService

interface UserCenterService : ModuleService {
    /**
     * 注册或反注册用户登录状态监听
     *
     * @param notify     监听回调
     * @param registered true 注册，false 反注册
     */
    fun registerLoginObserver(notify: UserCenterServiceNotify, registered: Boolean)

    /**
     * 对应用户是否为当前用户
     *
     * @param imAccId 用户im id
     * @return true 当前用户
     */
    fun isCurrentUser(imAccId: Long): Boolean

    /**
     * 获取当前用户
     */
    val currentUser: UserModel

    /**
     * 更新用户信息
     */
    fun updateUserInfo(model: UserModel, notify: UserCenterServiceNotify)

    /**
     * 呼出登录页面
     *
     * @param context 上下文
     */
    fun launchLogin(context: Context)

    /**
     * 通过缓存尝试登录
     */
    fun tryLogin(notify: UserCenterServiceNotify)

    /**
     * 呼出用户登出页面
     */
    fun launchLogout(activity: Activity, type: Int, notify: UserCenterServiceNotify)

    /**
     * 当前用户是否登录
     */
    val isLogin: Boolean

    /**
     * 直接调用接口登出
     */
    fun logout(notify: UserCenterServiceNotify)

    companion object {
        /**
         * 正常登出
         */
        const val LOGOUT_DIALOG_TYPE_NORMAL = 1

        /**
         * 登出，提示重新登录
         */
        const val LOGOUT_DIALOG_TYPE_LOGIN_AGAIN = 2
    }
}