/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.repository

import com.netease.yunxin.lib_live_pk_service.bean.AnchorPkInfo
import com.netease.yunxin.lib_live_pk_service.bean.PkInfo
import com.netease.yunxin.lib_network_kt.network.Response
import retrofit2.http.Body
import retrofit2.http.POST

interface PkApi {

    /**
     * Pk action
     */
    @POST("/pk/v1/inviteControl")
    suspend fun pkAction(
        @Body params: Map<String, @JvmSuppressWildcards Any?>
    ): Response<AnchorPkInfo>

    /**
     * get pk info
     */
    @POST("/pk/v1/info")
    suspend fun getPkInfo(@Body params: Map<String, @JvmSuppressWildcards Any?>): Response<PkInfo>

    /**
     * stop pk immediately
     */
    @POST("/pk/v1/end")
    suspend fun stopPk(): Response<Unit>

}