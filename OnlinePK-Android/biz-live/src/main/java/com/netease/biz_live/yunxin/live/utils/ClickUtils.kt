/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.utils

object ClickUtils {
    private var lastClickTime: Long = 0
    private const val CLICK_TIME = 300 //快速点击间隔时间

    // 判断按钮是否快速点击
    fun isFastClick(): Boolean {
        val time = System.currentTimeMillis()
        if (time - lastClickTime < CLICK_TIME) { //判断系统时间差是否小于点击间隔时间
            return true
        }
        lastClickTime = time
        return false
    }
}