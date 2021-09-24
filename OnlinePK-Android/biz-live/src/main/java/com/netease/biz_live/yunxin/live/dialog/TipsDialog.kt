/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.dialog

import android.app.Activity
import android.util.TypedValue
import android.view.View
import android.widget.RelativeLayout
import android.widget.TextView
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.utils.SpUtils

/**
 * @author sunkeding
 * 无标题的提示弹窗
 */
class TipsDialog(activity: Activity) : ChoiceDialog(activity) {
    override fun renderRootView(rootView: View?) {
        super.renderRootView(rootView)
        rootView?.findViewById<View?>(R.id.line_divide)?.visibility = View.GONE
        rootView?.findViewById<View?>(R.id.tv_dialog_negative)?.visibility =
            View.GONE
        val tvTitle = rootView?.findViewById<TextView?>(R.id.tv_dialog_title)
        tvTitle?.visibility = View.GONE
        val tvContent = rootView?.findViewById<TextView?>(R.id.tv_dialog_content)
        val params = tvContent?.layoutParams as RelativeLayout.LayoutParams
        params.topMargin = SpUtils.dp2pix(context, 24f)
        tvContent.layoutParams = params
        tvContent.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 15f)
        val line_bottom = rootView.findViewById<View?>(R.id.line_bottom)
        val layoutParams = line_bottom.layoutParams as RelativeLayout.LayoutParams
        layoutParams.topMargin = SpUtils.dp2pix(context, 24f)
        line_bottom.layoutParams = layoutParams
    }

    init {
        setCancelable(false)
    }
}