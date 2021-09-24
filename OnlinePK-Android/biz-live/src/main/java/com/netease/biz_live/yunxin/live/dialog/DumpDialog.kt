/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.dialog

import android.view.View
import android.widget.Button
import androidx.fragment.app.FragmentManager
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.R
import com.netease.lava.nertc.sdk.NERtcEx

/**
 * dump dialog
 */
class DumpDialog : BaseBottomDialog() {
    var btnStart: Button? = null
    var btnStop: Button? = null
    override fun getResourceLayout(): Int {
        return R.layout.test_dump_layout
    }

    override fun initView(rootView: View) {
        super.initView(rootView)
        btnStart = rootView.findViewById(R.id.btn_start_dump)
        btnStop = rootView.findViewById(R.id.btn_stop_dump)
    }

    override fun initData() {
        super.initData()
        btnStart?.setOnClickListener(View.OnClickListener { v: View? ->
            btnStart?.isEnabled = false
            ToastUtils.showLong(R.string.biz_live_start_audio_dump)
            NERtcEx.getInstance().startAudioDump()
        })
        btnStop?.setOnClickListener(View.OnClickListener { v: View? ->
            btnStart?.isEnabled = true
            ToastUtils.showLong(R.string.biz_live_dump_end)
            NERtcEx.getInstance().stopAudioDump()
        })
    }

    companion object {
        fun showDialog(fragmentManager: FragmentManager) {
            val dumpDialog = DumpDialog()
            dumpDialog.show(fragmentManager, "dumpDialog")
        }
    }
}