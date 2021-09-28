/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.network

import com.netease.biz_live.yunxin.live.model.response.LiveListResponse
import com.netease.yunxin.android.lib.network.common.BaseResponse
import com.netease.yunxin.android.lib.network.common.NetworkClient
import com.netease.yunxin.android.lib.network.common.transform.ErrorTransform
import io.reactivex.Single
import java.util.*

/**
 * 直播网络访问交互
 */
object LiveInteraction {
    /**
     * 获取直播间列表
     *
     * @param type
     * @param pageNum
     * @param pageSize
     * @return
     */
    fun getLiveList(
        type: Int,
        status:Int? = null,
        pageNum: Int,
        pageSize: Int
    ): Single<BaseResponse<LiveListResponse?>?> {
        val serverApi = NetworkClient.getInstance().getService(
            LiveServerApi::class.java
        )
        val map = mapOf<String, Any?>(
            "roomType" to type,
            "liveStatus" to status,
            "pageNum" to pageNum,
            "pageSize" to pageSize
        )

        return serverApi.getLiveRoomList(map).compose(ErrorTransform())
            .map { liveInfoBaseResponse: BaseResponse<LiveListResponse?>? -> liveInfoBaseResponse }
    }


    /**
     * 获取随机主题
     *
     * @return
     */
    fun getTopic(): Single<BaseResponse<String?>?>? {
        val api = NetworkClient.getInstance().getService(
            LiveServerApi::class.java
        )
        val params: MutableMap<String?, Any?> = HashMap(1)
        return api.getTopic(params).compose(ErrorTransform())
            .map { stringBaseResponse: BaseResponse<String?>? -> stringBaseResponse }
    }

    /**
     * 获取随机封面
     *
     * @return
     */
    fun getCover(): Single<BaseResponse<String?>?>? {
        val api = NetworkClient.getInstance().getService(
            LiveServerApi::class.java
        )
        val params: MutableMap<String?, Any?> = HashMap(1)
        return api.getCover(params).compose(ErrorTransform())
            .map { stringBaseResponse: BaseResponse<String?>? -> stringBaseResponse }
    }
}