/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.view

import android.content.Context
import android.util.AttributeSet
import android.view.*
import androidx.appcompat.widget.AppCompatImageView
import com.netease.biz_live.BuildConfig
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.dialog.DumpDialog
import com.netease.yunxin.nertc.demo.basic.BaseActivity

/**
 * @author sunkeding
 * 多功能按钮，承接观众举手申请上麦及观众推流参数设置两个功能
 */
class MultiFunctionButton : AppCompatImageView {
    private var type = Type.APPLY_SEAT_DISABLE

    interface Type {
        companion object {
            /**
             * 正常状态，点击按钮申请连麦
             */
            const val APPLY_SEAT_ENABLE = 0

            /**
             * 连麦申请中，按钮置灰不可点击
             */
            const val APPLY_SEAT_DISABLE = 1

            /**
             * 连麦中，点击按钮弹出设置弹窗
             */
            const val LINK_SEATS_SETTING = 2
        }
    }

    constructor(context: Context) : super(context) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        init(context)
    }

    private fun init(context: Context?) {
        setOnClickListener { v: View? ->
            if (onButtonClickListener == null || type == Type.APPLY_SEAT_DISABLE) {
                return@setOnClickListener
            }
            if (type == Type.APPLY_SEAT_ENABLE) {
                onButtonClickListener?.applySeat()
            } else if (type == Type.LINK_SEATS_SETTING) {
                onButtonClickListener?.showLinkSeatsStatusDialog()
            }
        }
        // 连麦观众设置按钮新增dump音频功能
        setOnLongClickListener {
            if (BuildConfig.DEBUG && type == Type.LINK_SEATS_SETTING && context is BaseActivity) {
                val activity = context as BaseActivity?
                activity?.supportFragmentManager?.let { it1 -> DumpDialog.showDialog(it1) }
            }
            false
        }
    }

    fun setType(type: Int) {
        this.type = type
        if (type == Type.APPLY_SEAT_ENABLE) {
            setImageResource(R.drawable.biz_live_raise_hand_enable)
        } else if (type == Type.APPLY_SEAT_DISABLE) {
            setImageResource(R.drawable.biz_live_raise_hand_disable)
        } else if (type == Type.LINK_SEATS_SETTING) {
            setImageResource(R.drawable.biz_live_push_setting)
        }
    }

    fun setOnButtonClickListener(onButtonClickListener: OnButtonClickListener?) {
        this.onButtonClickListener = onButtonClickListener
    }

    private var onButtonClickListener: OnButtonClickListener? = null

    interface OnButtonClickListener {
        open fun applySeat()
        open fun showLinkSeatsStatusDialog()
    }
}