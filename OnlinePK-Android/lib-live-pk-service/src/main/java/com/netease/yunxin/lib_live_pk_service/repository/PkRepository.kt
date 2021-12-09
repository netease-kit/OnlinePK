/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.repository

import com.netease.yunxin.lib_live_pk_service.PkConstants.PkAction
import com.netease.yunxin.lib_live_pk_service.bean.AnchorPkInfo
import com.netease.yunxin.lib_live_pk_service.bean.PkInfo
import com.netease.yunxin.lib_network_kt.network.Response
import com.netease.yunxin.lib_network_kt.network.ServiceCreator
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

object PkRepository {
    private val pkApi by lazy { ServiceCreator.create(PkApi::class.java) }

    /**
     * pk action
     * action in [PkAction]
     */
    suspend fun pkAction(
        action: Int, targetAccountId: String?
    ): Response<AnchorPkInfo> = withContext(Dispatchers.IO) {
        val params = mapOf<String, Any?>(
            "action" to action, "targetAccountId" to targetAccountId
        )
        pkApi.pkAction(params)
    }

    suspend fun getPkInfo(
        roomId: String?
    ): Response<PkInfo> = withContext(Dispatchers.IO) {
        val params = mapOf<String, Any?>(
            "roomId" to roomId
        )
        pkApi.getPkInfo(params)
    }

    suspend fun stopPk(): Response<Unit> = withContext(Dispatchers.IO) {
        pkApi.stopPk()
    }

}