/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.view

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.RelativeLayout
import android.widget.TextView
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.utils.LinkedSeatsAudienceActionManager
import com.netease.biz_live.yunxin.live.constant.ApiErrorCode
import com.netease.yunxin.seatlibrary.CompletionCallback

/**
 * @author sunkeding
 * 等待主播接受连麦申请的横幅
 */
class WaitAnchorAcceptView : RelativeLayout {
    private var cancelApplySeatClickCallback: CancelApplySeatClickCallback? = null

    var tvCancel: TextView? = null

    constructor(context: Context?) : super(context) {
        init(context)
    }

    constructor(context: Context?, attrs: AttributeSet?) : super(context, attrs) {
        init(context)
    }

    constructor(context: Context?, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        init(context)
    }

    private fun init(context: Context?) {
        LayoutInflater.from(context).inflate(R.layout.biz_live_view_wait_anchor_accept, this, true)
        tvCancel = findViewById<TextView?>(R.id.tv_cancel)
        tvCancel?.setOnClickListener { v: View? ->
            tvCancel?.isEnabled = false
            val linkedSeatsAudienceActionManager = LinkedSeatsAudienceActionManager
            linkedSeatsAudienceActionManager.cancelSeatApply(
                object : CompletionCallback<Void> {
                    override fun success(info: Void?) {
                        visibility = GONE
                        cancelApplySeatClickCallback?.cancel()
                        tvCancel?.isEnabled = true
                    }

                    override fun error(code: Int, msg: String) {
                        ToastUtils.showShort(msg)
                        if (ApiErrorCode.DONT_APPLY_SEAT == code) {
                            visibility = GONE
                            cancelApplySeatClickCallback?.cancel()
                        } else {
                            visibility = VISIBLE
                        }
                        tvCancel?.isEnabled = true
                    }
                })
        }
    }


    fun setCancelApplySeatClickCallback(cancelApplySeatClickCallback: CancelApplySeatClickCallback?) {
        this.cancelApplySeatClickCallback = cancelApplySeatClickCallback
    }


    interface CancelApplySeatClickCallback {
        open fun cancel()
    }
}