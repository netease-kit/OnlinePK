/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_network_kt.network

/**
 * 返回封装
 */
class Response<T> {
    var code: Int = 0
    var data: T? = null
    var msg: String = ""
    var requestId: String = ""

    open fun isSuccess(): Boolean {
        return code == 200
    }
}