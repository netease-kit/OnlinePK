/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_network_kt.network

import retrofit2.HttpException

/**
 * 请求
 */
object Request {
    suspend fun <T> request(
        block: suspend () -> Response<T>?,
        success: (T?) -> Unit,
        error: (code: Int, msg: String) -> Unit
    ) {
        try {
            val response = block()
            when {
                response == null -> {
                    error(ErrorCode.ERROR_CODE_EMPTY, "request error!")
                }
                response.isSuccess() -> {
                    success(response.data)
                }
                else -> {
                    error(response.code, response.msg)
                }
            }
        } catch (e: Throwable) {
            // 这里处理网络错误
            if (e is HttpException) {
                error(e.code(), "network exception e = ${e.message()}")
            } else {
                // 各种其他网络错误...
                error(ErrorCode.DEFAULT, "other exception e = ${e.message}")
            }

        }
    }
}