/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.feedback

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.netease.yunxin.nertc.demo.R
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig
import java.util.*

/**
 * demo 名称选择 页面
 */
class DemoNameActivity : BaseActivity() {
    private var adapter: DemoNameAdapter? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_demo_name)
        paddingStatusBarHeight(findViewById(R.id.cl_root))
        initViews()
    }

    private fun initViews() {
        val close = findViewById<View>(R.id.iv_close)
        close.setOnClickListener { v: View? -> finish() }
        val demoNameList = findViewById<RecyclerView>(R.id.rv_demo_name_list)
        demoNameList.layoutManager = LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false)
        val demoName = intent.getStringExtra(KEY_PARAM_DEMO_NAME)
        adapter = DemoNameAdapter(
            this, demoName, Arrays.asList(
                getString(R.string.app_onetoonevoiceroom),
                getString(R.string.app_multiple_video_call)
            )
        )
        demoNameList.adapter = adapter
    }

    override fun provideStatusBarConfig(): StatusBarConfig? {
        return StatusBarConfig.Builder()
            .statusBarDarkFont(false)
            .build()
    }

    override fun finish() {
        val intent = Intent()
        intent.putExtra(KEY_PARAM_DEMO_NAME, adapter!!.focusedItem)
        setResult(RESULT_OK, intent)
        super.finish()
    }

    companion object {
        const val KEY_PARAM_DEMO_NAME = "key_param_demo_name"
        fun launchForResult(activity: Activity, requestCode: Int, demoName: String?) {
            val intent = Intent(activity, DemoNameActivity::class.java)
            intent.putExtra(KEY_PARAM_DEMO_NAME, demoName)
            activity.startActivityForResult(intent, requestCode)
        }
    }
}