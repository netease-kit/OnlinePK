/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.module.base

import android.content.Context

interface ModuleService {
    /**
     * 初始化调用
     *
     * @param context application 上下文
     */
    fun onInit(context: Context)
}