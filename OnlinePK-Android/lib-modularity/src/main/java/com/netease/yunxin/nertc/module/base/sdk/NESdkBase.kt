/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.module.base.sdk

import android.content.Context
import com.beautyFaceunity.FURenderer
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.SDKOptions
import com.netease.nimlib.sdk.auth.LoginInfo
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class NESdkBase private constructor() {
    var context: Context? = null
        private set

    companion object {
        val instance = Holder.holder
    }

    private object Holder {
        val holder = NESdkBase()
    }

    fun initContext(context: Context): NESdkBase {
        this.context = context.applicationContext
        return this
    }

    /**
     * 初始化 IM sdk
     *
     * @param appKey 用户 IM sdk 的 AppKey
     * @param info   用户登录信息，如果存在会自动登录，否则设置为null
     */
    fun initIM(appKey: String?, info: LoginInfo?): NESdkBase {
        val options = SDKOptions()
        options.appKey = appKey
        options.disableAwake = true
        NIMClient.init(context, info, options)
        return this
    }

    fun initFaceunity(): NESdkBase? {
        FURenderer.initFURenderer(context)
        // 异步拷贝 assets 资源
        GlobalScope.launch(Dispatchers.IO) {
            com.beautyFaceunity.utils.FileUtils.copyAssetsChangeFaceTemplate(context)
        }
        return this
    }

}