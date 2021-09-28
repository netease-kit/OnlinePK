/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.gift

import android.util.SparseArray
import com.blankj.utilcode.util.Utils
import com.netease.biz_live.R

/**
 * Created by luc on 2020/11/19.
 *
 *
 * 礼物内容存储集合
 */
object GiftCache {
    private val TOTAL_GIFT: SparseArray<GiftInfo> = SparseArray()

    /**
     * 获取礼物详情
     *
     * @param giftId 礼物id
     */
    fun getGift(giftId: Int): GiftInfo {
        return TOTAL_GIFT.get(giftId)
    }

    /**
     * 获取礼物列表
     */
    fun getGiftList(): MutableList<GiftInfo>? {
        return listOf(
            getGift(1),
            getGift(2),
            getGift(3),
            getGift(4)
        ).toMutableList()
    }

    init {
        // 礼物-荧光棒
        TOTAL_GIFT.append(
            1,
            GiftInfo(
                1,
                Utils.getApp().getString(R.string.biz_live_glow_stick),
                9,
                R.drawable.icon_gift_lifght_stick,
                R.raw.anim_gift_light_stick
            )
        )
        // 礼物-安排
        TOTAL_GIFT.append(
            2,
            GiftInfo(
                2,
                Utils.getApp().getString(R.string.biz_live_arrange),
                99,
                R.drawable.icon_gift_plan,
                R.raw.anim_gift_plan
            )
        )
        // 礼物-跑车
        TOTAL_GIFT.append(
            3,
            GiftInfo(
                3,
                Utils.getApp().getString(R.string.biz_live_sports_car),
                199,
                R.drawable.icon_gift_super_car,
                R.raw.anim_gift_super_car
            )
        )
        // 礼物-火箭
        TOTAL_GIFT.append(
            4,
            GiftInfo(
                4,
                Utils.getApp().getString(R.string.biz_live_rockets),
                999,
                R.drawable.icon_gift_rocket,
                R.raw.anim_gift_rocket
            )
        )
    }
}