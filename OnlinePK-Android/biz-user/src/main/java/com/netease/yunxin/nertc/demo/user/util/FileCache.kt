/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.user.util

import android.content.Context
import android.text.TextUtils
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.io.*

/**
 * Created by luc on 2020/11/8.
 */
object FileCache {
    private const val CACHE_NAME = "temp"
    private var cacheRoot: File? = null
    fun <T> cacheValue(context: Context, data: T, token: TypeToken<T>): Boolean {
        return cacheValue(context, getCommonFileName(token), data, token)
    }

    fun <T> cacheValue(context: Context, name: String, data: T, token: TypeToken<T>): Boolean {
        val jsonStr = Gson().toJson(data, token.type)
        val fileName = getFullFileName(context, name)
        return writeStr(jsonStr, fileName)
    }

    fun <T> getCacheValue(context: Context, token: TypeToken<T>): T {
        return getCacheValue(context, getCommonFileName(token), token)
    }

    fun <T> getCacheValue(context: Context, name: String, token: TypeToken<T>): T {
        val jsonStr = readStr(getFullFileName(context, name))
        return Gson().fromJson(jsonStr, token.type)
    }

    fun <T> removeCache(context: Context, token: TypeToken<T>): Boolean {
        return removeCache(context, getCommonFileName(token))
    }

    fun removeCache(context: Context, name: String): Boolean {
        val fileName = getFullFileName(context, name)
        val cache = File(fileName)
        return !cache.exists() || cache.delete()
    }

    /**
     * 写入字符串至指定文件中
     *
     * @return true 写入成功，false 写入失败
     */
    private fun writeStr(json: String, fileName: String): Boolean {
        if (TextUtils.isEmpty(fileName)) {
            return false
        }
        var result = false
        try {
            BufferedWriter(FileWriter(fileName)).use { writer ->
                writer.write(json)
                result = true
            }
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return result
    }

    /**
     * 从指定文件中读取对应的字符串内容
     */
    private fun readStr(fileName: String): String {
        val builder = StringBuilder()
        try {
            BufferedReader(FileReader(fileName)).use { reader ->
                var line: String?
                do {
                    line = reader.readLine()
                    if (line != null) {
                        builder.append(line)
                    }
                } while (line != null)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return builder.toString()
    }

    private fun <T> getCommonFileName(token: TypeToken<T>): String {
        return token.rawType.canonicalName
    }

    private fun getFullFileName(context: Context, fileName: String): String {
        return File(getCacheFile(context), fileName).absolutePath
    }

    /**
     * 获取 缓存文件夹
     *
     * @param context 当前 app 上下文
     * @return 缓存文件夹
     */
    private fun getCacheFile(context: Context): File? {
        if (cacheRoot != null) {
            return cacheRoot
        }
        val cacheParent = context.cacheDir
        val cache = File(cacheParent, CACHE_NAME)
        if (!cache.exists()) {
            cache.mkdirs()
        }
        cacheRoot = cache
        return cacheRoot
    }
}