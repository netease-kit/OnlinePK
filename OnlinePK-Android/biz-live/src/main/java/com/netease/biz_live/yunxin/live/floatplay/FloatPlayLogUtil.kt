package com.netease.biz_live.yunxin.live.floatplay

import com.netease.yunxin.kit.alog.ALog

object FloatPlayLogUtil {
    private const val TAG = "FloatPlayLogUtil"

    @JvmStatic
    fun log(tag: String?, msg: String?) {
        ALog.d(tag, msg)
    }

    @JvmStatic
    fun log(msg: String?) {
        log(TAG, msg)
    }
}