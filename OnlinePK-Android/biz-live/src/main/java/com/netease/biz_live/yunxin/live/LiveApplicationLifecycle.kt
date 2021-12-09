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
import com.netease.yunxin.login.sdk.AuthorManager
import com.netease.yunxin.login.sdk.model.LoginCallback
import com.netease.yunxin.login.sdk.model.UserInfo
import com.netease.yunxin.nertc.module.base.AbsApplicationLifecycle

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

            //todo 启动Activity修改
            if (AuthorManager.isLogin()) {
//                AuthorManager.logout(object :LoginCallback<Void>{
//                    override fun onError(errorCode: Int, errorMsg: String) {
//                        ALog.e(TAG, "logout error", errorMsg)
//                    }
//
//                    override fun onSuccess(data: Void?) {
//                        AuthorManager.launchLogin(application.applicationContext)
//                    }
//
//                })

            } else {
                AuthorManager.autoLogin(object :LoginCallback<UserInfo>{
                    override fun onError(errorCode: Int, errorMsg: String) {
//                        AuthorManager.launchLogin(application.applicationContext)
                    }

                    override fun onSuccess(data: UserInfo?) {
                        ToastUtils.showLong(R.string.biz_live_please_refresh)
                    }

                })
            }
        }
    }

    companion object {
        private val TAG = LiveApplicationLifecycle::class.java.simpleName
    }
}