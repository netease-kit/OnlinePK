/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.dialog

import android.app.Activity
import android.app.Dialog
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager.BadTokenException
import android.widget.TextView
import androidx.annotation.LayoutRes
import com.netease.biz_live.R
import com.netease.yunxin.kit.alog.ALog

/**
 * Created by luc on 2020/12/3.
 * 选择dialog
 */
open class ChoiceDialog(activity: Activity) : Dialog(activity, R.style.CommonDialog) {
    protected var activity: Activity?
    protected var rootView: View?
    protected var titleStr: String? = null
    protected var contentStr: String? = null
    protected var positiveStr: String? = null
    protected var negativeStr: String? = null
    protected var positiveListener: View.OnClickListener? = null
    protected var negativeListener: View.OnClickListener? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        rootView?.let { setContentView(it) }
    }

    @LayoutRes
    protected fun contentLayoutId(): Int {
        return R.layout.view_dialog_choice_layout
    }

    /**
     * 页面渲染
     */
    protected open fun renderRootView(rootView: View?) {
        if (rootView == null) {
            return
        }
        val tvTitle = rootView.findViewById<TextView?>(R.id.tv_dialog_title)
        tvTitle.text = titleStr
        val tvContent = rootView.findViewById<TextView?>(R.id.tv_dialog_content)
        tvContent.text = contentStr
        val tvPositive = rootView.findViewById<TextView?>(R.id.tv_dialog_positive)
        tvPositive.text = positiveStr
        tvPositive.setOnClickListener { v: View? ->
            dismiss()
            positiveListener?.onClick(v)
        }
        val tvNegative = rootView.findViewById<TextView?>(R.id.tv_dialog_negative)
        tvNegative.text = negativeStr
        tvNegative.setOnClickListener { v: View? ->
            dismiss()
            negativeListener?.onClick(v)
        }
    }

    fun setTitle(title: String?): ChoiceDialog {
        titleStr = title
        return this
    }

    fun setContent(content: String?): ChoiceDialog {
        contentStr = content
        return this
    }

    fun setPositive(positive: String?, listener: View.OnClickListener?): ChoiceDialog {
        positiveStr = positive
        positiveListener = listener
        return this
    }

    fun setNegative(negative: String?, listener: View.OnClickListener?): ChoiceDialog {
        negativeListener = listener
        negativeStr = negative
        return this
    }

    override fun show() {
        if (isShowing) {
            return
        }
        renderRootView(rootView)
        try {
            super.show()
        } catch (e: BadTokenException) {
            ALog.e("ChoiceDialog", "error message is :" + e.message)
        }
    }

    init {
        this.activity = activity
        rootView = LayoutInflater.from(context).inflate(contentLayoutId(), null)
    }
}