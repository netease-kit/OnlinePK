/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.utils

import com.blankj.utilcode.util.Utils
import com.netease.biz_live.R
import java.text.DecimalFormat

/**
 * Created by luc on 2020/12/1.
 */
object StringUtils {
    /**
     * 格式化展示云币数量，超过10000 展示为 xx万
     *
     * @param coinCount 云币总数
     * @return 云币数字符串
     */
    fun getCoinCount(coinCount: Long): String? {
        if (coinCount < 10000) {
            return coinCount.toString() + Utils.getApp().getString(R.string.biz_live_coin)
        }
        val decimalFormat = DecimalFormat("#.##")
        return decimalFormat.format((coinCount / 10000f).toDouble()) + Utils.getApp()
            .getString(R.string.biz_live_ten_thousand) + Utils.getApp().getString(
            R.string.biz_live_coin
        )
    }

    /**
     * 格式化展示观众数，超过 1w 展示 xx万，超过 1亿展示 xx亿
     *
     * @param audienceCount 观众实际数
     * @return 观众数字符串
     */
    fun getAudienceCount(audienceCount: Int): String? {
        if (audienceCount < 1000) {
            return audienceCount.coerceAtLeast(0).toString()
        }
        if (audienceCount < 100000000) {
            val decimalFormat = DecimalFormat("#.##")
            return decimalFormat.format((audienceCount / 10000f).toDouble()) + Utils.getApp()
                .getString(
                    R.string.biz_live_ten_thousand
                )
        }
        val decimalFormat = DecimalFormat("#.##")
        return decimalFormat.format((audienceCount / 100000000f).toDouble()) + Utils.getApp()
            .getString(
                R.string.biz_live_hundred_million
            )
    }
}