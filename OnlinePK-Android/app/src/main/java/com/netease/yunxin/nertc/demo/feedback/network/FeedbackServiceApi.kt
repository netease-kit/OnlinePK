/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.feedback.network

import com.netease.yunxin.android.lib.network.common.BaseResponse
import com.netease.yunxin.android.lib.network.common.BaseUrl
import io.reactivex.Single
import retrofit2.http.Body
import retrofit2.http.POST

/**
 * Created by luc on 2020/11/16.
 */
@BaseUrl("https://statistic.live.126.net/")
interface FeedbackServiceApi {
    /**
     * 反馈上报
     *
     * @param body 反馈参数
     */
    @POST("/statics/report/feedback/demoSuggest")
    fun demoSuggest(@Body body: Map<String, Any?>?): Single<BaseResponse<Void?>?>
}