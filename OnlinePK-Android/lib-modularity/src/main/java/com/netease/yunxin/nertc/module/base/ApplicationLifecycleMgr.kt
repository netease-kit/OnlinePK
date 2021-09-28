/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.module.base

import android.app.Application
import java.util.*

/**
 * 单例，管理application 生命周期以及回调触发
 */
class ApplicationLifecycleMgr private constructor() {
    private val lifecycleMap: MutableMap<Class<out AbsApplicationLifecycle>, AbsApplicationLifecycle> =
        HashMap()

    companion object {
        val instance = Holder.holder
    }

    private object Holder {
        val holder = ApplicationLifecycleMgr()
    }
    //------------------------------------------------------------------------------------
    /**
     * 生命周期注册
     */
    fun registerLifecycle(lifecycle: AbsApplicationLifecycle?): ApplicationLifecycleMgr {
        if (lifecycle == null) {
            return this
        }
        if (lifecycleMap.containsKey(lifecycle.javaClass) || lifecycleMap.containsValue(lifecycle)) {
            return this
        }
        lifecycleMap[lifecycle.javaClass] = lifecycle
        return this
    }

    /**
     * @param commonRunner 各个模块通用初始化信息
     */
    @JvmOverloads
    fun notifyOnCreate(application: Application, commonRunner: Runnable? = null) {
        commonRunner?.run()
        for (lifecycle in lifecycleMap.values) {
            lifecycle.onModuleCreate(application)
        }
    }

    fun <T : AbsApplicationLifecycle?> getLifecycle(tClass: Class<T>): T? {
        val lifecycle: Any? = lifecycleMap[tClass]
        return if (tClass.isInstance(lifecycle)) lifecycle as T? else null
    }
}