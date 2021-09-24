/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.gift.ui

import android.content.Context
import android.util.AttributeSet
import com.airbnb.lottie.LottieAnimationView

/**
 * Created by luc on 2020/12/7.
 *
 *
 * 当礼物接收到礼物发送时如果为未展示状态则忽略当前礼物动画，即使当前onDetachWindow 也不会暂停动画，
 * 当直播结束手动调用资源释放
 */
class GifAnimationView : LottieAnimationView {
    constructor(context: Context?) : super(context)
    constructor(context: Context?, attrs: AttributeSet?) : super(context, attrs)
    constructor(context: Context?, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    )

    override fun isShown(): Boolean {
        return true
    }

    override fun isAnimating(): Boolean {
        return false
    }
}