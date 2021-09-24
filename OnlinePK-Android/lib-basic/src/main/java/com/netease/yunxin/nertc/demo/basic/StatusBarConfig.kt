/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.basic

import android.R
import android.app.Activity
import android.view.View
import androidx.annotation.ColorRes
import com.gyf.immersionbar.ImmersionBar

/**
 * Created by luc on 2020/11/12.
 */
class StatusBarConfig(
    val fits: Boolean,
    val darkFont: Boolean,
    val fullScreen: Boolean,
    val barColor: Int
) {
    class Builder {
        private var fits = false
        private var darkFont = false
        private var fullScreen = false
        private var barColor = R.color.transparent
        fun fitsSystemWindow(fits: Boolean): Builder {
            this.fits = fits
            return this
        }

        fun statusBarDarkFont(dark: Boolean): Builder {
            darkFont = dark
            return this
        }

        fun statusBarColor(@ColorRes color: Int): Builder {
            barColor = color
            return this
        }

        fun fullScreen(full: Boolean): Builder {
            fullScreen = full
            return this
        }

        fun build(): StatusBarConfig {
            return StatusBarConfig(fits, darkFont, fullScreen, barColor)
        }
    }

    companion object {
        fun paddingStatusBarHeight(activity: Activity?, view: View?) {
            if (view == null) {
                return
            }
            val barHeight = getStatusBarHeight(activity)
            view.setPadding(
                view.paddingLeft, view.paddingTop + barHeight,
                view.paddingRight, view.paddingBottom
            )
        }

        fun getStatusBarHeight(activity: Activity?): Int {
            return ImmersionBar.getStatusBarHeight(activity!!)
        }
    }
}