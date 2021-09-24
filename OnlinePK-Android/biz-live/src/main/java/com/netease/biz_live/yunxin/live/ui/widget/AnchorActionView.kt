/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.ui.widget

import android.content.Context
import android.text.TextUtils
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.View.OnClickListener
import android.widget.LinearLayout
import android.widget.TextView
import com.netease.biz_live.R

class AnchorActionView : LinearLayout {
    private var tvComment: TextView? = null
    private var tvBlack: TextView? = null
    private var tvColor: TextView? = null
    private var audienceNick: String? = null
    private var count = 0

    constructor(context: Context?) : super(context) {
        initView()
    }

    constructor(context: Context?, attrs: AttributeSet?) : super(context, attrs) {
        initView()
    }

    constructor(context: Context?, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        initView()
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.view_anchor_aciton, this)
        tvComment = findViewById(R.id.tv_comment)
        tvBlack = findViewById(R.id.tv_black)
        tvColor = findViewById(R.id.tv_color)
    }

    fun setBlackButton(
        show: Boolean,
        text: String?,
        clickListener: OnClickListener?
    ): AnchorActionView {
        tvBlack?.visibility = if (show) VISIBLE else GONE
        tvBlack?.text = if (TextUtils.isEmpty(text)) "" else text
        tvBlack?.setOnClickListener(OnClickListener { v: View? ->
            hide()
            clickListener?.onClick(v)
        })
        return this
    }

    fun setText(text: String?): AnchorActionView? {
        tvComment?.text = text
        return this
    }

    fun setColorButton(text: String?, clickListener: OnClickListener?): AnchorActionView? {
        tvColor?.text = if (TextUtils.isEmpty(text)) "" else text
        tvColor?.setOnClickListener(OnClickListener { v: View? ->
            hide()
            clickListener?.onClick(v)
        })
        return this
    }

    fun isShowing(): Boolean {
        return this.visibility == VISIBLE
    }

    fun show() {
        visibility = VISIBLE
    }

    fun hide() {
        visibility = GONE
        tvColor?.text = ""
        tvComment?.text = ""
        tvBlack?.text = ""
        tvBlack?.visibility = GONE
        audienceNick = ""
        count = 0
    }
}