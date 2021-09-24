/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.repository

import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.lib_network_kt.network.Response
import com.netease.yunxin.lib_network_kt.network.ServiceCreator
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

object LiveRoomRepository {
    private val roomApi by lazy { ServiceCreator.create(LiveRoomApi::class.java) }

    suspend fun createLiveRoom(
        roomTopic: String?, cover: String?, roomType: Int,pushType:Int
    ): Response<LiveInfo> = withContext(Dispatchers.IO) {
        val params = mapOf<String, Any?>(
            "roomTopic" to roomTopic, "cover" to cover, "roomType" to roomType,"pushType" to pushType
        )
        roomApi.createRoom(params)
    }

    suspend fun enterRoom(roomId: String): Response<LiveInfo> = withContext(Dispatchers.IO) {
        val params = mapOf(
            "roomId" to roomId
        )
        roomApi.enterRoom(params)
    }

    suspend fun closeRoom(roomId: String): Response<Unit> = withContext(Dispatchers.IO) {
        val params = mapOf(
            "roomId" to roomId
        )
        roomApi.closeRoom(params)
    }

    suspend fun reward(roomId: String, giftId: Int): Response<Unit> = withContext(Dispatchers.IO) {
        val params = mapOf(
            "roomId" to roomId, "giftId" to giftId
        )
        roomApi.reward(params)
    }
}