/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.repository

import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.lib_network_kt.network.Response
import retrofit2.http.Body
import retrofit2.http.POST

interface LiveRoomApi {

    /**
     * create room
     */
    @POST("/live/v1/create")
    suspend fun createRoom(
        @Body params: Map<String, @JvmSuppressWildcards Any?>
    ): Response<LiveInfo>


    /**
     * enter room
     */
    @POST("/live/v1/info")
    suspend fun enterRoom(
        @Body params: Map<String, @JvmSuppressWildcards Any>
    ): Response<LiveInfo>


    /**
     * close room
     */
    @POST("/live/v1/close")
    suspend fun closeRoom(
        @Body params: Map<String, @JvmSuppressWildcards Any>
    ): Response<Unit>


    /**
     * audience reward to anchor
     */
    @POST("/live/v1/reward")
    suspend fun reward(
        @Body params: Map<String, @JvmSuppressWildcards Any>
    ): Response<Unit>

}