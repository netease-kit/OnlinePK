/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.*
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.nertc.demo.R
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig
import com.netease.yunxin.nertc.demo.user.UserCenterService
import com.netease.yunxin.nertc.demo.user.UserInfoActivity
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr

class UserInfoActivity : BaseActivity() {
    private val service: UserCenterService = ModuleServiceMgr.instance.getService(
        UserCenterService::class.java
    )
    private val notify: UserCenterServiceNotify = object : CommonUserNotify() {
        override fun onUserInfoUpdate(model: UserModel?) {
            currentUser = model
            initUser()
        }
    }
    private var currentUser: UserModel? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        service.registerLoginObserver(notify, true)
        setContentView(R.layout.activity_user_info)
        currentUser = service.currentUser
        initViews()
        paddingStatusBarHeight(findViewById(R.id.cl_root))
    }

    override fun onDestroy() {
        super.onDestroy()
        service.registerLoginObserver(notify, false)
    }

    private fun initViews() {
        val logout = findViewById<View>(R.id.tv_logout)
        logout.setOnClickListener { v: View? ->
            service.launchLogout(this,
                UserCenterService.LOGOUT_DIALOG_TYPE_NORMAL, object : CommonUserNotify() {
                    override fun onUserLogout(success: Boolean, code: Int) {
                        if (success) {
                            finish()
                        }
                    }
                })
        }
        val close = findViewById<View>(R.id.iv_close)
        close.setOnClickListener { v: View? -> finish() }
        initUser()
    }

    private fun initUser() {
        val ivUserPortrait = findViewById<ImageView>(R.id.iv_user_portrait)
        ImageLoader.with(applicationContext).circleLoad(currentUser!!.avatar, ivUserPortrait)
        val tvNickname = findViewById<TextView>(R.id.tv_nick_name)
        tvNickname.setOnClickListener { v: View? ->
            startActivity(
                Intent(
                    this@UserInfoActivity,
                    EditUserInfoActivity::class.java
                )
            )
        }
        tvNickname.text = currentUser!!.nickname
    }

    override fun provideStatusBarConfig(): StatusBarConfig? {
        return StatusBarConfig.Builder()
            .statusBarDarkFont(false)
            .build()
    }
}