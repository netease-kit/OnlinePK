/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_network_kt.network

import android.text.TextUtils
import okhttp3.Interceptor
import okhttp3.Request
import okhttp3.Request.Builder
import okhttp3.Response

class HeaderInterceptor : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val original = chain.request()
        val requestBuilder: Builder = original.newBuilder()

        val appKey: String = ServiceCreator.getAppKey()
        if (!TextUtils.isEmpty(appKey)) {
            requestBuilder.header("appKey", appKey)
        }
        val token = ServiceCreator.getToken()
        if (!TextUtils.isEmpty(token)) {
            requestBuilder.header("accessToken", token!!)
        }

        requestBuilder.header("lang", ServiceCreator.lang)

        requestBuilder.header("Content-Type", " application/json")
        val request: Request = requestBuilder.build()
        return chain.proceed(request)
    }
}