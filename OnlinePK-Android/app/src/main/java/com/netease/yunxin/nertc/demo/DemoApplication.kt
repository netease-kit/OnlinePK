/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo

import android.app.Application
import android.text.TextUtils
import com.netease.biz_live.yunxin.live.LiveApplicationLifecycle
import com.netease.biz_live.yunxin.live.LiveService
import com.netease.biz_live.yunxin.live.LiveServiceImpl
import com.netease.yunxin.android.lib.network.common.NetworkClient
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.alog.BasicInfo
import com.netease.yunxin.lib_network_kt.network.ServiceCreator
import com.netease.yunxin.login.sdk.AuthorManager
import com.netease.yunxin.login.sdk.model.AuthorConfig
import com.netease.yunxin.login.sdk.model.LoginType
import com.netease.yunxin.nertc.module.base.ApplicationLifecycleMgr
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr
import com.netease.yunxin.nertc.module.base.sdk.NESdkBase

class DemoApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        ALog.init(this, ALog.LEVEL_ALL)
        ALog.logFirst(
            BasicInfo.Builder()
                .name(getString(R.string.app_name))
                .version("v" + BuildConfig.VERSION_NAME)
                .gitHashCode(BuildConfig.GIT_COMMIT_HASH)
                .deviceId(this)
                .baseUrl(com.netease.yunxin.nertc.demo.basic.BuildConfig.BASE_URL)
                .packageName(this)
                .nertcVersion(BuildConfig.VERSION_NERTC)
                .imVersion(BuildConfig.VERSION_IM)
                .build()
        )
        // 配置网络基础 url 以及 debug 开关
        NetworkClient.getInstance()
            .configBaseUrl(com.netease.yunxin.nertc.demo.basic.BuildConfig.BASE_URL)
            .appKey(com.netease.yunxin.nertc.demo.basic.BuildConfig.APP_KEY)
            .configDebuggable(true)
        val language = resources.configuration.locale.language
        if (!language.contains("zh")) {
            NetworkClient.getInstance().configLanguage("en")
        }

        //kt网络配置
        ServiceCreator.init(
            applicationContext,
            com.netease.yunxin.nertc.demo.basic.BuildConfig.BASE_URL,
            com.netease.yunxin.nertc.demo.basic.BuildConfig.APP_KEY
        )
        // 初始化相关sdk
        NESdkBase.instance
            .initContext(this) // 初始化 IM sdk
            //此处仅设置 AppKey，其他设置请自行参看信令文档设置 https://dev.yunxin.163.com/docs/product/信令/SDK开发集成/Android开发集成/初始化
            .initIM(com.netease.yunxin.nertc.demo.basic.BuildConfig.APP_KEY, null) //初始化美颜(相芯)
            .initFaceunity()

        // 各个module初始化逻辑
        ApplicationLifecycleMgr.instance
            .registerLifecycle(LiveApplicationLifecycle())
            .notifyOnCreate(this)

        //初始化登录模块
        val authorConfig =
            AuthorConfig(com.netease.yunxin.nertc.demo.basic.BuildConfig.APP_KEY, 1, 3, false)
        authorConfig.loginType = LoginType.LANGUAGE_SWITCH
        AuthorManager.initAuthor(applicationContext, authorConfig)

        // 模块方法实例注册，直播模块
        ModuleServiceMgr.instance
            .registerService(LiveService::class.java, applicationContext, LiveServiceImpl())
    }
}