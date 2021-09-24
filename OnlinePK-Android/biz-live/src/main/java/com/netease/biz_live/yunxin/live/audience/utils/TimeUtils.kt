/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.utils

/**
 * Created by luc on 2020/12/9.
 */
object TimeUtils {
    /**
     * 获取时间剩余总毫秒数
     *
     * @param totalTime        时间总毫秒数
     * @param currentTimestamp 当前时间戳
     * @param startedTimestamp 开始时间戳
     * @param offset           偏移量毫秒数
     * @return 时间剩余毫秒数
     */
    fun getLeftTime(
        totalTime: Long,
        currentTimestamp: Long,
        startedTimestamp: Long,
        offset: Long
    ): Long {
        return totalTime - (currentTimestamp - startedTimestamp) + offset
    }
}