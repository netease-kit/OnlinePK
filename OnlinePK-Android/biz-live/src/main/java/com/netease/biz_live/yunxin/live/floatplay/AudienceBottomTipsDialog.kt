package com.netease.biz_live.yunxin.live.floatplay

import android.os.Bundle
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.DialogFragment
import com.blankj.utilcode.util.SizeUtils
import com.netease.biz_live.R

/**
 * 观众端点击x弹出此弹窗
 */
class AudienceBottomTipsDialog : DialogFragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val rootView = inflater.inflate(R.layout.video_float_play_layout, container, false)
        initView(rootView)
        return rootView
    }

    override fun onStart() {
        super.onStart()
        initParams()
    }

    fun initView(rootView: View) {
        rootView.findViewById<View>(R.id.fl_mini).setOnClickListener {
            if (clickCallback != null) {
                clickCallback!!.minimize()
            }
        }
        rootView.findViewById<View>(R.id.fl_exit).setOnClickListener {
            if (clickCallback != null) {
                clickCallback!!.exit()
            }
        }
    }

    private fun initParams() {
        val window = dialog!!.window
        if (window != null) {
            window.setBackgroundDrawableResource(R.drawable.biz_live_bottom_dialog_bg)
            val params = window.attributes
            params.gravity = Gravity.BOTTOM
            // 使用ViewGroup.LayoutParams，以便Dialog 宽度充满整个屏幕
            params.width = ViewGroup.LayoutParams.MATCH_PARENT
            params.height = SizeUtils.dp2px(164f)
            params.dimAmount=0f
            window.attributes = params
        }
        isCancelable = true //设置点击外部是否消失
    }

    fun setClickCallback(clickCallback: OnClickCallback?) {
        this.clickCallback = clickCallback
    }

    private var clickCallback: OnClickCallback? = null

    interface OnClickCallback {
        fun minimize()
        fun exit()
    }
}