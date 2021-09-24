/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.network

import com.netease.biz_live.yunxin.live.model.response.LiveListResponse
import com.netease.yunxin.android.lib.network.common.BaseResponse
import io.reactivex.Single
import retrofit2.http.Body
import retrofit2.http.POST

/**
 * 直播网络访问
 */
interface LiveServerApi {
    /**
     * 获取直播间列表
     */
    @POST("/live/v1/list")
    open fun getLiveRoomList(@Body body: Map<String,@JvmSuppressWildcards Any?>): Single<BaseResponse<LiveListResponse?>?>

    /**
     * 获取房间主题
     *
     * @param body
     * @return
     */
    @POST("/v1/room/getRandomRoomTopic")
    open fun getTopic(@Body body: MutableMap<String?, Any?>?): Single<BaseResponse<String?>?>

    /**
     * 获取房间封面
     *
     * @param body
     * @return
     */
    @POST("/v1/room/getRandomLivePic")
    open fun getCover(@Body body: MutableMap<String?, Any?>?): Single<BaseResponse<String?>?>

    companion object {
        /**
         * 直播频道不存在
         */
        const val ERROR_CODE_ROOM_NOT_EXIST = 655

        /**
         * 用户不在直播房间内
         */
        const val ERROR_CODE_USER_NOT_IN_ROOM = 2101
    }
}