/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_network_kt.network

/**
 * 错误码
 */
object ErrorCode {
    /**
     * 未知错误码
     */
    const val DEFAULT = -1

    /**
     * 返回data为空
     */
    const val ERROR_CODE_EMPTY = 1001
}

object ErrorMsg {
    /**
     * 服务端未知错误
     */
    const val SERVER_UNKNOWN_ERROR = "server unknown error"
}