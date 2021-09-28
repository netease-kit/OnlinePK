/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user.network

import com.netease.yunxin.android.lib.network.common.BaseResponse
import com.netease.yunxin.nertc.demo.user.UserModel
import io.reactivex.Single
import retrofit2.http.Body
import retrofit2.http.POST

/**
 * Created by luc on 2020/11/7.
 */
internal interface UserServerApi {
    /**
     * 发送登录验证码
     */
    @POST("/auth/sendLoginSmsCode")
    fun sendLoginSmsCode(@Body body: Map<String, @JvmSuppressWildcards Any?>?): Single<BaseResponse<Void?>?>

    /**
     * 通过验证码登录
     */
    @POST("/auth/loginBySmsCode")
    fun loginWithSmsCode(@Body body: Map<String, @JvmSuppressWildcards Any>?): Single<BaseResponse<UserModel?>?>

    /**
     * 通过token 登录
     */
    @POST("/auth/loginByToken")
    fun loginWithToken(): Single<BaseResponse<UserModel?>?>?

    /**
     * 登出
     */
    @POST("/auth/logout")
    fun logout(): Single<BaseResponse<Void?>?>

    /**
     * 更新用户昵称
     */
    @POST("/auth/updateNickname")
    fun updateNickname(@Body body: Map<String, @JvmSuppressWildcards Any>?): Single<BaseResponse<UserModel?>?>
}