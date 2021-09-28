/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.gift

import android.animation.Animator
import android.view.View
import androidx.annotation.RawRes
import com.airbnb.lottie.LottieAnimationView
import java.util.*

/**
 * Created by luc on 2020/11/24.
 */
class GiftRender {
    private val giftQueue: Queue<Int?> = LinkedList()
    private var animationView: LottieAnimationView? = null
    private var isAnimating = false
    fun init(animationView: LottieAnimationView) {
        this.animationView = animationView
        this.animationView?.addAnimatorListener(object : Animator.AnimatorListener {
            override fun onAnimationStart(animation: Animator) {}
            override fun onAnimationEnd(animation: Animator) {
                animationView.visibility = View.GONE
                if (!giftQueue.isEmpty()) {
                    playAnim(giftQueue.poll())
                } else {
                    isAnimating = false
                }
            }

            override fun onAnimationCancel(animation: Animator?) {
                isAnimating = !giftQueue.isEmpty()
            }

            override fun onAnimationRepeat(animation: Animator?) {}
        })
    }

    @Synchronized
    fun addGift(@RawRes gitResId: Int) {
        giftQueue.add(gitResId)
        if (!isAnimating) {
            isAnimating = true
            playAnim(giftQueue.poll())
        }
    }

    fun release() {
        giftQueue.clear()
        animationView?.let {
            it.cancelAnimation()
            it.visibility = View.GONE
        }
    }

    private fun playAnim(@RawRes gitResId: Int?) {
        if (gitResId == null) {
            return
        }
        animationView?.visibility = View.VISIBLE
        animationView?.setAnimation(gitResId)
        animationView?.playAnimation()
    }
}