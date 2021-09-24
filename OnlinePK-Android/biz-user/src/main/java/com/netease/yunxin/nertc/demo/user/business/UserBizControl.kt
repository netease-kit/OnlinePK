/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user.business

import android.text.TextUtils
import com.blankj.utilcode.util.ToastUtils
import com.blankj.utilcode.util.Utils
import com.google.gson.reflect.TypeToken
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.RequestCallback
import com.netease.nimlib.sdk.auth.AuthService
import com.netease.nimlib.sdk.auth.LoginInfo
import com.netease.yunxin.android.lib.network.common.NetworkClient
import com.netease.yunxin.nertc.demo.user.UserCenterServiceNotify
import com.netease.yunxin.nertc.demo.user.UserModel
import com.netease.yunxin.nertc.demo.user.network.UserServerImpl
import com.netease.yunxin.nertc.demo.user.util.FileCache
import io.reactivex.Single
import io.reactivex.SingleEmitter
import io.reactivex.subjects.PublishSubject
import java.util.*

/**
 * Created by luc on 2020/11/8.
 */
object UserBizControl {
    private const val USER_CACHE_NAME = "user-cache"
    private val observerCache: MutableList<UserCenterServiceNotify> = ArrayList()
    private val USER_STATE_OBSERVER: UserCenterServiceNotify = object : UserCenterServiceNotify {
        override fun onUserLogin(success: Boolean, code: Int) {
            notifyAllRegisteredInfo(object : NotifyHelper {
                override fun onNotifyAction(notify: UserCenterServiceNotify?) {
                    notify?.onUserLogin(
                        success,
                        code
                    )
                }

            })
        }

        override fun onUserLogout(success: Boolean, code: Int) {
            notifyAllRegisteredInfo(object : NotifyHelper {
                override fun onNotifyAction(notify: UserCenterServiceNotify?) {
                    notify?.onUserLogout(
                        success,
                        code
                    )
                }

            })
        }

        override fun onError(exception: Throwable?) {

            notifyAllRegisteredInfo(object : NotifyHelper {
                override fun onNotifyAction(notify: UserCenterServiceNotify?) {
                    notify?.onError(
                        exception
                    )
                }

            })
        }

        override fun onUserInfoUpdate(model: UserModel?) {

            notifyAllRegisteredInfo(object : NotifyHelper {
                override fun onNotifyAction(notify: UserCenterServiceNotify?) {
                    notify?.onUserInfoUpdate(
                        model
                    )
                }

            })
        }
    }

    /**
     * 当前用户
     */
    private var currentUser: UserModel? = null

    /**
     * 注册/反注册登录状态监听
     *
     * @param notify   状态监听
     * @param register true 注册，false 反注册
     */
    @JvmStatic
    fun registerUserStatus(notify: UserCenterServiceNotify, register: Boolean) {
        if (register) {
            observerCache.add(notify)
        } else {
            observerCache.remove(notify)
        }
    }

    /**
     * 尝试使用用户本地缓存数据完成登录
     */
    @JvmStatic
    fun tryLogin(): Single<Boolean> {
        // 检查本地缓存是否存在，不存在直接返回 false，否则返回登录后的结果；
        val userModel = FileCache.getCacheValue(Utils.getApp(), USER_CACHE_NAME,
            object : TypeToken<UserModel?>() {})
        // 检查本地缓存是否有效
        if (userModel == null || TextUtils.isEmpty(userModel.imToken) || userModel.imAccid == 0L) {
            return Single.just(false)
        }
        // 构建 im 登录参数
        val loginInfo = LoginInfo(userModel.imAccid.toString(), userModel.imToken)
        return loginIM(loginInfo).doOnSuccess {
            currentUser = userModel
            NetworkClient.getInstance().configAccessToken(userModel.accessToken)
        }.retry(1)
    }

