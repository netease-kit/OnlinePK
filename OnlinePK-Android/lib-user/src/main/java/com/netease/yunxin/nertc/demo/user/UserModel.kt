/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user

import android.text.TextUtils
import com.google.gson.annotations.SerializedName
import java.io.Serializable

/**
 * 业务用户数据
 */
class UserModel : Serializable {
    @SerializedName("mobile")
    var mobile //String  登录的手机号
            : String? = null

    @SerializedName("accessToken")
    var accessToken //String  登录令牌，重新生成的新令牌，过期时间重新计算
            : String? = null

    @SerializedName("imAccid")
    var imAccid //long  IM账号
            : Long = 0

    @SerializedName("imToken")
    var imToken //String  IM令牌，重新生成的新令牌
            : String? = null

    @SerializedName("avatar")
    var avatar //String  头像地址
            : String? = null

    @SerializedName("nickname")
    var nickname //昵称
            : String? = null

    @SerializedName("accountId")
    var accountId // 账号id
            : String? = null

    @SerializedName("avRoomUid")
    var avRoomUid // 音视频房间内成员编号
            : String? = null

    /**
     * 是否为相同的 IM 用户
     *
     * @param imAccid IM 用户id
     * @return true 相同IM用户，false 不同的IM用户
     */
    fun isSameIMUser(imAccid: Long): Boolean {
        return this.imAccid == imAccid
    }

    override fun equals(o: Any?): Boolean {
        if (this === o) return true
        if (o == null || javaClass != o.javaClass) return false
        val userModel = o as UserModel
        return TextUtils.equals(mobile, userModel.mobile)
    }

    /**
     * 获取昵称，没有昵称默认为 手机号
     */
    @JvmName("getNickname1")
    fun getNickname(): String? {
        return if (TextUtils.isEmpty(nickname)) mobile else nickname
    }

    /**
     * 信息备份
     */
    fun backup(): UserModel {
        val model = UserModel()
        model.accessToken = accessToken
        model.accountId = accountId
        model.avatar = avatar
        model.avRoomUid = avRoomUid
        model.imAccid = imAccid
        model.imToken = imToken
        model.mobile = mobile
        model.nickname = nickname
        return model
    }
}