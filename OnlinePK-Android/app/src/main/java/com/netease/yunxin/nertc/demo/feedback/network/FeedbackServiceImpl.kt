/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.feedback.network

import com.netease.yunxin.android.lib.network.common.BaseResponse
import com.netease.yunxin.android.lib.network.common.NetworkClient
import com.netease.yunxin.login.sdk.model.UserInfo
import com.netease.yunxin.nertc.demo.basic.BuildConfig
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import java.util.*

/**
 * Created by luc on 2020/11/16.
 */
object FeedbackServiceImpl {
    /**
     * 用户中心意见反馈
     *
     * @param model       用户信息
     * @param demoName    demo 名称
     * @param content     反馈内容
     * @param contentType 反馈类型数组
     */
    fun demoSuggest(
        model: UserInfo,
        demoName: String?,
        content: String?,
        vararg contentType: Int
    ): Single<Boolean?> {
        val api = NetworkClient.getInstance().getService(
            FeedbackServiceApi::class.java
        )
        val map: MutableMap<String, Any?> = HashMap()
        map["tel"] = model.getUserContact()
        map["uid"] = model.accountId
        map["contact"] = model.getUserContact()
        map["content_type"] = contentType
        map["feedback_source"] = demoName
        map["content"] = content
        map["type"] = 1
        map["appkey"] = BuildConfig.APP_KEY
        return api.demoSuggest(map).map { obj: BaseResponse<Void?>? -> obj!!.isSuccessful }
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
    }
}