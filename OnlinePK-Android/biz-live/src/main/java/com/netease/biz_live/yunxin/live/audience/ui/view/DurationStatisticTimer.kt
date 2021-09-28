/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.view

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatTextView
import com.blankj.utilcode.util.SPUtils
import com.netease.biz_live.R
import com.netease.yunxin.kit.alog.ALog
import java.util.*

/**
 * @author sunkeding
 * 时长统计
 */
class DurationStatisticTimer : AppCompatTextView {
    private var timerTask: TimerTask? = null
    private var timer: Timer? = null
    private var costSeconds = 0L
    private val uiHandler: Handler? = Handler(Looper.getMainLooper())
    private val stringBuilder: StringBuilder? = StringBuilder()

    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    )

    fun start() {
        costSeconds =
            Math.round((System.currentTimeMillis() - DurationUtil.getBeginTimeStamp()) / 1000.0)
        if (timerTask == null) {
            timerTask = object : TimerTask() {
                override fun run() {
                    try {
                        ALog.d(TAG, "sceond:$costSeconds")
                        uiHandler?.post(Runnable {
                            text = String.format(
                                Locale.US, context.getString(
                                    R.string.biz_live_link_seat_duration
                                ), getTime(costSeconds)
                            )
                        })
                        costSeconds++
                    } catch (e: NumberFormatException) {
                        e.printStackTrace()
                    }
                }
            }
        }
        if (timer == null) {
            timer = Timer()
        }
        timer!!.schedule(timerTask, DELAY.toLong(), PERIOD.toLong())
    }

    fun stop() {
        if (timerTask != null) {
            timerTask?.cancel()
            timerTask = null
        }
        if (timer != null) {
            timer?.cancel()
            timer?.purge()
            timer = null
        }
    }

    fun getTime(time: Long): String {
        stringBuilder?.setLength(0)
        if (time / 3600 > 0) {
            stringBuilder?.append(time / 3600)?.append("小时")
        }
        if (time % 3600 / 60 > 0) {
            stringBuilder?.append(time % 3600 / 60)?.append("分")
        }
        if (time % 3600 % 60 > 0) {
            stringBuilder?.append(time % 3600 % 60)?.append("秒")
        }
        return stringBuilder.toString()
    }

    object DurationUtil {
        private val SP_KEY: String = "begin_timestamp"

        /**
         * 设置连麦开始时间
         */
        fun setBeginTimeStamp(beginTimeStamp: Long) {
            SPUtils.getInstance().put(SP_KEY, beginTimeStamp)
        }

        fun getBeginTimeStamp(): Long {
            return SPUtils.getInstance().getLong(SP_KEY, 0L)
        }

        @JvmStatic
        fun reset() {
            setBeginTimeStamp(0L)
        }
    }

    companion object {
        private val TAG: String = "DurationStatisticTimer"
        private const val PERIOD = 1000
        private const val DELAY = 0
    }
}