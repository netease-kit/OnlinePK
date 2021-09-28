/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user.network

import com.netease.yunxin.android.lib.network.common.BaseResponse
import com.netease.yunxin.android.lib.network.common.NetworkClient
import com.netease.yunxin.android.lib.network.common.NetworkConstant
import com.netease.yunxin.nertc.demo.user.UserModel
import io.reactivex.Single
import io.reactivex.SingleTransformer
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import java.util.*

/**
 * Created by luc on 2020/11/7.
 */
object UserServerImpl {
    /**
     * 发送短信验证码
     *
     * @param phoneNumber 手机号码
     * @return true 成功，false 失败
     */
    fun sendVerifyCode(phoneNumber: String?): Single<Boolean?> {
        val api = NetworkClient.getInstance().getService(
            UserServerApi::class.java
        )
        val map: MutableMap<String, Any?> = HashMap(1)
        map["mobile"] = phoneNumber
        return api.sendLoginSmsCode(map).compose(scheduleThread())
            .map { obj: BaseResponse<Void?>? -> obj!!.isSuccessful }
    }

    /**
     * 通过手机号+短信验证登录获取用户信息
     *
     * @param phoneNumber 手机号
     * @param code        短信验证码
     * @return 用户信息
     */
    fun loginWithVerifyCode(phoneNumber: String, code: String): Single<UserModel?> {
        val api = NetworkClient.getInstance().getService(
            UserServerApi::class.java
        )
        val map: MutableMap<String, Any> = HashMap(2)
        map["mobile"] = phoneNumber
        map["smsCode"] = code
        return api.loginWithSmsCode(map)
            .compose(scheduleThread())
            .doOnSuccess { userModelBaseResponse: BaseResponse<UserModel?>? ->
                if (!userModelBaseResponse!!.isSuccessful) {
                    throw Exception("loginWithSmsCode error and code is " + userModelBaseResponse.code)
                }
            }
            .map { userModelBaseResponse: BaseResponse<UserModel?>? -> userModelBaseResponse!!.data }
    }

    /**
     * 登出用户账号
     */
    @Deprecated("") // 目前接口已经废弃，由于调用此接口会导致token失效
    fun logout(): Single<Boolean> {
        val api = NetworkClient.getInstance().getService(
            UserServerApi::class.java
        )
        return api
            .logout()
            .compose(scheduleThread())
            .map { response: BaseResponse<Void?>? -> response!!.isSuccessful || response.code == NetworkConstant.ERROR_RESPONSE_CODE_TOKEN_FAIL }
    }

    /**
     * 更新用户昵称
     */
    fun updateNickname(nickname: String): Single<UserModel> {
        val api = NetworkClient.getInstance().getService(
            UserServerApi::class.java
        )
        val map: MutableMap<String, Any> = HashMap(1)
        map["nickname"] = nickname
        return api.updateNickname(map).compose(scheduleThread())
            .map { userModelBaseResponse: BaseResponse<UserModel?>? -> userModelBaseResponse!!.data }
    }

    /***
     * 切换网络访问线程
     */
    private fun <T> scheduleThread(): SingleTransformer<T, T> {
        return SingleTransformer { upstream: Single<T> ->
            upstream.subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread())
        }
    }
}