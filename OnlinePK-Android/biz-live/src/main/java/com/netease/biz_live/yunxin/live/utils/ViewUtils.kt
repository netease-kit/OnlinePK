/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.utils

import android.view.View

/**
 * Created by luc on 2020/11/25.
 */
object ViewUtils {
    /**
     * 判断当前坐标是否在设置的view上
     *
     * @param view 目标 view
     * @param x    横坐标
     * @param y    纵坐标
     * @return true 在view 上，false 反之。
     */
    fun isInView(view: View?, x: Int, y: Int): Boolean {
        if (view == null) {
            return false
        }
        val location = IntArray(2)
        view.getLocationOnScreen(location)
        val left = location[0]
        val top = location[1]
        val right = left + view.measuredWidth
        val bottom = top + view.measuredHeight
        return y >= top && y <= bottom && x >= left && x <= right
    }
}