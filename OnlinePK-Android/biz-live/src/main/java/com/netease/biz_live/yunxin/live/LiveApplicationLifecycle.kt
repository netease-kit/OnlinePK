/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live

import android.app.Application
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.R
import com.netease.neliveplayer.sdk.NELivePlayer
import com.netease.neliveplayer.sdk.NELivePlayer.OnDataUploadListener
import com.netease.neliveplayer.sdk.model.NESDKConfig
import com.netease.yunxin.android.lib.network.common.NetworkClient
import com.netease.yunxin.android.lib.network.common.NetworkConstant
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.nertc.demo.user.CommonUserNotify
import com.netease.yunxin.nertc.demo.user.UserCenterService
import com.netease.yunxin.nertc.module.base.AbsApplicationLifecycle
import com.netease.yunxin.nertc.module.base.ModuleServiceMgr

/**
 * Created by luc on 2020/11/12.
 */
class LiveApplicationLifecycle : AbsApplicationLifecycle(
    LiveApplicationLifecycle::class.java.canonicalName
) {
    /**
     * 用户拉流数据采集
     */
    private val dataUploadListener: OnDataUploadListener? = object : OnDataUploadListener {
        override fun onDataUpload(s: String?, s1: String?): Boolean {
            ALog.e("Player===>", "stream url is $s, detail data is $s1")
            return true
        }

        override fun onDocumentUpload(
            s: String?,
            map: MutableMap<String?, String?>?,
            map1: MutableMap<String?, String?>?
        ): Boolean {
            return true
        }
    }

    override fun onModuleCreate(application: Application) {
        val config = NESDKConfig()
        config.dataUploadListener = dataUploadListener
        NELivePlayer.init(application.applicationContext, config)

        // 统一处理 网络请求 token 失效的情况，登出并退至登录页面
        NetworkClient.getInstance().registerHandler(
            NetworkConstant.ERROR_RESPONSE_CODE_TOKEN_FAIL
        ) { errorCode: Int, msg: String?, data: Any? ->
            ToastUtils.showLong(R.string.biz_live_login_expried_tips)
            val service = ModuleServiceMgr.instance.getService(
                UserCenterService::class.java
            )
            if (service.isLogin) {
                service.logout(object : CommonUserNotify() {
                    override fun onUserLogout(success: Boolean, code: Int) {
                        if (success) {
                            service.launchLogin(application.applicationContext)
                        } else {
                            ALog.e(TAG, "logout fail code is $code")
                        }
                    }

                    override fun onError(exception: Throwable?) {
                        super.onError(exception)
                        ALog.e(TAG, "logout error", exception)
                    }
                })
            } else {
                service.tryLogin(object : CommonUserNotify() {
                    override fun onUserLogin(success: Boolean, code: Int) {
                        ToastUtils.showLong(R.string.biz_live_please_refresh)
                    }

                    override fun onError(exception: Throwable?) {
                        service.launchLogin(application.applicationContext)
                    }
                })
            }
        }
    }

    companion object {
        private val TAG = LiveApplicationLifecycle::class.java.simpleName
    }
}