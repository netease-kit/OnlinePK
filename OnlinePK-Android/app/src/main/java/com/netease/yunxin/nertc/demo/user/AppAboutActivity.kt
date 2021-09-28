/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user

import android.os.Bundle
import android.view.View
import android.widget.TextView
import com.netease.yunxin.nertc.demo.BuildConfig
import com.netease.yunxin.nertc.demo.R
import com.netease.yunxin.nertc.demo.basic.*
import com.netease.yunxin.nertc.demo.user.AppAboutActivity

class AppAboutActivity : BaseActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_app_about)
        paddingStatusBarHeight(findViewById(R.id.cl_root))
        initViews()
    }

    private fun initViews() {
        val close = findViewById<View>(R.id.iv_close)
        close.setOnClickListener { v: View? -> finish() }
        val appVersion = findViewById<TextView>(R.id.tv_app_version)
        appVersion.text = "v" + BuildConfig.VERSION_NAME
        val imVersion = findViewById<TextView>(R.id.tv_im_version)
        imVersion.text = "v" + BuildConfig.VERSION_IM
        val nertcVersion = findViewById<TextView>(R.id.tv_g2_version)
        nertcVersion.text = "v" + BuildConfig.VERSION_NERTC
        val privacy = findViewById<View>(R.id.tv_privacy)
        privacy.setOnClickListener { v: View? ->
            CommonBrowseActivity.launch(
                this@AppAboutActivity, getString(
                    R.string.app_privacy_policy
                ), Constants.URL_PRIVACY
            )
        }
        val userPolice = findViewById<View>(R.id.tv_user_police)
        userPolice.setOnClickListener { v: View? ->
            CommonBrowseActivity.launch(
                this@AppAboutActivity, getString(
                    R.string.app_user_agreement
                ), Constants.URL_USER_POLICE
            )
        }
        val disclaimer = findViewById<View>(R.id.tv_disclaimer)
        disclaimer.setOnClickListener { v: View? ->
            CommonBrowseActivity.launch(
                this@AppAboutActivity, getString(
                    R.string.app_disclaimer
                ), Constants.URL_DISCLAIMER
            )
        }
    }

    override fun provideStatusBarConfig(): StatusBarConfig? {
        return StatusBarConfig.Builder()
            .statusBarDarkFont(false)
            .build()
    }
}