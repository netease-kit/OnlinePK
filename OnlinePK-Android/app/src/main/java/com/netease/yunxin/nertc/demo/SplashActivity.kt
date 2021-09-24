/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo

import android.content.Intent
import android.os.Bundle
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig
import com.netease.yunxin.nertc.demo.user.CommonUserNotify
import com.netease.yunxin.nertc.demo.user.UserCenterService
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr

class SplashActivity : BaseActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (!this.isTaskRoot) {
            val mainIntent = intent
            val action = mainIntent.action
            if (mainIntent.hasCategory(Intent.CATEGORY_LAUNCHER) && Intent.ACTION_MAIN == action) {
                finish()
                return
            }
        }
        setContentView(R.layout.activity_splash)
        val service: UserCenterService = ModuleServiceMgr.instance.getService(
            UserCenterService::class.java
        )
        service.tryLogin(object : CommonUserNotify() {
            override fun onUserLogin(success: Boolean, code: Int) {
                if (success) {
                    navigationMain()
                } else {
                    service.launchLogin(this@SplashActivity)
                }
                finish()
            }

            override fun onError(exception: Throwable?) {
                service.launchLogin(this@SplashActivity)
                finish()
            }
        })
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        ALog.d(TAG, "onNewIntent: intent -> " + intent.data)
        setIntent(intent)
    }

    private fun navigationMain() {
        val intent = Intent(this, MainActivity::class.java)
        startActivity(intent)
        finish()
    }

    override fun provideStatusBarConfig(): StatusBarConfig? {
        return StatusBarConfig.Builder()
            .statusBarDarkFont(true)
            .fullScreen(true)
            .build()
    }

    companion object {
        private const val TAG = "SplashActivity"
    }
}