    /**
     * 用户登录
     *
     * @param phoneNumber 手机号
     * @param verifyCode  验证码
     */
    @JvmStatic
    fun login(phoneNumber: String, verifyCode: String): Single<Boolean> {
        return UserServerImpl.loginWithVerifyCode(phoneNumber, verifyCode)
            .doOnSuccess { model: UserModel? -> currentUser = model }
            .map { userModel: UserModel ->
                LoginInfo(
                    userModel.imAccid.toString(),
                    userModel.imToken
                )
            } // 缓存至本地
            .doOnSuccess {
                FileCache.cacheValue(Utils.getApp(), USER_CACHE_NAME, currentUser,
                    object : TypeToken<UserModel?>() {})
                NetworkClient.getInstance().configAccessToken(
                    currentUser!!.accessToken
                )
            }
            .flatMap { obj: LoginInfo -> loginIM(obj) }
            .doOnSuccess { aBoolean: Boolean ->
                // 登录im 失败认为登录失败，清空当前用户信息
                if (!aBoolean) {
                    currentUser = null
                }
            }
    }

    /**
     * 登录 IM 信息
     */
    private fun loginIM(loginInfo: LoginInfo): Single<Boolean> {
        val subject = PublishSubject.create<Boolean>()
        NIMClient.getService(AuthService::class.java)
            .login(loginInfo)
            .setCallback(object : RequestCallback<LoginInfo> {
                override fun onSuccess(param: LoginInfo) {
                    subject.onNext(true)
                    subject.onComplete()
                }

                override fun onFailed(code: Int) {
                    FileCache.removeCache(Utils.getApp(), USER_CACHE_NAME)
                    currentUser = null
                    ToastUtils.showShort("登录IM 失败，错误码 $code")
                    subject.onNext(false)
                    subject.onComplete()
                }

                override fun onException(exception: Throwable) {
                    subject.onError(exception)
                }
            })
        return subject.serialize()
            .singleOrError()
            .doOnSuccess { aBoolean: Boolean -> USER_STATE_OBSERVER.onUserLogin(aBoolean, 0) }
            .doOnError { exception: Throwable -> USER_STATE_OBSERVER.onError(exception) }
    }

    /**
     * 退出登录
     */
    @JvmStatic
    fun logout(): Single<Boolean> {
        return Single.create { emitter: SingleEmitter<Boolean> ->
            try {
                val result = FileCache.removeCache(Utils.getApp(), USER_CACHE_NAME)
                currentUser = null
                emitter.onSuccess(result)
            } catch (e: Exception) {
                emitter.onError(e)
            }
        }.doOnSuccess { aBoolean: Boolean ->
            NIMClient.getService(AuthService::class.java).logout()
            USER_STATE_OBSERVER.onUserLogout(aBoolean, 0)
        }.doOnError { exception: Throwable? -> USER_STATE_OBSERVER.onError(exception) }
    }

    /**
     * 更新用户信息
     *
     * @param model 用户信息
     */
    @JvmStatic
    fun updateUserInfo(model: UserModel?): Single<UserModel> {
        return if (model == null) {
            Single.error(Throwable("UserModel is null"))
        } else UserServerImpl.updateNickname(model.nickname!!)
            .doOnSuccess { userModel: UserModel ->
                val backup = userModel.backup()
                currentUser = backup
                FileCache.cacheValue(Utils.getApp(), USER_CACHE_NAME, backup,
                    object : TypeToken<UserModel?>() {})
                USER_STATE_OBSERVER.onUserInfoUpdate(backup)
            }
            .doOnError { exception: Throwable? -> USER_STATE_OBSERVER.onError(exception) }
    }

    @JvmStatic
    val userInfo: UserModel?
        get() = if (currentUser != null) currentUser!!.backup() else null

    /**
     * 通知所有已注册回调
     */
    private fun notifyAllRegisteredInfo(helper: NotifyHelper) {
        for (notify in observerCache) {
            helper.onNotifyAction(notify)
        }
    }

    /**
     * 通知帮助接口
     */
    private interface NotifyHelper {
        fun onNotifyAction(notify: UserCenterServiceNotify?)
    }
}