/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_network_kt.network

import android.content.Context
import com.netease.yunxin.kit.alog.ALog
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.converter.scalars.ScalarsConverterFactory
import java.util.concurrent.TimeUnit

object ServiceCreator {

    private lateinit var baseUrl: String

    private lateinit var appKey: String

    private var token: String? = null

    private lateinit var retrofit: Retrofit

    var lang = "zh"

    fun init(context: Context, url: String, appKey: String) {
        baseUrl = url
        ServiceCreator.appKey = appKey
        val logging = HttpLoggingInterceptor(object :
            HttpLoggingInterceptor.Logger {
            override fun log(message: String) {
                ALog.d("NetworkClient", message)
            }
        })
        logging.level = HttpLoggingInterceptor.Level.BODY
        val httpClient = OkHttpClient.Builder()
            .connectTimeout(30L, TimeUnit.SECONDS)
            .readTimeout(5L, TimeUnit.SECONDS)
            .writeTimeout(5L, TimeUnit.SECONDS)
            .addInterceptor(logging)
            .addInterceptor(HeaderInterceptor())
        val builder = Retrofit.Builder().baseUrl(baseUrl)
            .client(httpClient.build())
            .addConverterFactory(ScalarsConverterFactory.create())
            .addConverterFactory(GsonConverterFactory.create())
        retrofit = builder.build()
        val language = context.resources.configuration.locale.language
        if (!language.contains("zh")) {
            lang = "en"
        }
    }

    fun <T> create(serviceClass: Class<T>): T = retrofit.create(serviceClass)

    fun getAppKey(): String {
        return appKey
    }

    fun setToken(accessToken: String?) {
        token = accessToken
    }

    fun getToken(): String? {
        return token
    }
}