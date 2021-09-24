/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_network_kt

interface NetRequestCallback<T> {

    fun success(info: T? = null)

    fun error(code: Int = -1, msg: String)
}