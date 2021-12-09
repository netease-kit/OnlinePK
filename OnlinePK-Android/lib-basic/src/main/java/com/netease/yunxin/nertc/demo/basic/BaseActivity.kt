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
import com.netease.yunxin.login.sdk.AuthorManager
import com.netease.yunxin.login.sdk.model.EventType
import com.netease.yunxin.login.sdk.model.LoginEvent
import com.netease.yunxin.login.sdk.model.LoginObserver

open class BaseActivity : AppCompatActivity() {

    private val loginObserver: LoginObserver<LoginEvent> = object : LoginObserver<LoginEvent> {
        override fun onEvent(event: LoginEvent) {
            if (event.eventType == EventType.TYPE_LOGOUT && !ignoredLoginEvent()){
                finish()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AuthorManager.registerLoginObserver(loginObserver)
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
        AuthorManager.unregisterLoginObserver(loginObserver)
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