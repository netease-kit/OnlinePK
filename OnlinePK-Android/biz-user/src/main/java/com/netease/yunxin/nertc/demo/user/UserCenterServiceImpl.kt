/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user

import android.app.Activity
import android.content.Context
import com.netease.yunxin.nertc.demo.user.business.UserBizControl
import com.netease.yunxin.nertc.demo.user.business.UserBizControl.registerUserStatus
import com.netease.yunxin.nertc.demo.user.business.UserBizControl.updateUserInfo
import com.netease.yunxin.nertc.demo.user.business.UserBizControl.userInfo
import com.netease.yunxin.nertc.demo.user.ui.LoginActivity
import com.netease.yunxin.nertc.demo.user.ui.LogoutDialog
import io.reactivex.observers.ResourceSingleObserver

class UserCenterServiceImpl : UserCenterService {
    private var dialog: LogoutDialog? = null
    override fun registerLoginObserver(notify: UserCenterServiceNotify, registered: Boolean) {
        registerUserStatus(notify, registered)
    }

    override fun isCurrentUser(imAccId: Long): Boolean {
        return isLogin && currentUser.isSameIMUser(imAccId)
    }

    override val currentUser: UserModel
        get() = if (userInfo == null) UserModel() else userInfo!!

    override fun updateUserInfo(model: UserModel, notify: UserCenterServiceNotify) {
        updateUserInfo(model).subscribe(object : ResourceSingleObserver<UserModel>() {
            override fun onSuccess(model: UserModel) {
                notify.onUserInfoUpdate(model)
            }

            override fun onError(e: Throwable) {
                notify.onError(e)
            }
        })
    }

    override fun launchLogin(context: Context) {
        LoginActivity.startLogin(context)
    }

    override fun tryLogin(notify: UserCenterServiceNotify) {
        UserBizControl.tryLogin().subscribe(object : ResourceSingleObserver<Boolean?>() {
            override fun onSuccess(aBoolean: Boolean) {
                notify.onUserLogin(aBoolean, 0)
            }

            override fun onError(e: Throwable) {
                notify.onError(e)
            }
        })
    }

    override fun launchLogout(activity: Activity, type: Int, notify: UserCenterServiceNotify) {
        if (dialog != null && dialog!!.isShowing && !activity.isFinishing) {
            try {
                dialog!!.dismiss()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        dialog = LogoutDialog(activity, type, notify)
        dialog!!.show()
    }

    override val isLogin: Boolean
        get() = userInfo != null

    override fun logout(notify: UserCenterServiceNotify) {
        UserBizControl.logout().subscribe(object : ResourceSingleObserver<Boolean?>() {
            override fun onSuccess(aBoolean: Boolean) {
                if (notify != null) {
                    notify.onUserLogout(aBoolean, 0)
                }
            }

            override fun onError(e: Throwable) {
                if (notify != null) {
                    notify.onError(e)
                }
            }
        })
    }

    override fun onInit(context: Context) {

    }
}