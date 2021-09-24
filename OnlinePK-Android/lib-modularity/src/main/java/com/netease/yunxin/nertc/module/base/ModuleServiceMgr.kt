/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.module.base

import android.content.Context
import java.util.*

class ModuleServiceMgr private constructor() {
    private val serviceMap: MutableMap<Class<*>, ModuleService?> = HashMap()

    companion object {
        val instance = Holder.holder
    }

    private object Holder {
        val holder = ModuleServiceMgr()
    }

    fun registerService(
        clazz: Class<*>?,
        context: Context,
        service: ModuleService?
    ): ModuleServiceMgr {
        if (clazz == null || service == null) {
            return this
        }
        if (serviceMap.containsValue(service)) {
            return this
        }
        serviceMap[clazz] = service
        service.onInit(context)
        return this
    }

    /**
     * 获取方法服务实例
     *
     * @param tClass 服务类型
     * @return 服务实例
     */
    fun <T : ModuleService?> getService(tClass: Class<T>): T {
        val lifecycle: Any? = serviceMap[tClass]
        val result = if (tClass.isInstance(lifecycle)) lifecycle as T? else null
        return result ?: getService<ModuleService>(tClass.canonicalName) as T
    }

    fun <T : ModuleService?> getService(className: String?): T? {
        var tClass: Class<*>? = null
        try {
            tClass = Class.forName(className)
        } catch (e: ClassNotFoundException) {
            e.printStackTrace()
        }
        if (tClass == null) {
            return null
        }
        val service: Any? = serviceMap[tClass]
        var result: T? = null
        try {
            result = service as T?
        } catch (e: ClassCastException) {
            e.printStackTrace()
        }
        if (result != null) {
            return result
        }
        try {
            result = tClass.newInstance() as T
            serviceMap[tClass] = result
        } catch (e: IllegalAccessException) {
            e.printStackTrace()
        } catch (e: InstantiationException) {
            e.printStackTrace()
        }
        return result
    }

}