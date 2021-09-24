/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.dialog

import android.app.Activity
import android.app.Dialog
import android.os.Bundle
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.view.WindowManager.BadTokenException
import android.widget.FrameLayout
import androidx.annotation.LayoutRes
import com.netease.biz_live.R
import com.netease.yunxin.kit.alog.ALog

/**
 * 底部弹窗基类，子类需要实现 顶部view，以及底部view 的渲染即可
 */
abstract class BottomBaseDialog(protected var activity: Activity) : Dialog(activity, R.style.BottomDialogTheme) {
    protected val rootView: View by lazy {
        LayoutInflater.from(context).inflate(contentLayoutId(), null)
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val window = window
        if (window != null) {
            window.decorView.setPadding(0, 0, 0, 0)
            val wlp = window.attributes
            wlp.gravity = Gravity.BOTTOM
            wlp.width = WindowManager.LayoutParams.MATCH_PARENT
            wlp.height = WindowManager.LayoutParams.WRAP_CONTENT
            window.attributes = wlp
        }
        setContentView(rootView)
        setCanceledOnTouchOutside(true)
    }

    @LayoutRes
    protected fun contentLayoutId(): Int {
        return R.layout.view_dialog_utils_base
    }

    /**
     * 页面渲染
     */
    protected fun renderRootView(rootView: View?) {
        if (rootView == null) {
            return
        }
        renderTopView(rootView.findViewById(R.id.fl_dialog_top))
        renderBottomView(rootView.findViewById(R.id.fl_dialog_bottom))
    }

    /**
     * 渲染dialog顶部UI
     *
     * @param parent UI 容器
     */
    protected abstract fun renderTopView(parent: FrameLayout)

    /**
     * 渲染dialog底部UI
     *
     * @param parent UI 容器
     */
    protected abstract fun renderBottomView(parent: FrameLayout)
    override fun show() {
        if (isShowing) {
            return
        }
        renderRootView(rootView)
        try {
            super.show()
        } catch (e: BadTokenException) {
            ALog.e(this.javaClass.simpleName, "error message is :" + e.message)
        }
    }
}