/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.basic

import android.os.Bundle
import android.view.View
import androidx.annotation.IdRes
import androidx.appcompat.app.AppCompatActivity
import com.gyf.immersionbar.ImmersionBar
import com.netease.yunxin.nertc.demo.user.CommonUserNotify
import com.netease.yunxin.nertc.demo.user.UserCenterService
import com.netease.yunxin.nertc.demo.user.UserCenterServiceNotify
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr

open class BaseActivity : AppCompatActivity() {
    private val userCenterService = ModuleServiceMgr.instance.getService(
        UserCenterService::class.java
    )
    private val loginNotify: UserCenterServiceNotify = object : CommonUserNotify() {
        override fun onUserLogout(success: Boolean, code: Int) {
            if (success && !ignoredLoginEvent()) {
                finish()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        userCenterService.registerLoginObserver(loginNotify, true)
        val config = provideStatusBarConfig()
        if (config != null) {
            val bar = ImmersionBar.with(this)
                .statusBarDarkFont(config.darkFont)
                .statusBarColor(config.barColor)
            if (config.fits) {
                bar.fitsSystemWindows(true)
            }
            if (config.fullScreen) {
                bar.fullScreen(true)
            }
            bar.init()
        }
    }

    override fun onDestroy() {
        userCenterService.registerLoginObserver(loginNotify, false)
        super.onDestroy()
    }

    protected open fun provideStatusBarConfig(): StatusBarConfig? {
        return null
    }

    protected open fun ignoredLoginEvent(): Boolean {
        return false
    }

    protected fun paddingStatusBarHeight(view: View?) {
        StatusBarConfig.paddingStatusBarHeight(this, view)
    }

    protected fun paddingStatusBarHeight(@IdRes rootViewId: Int) {
        paddingStatusBarHeight(findViewById(rootViewId))
    }
}