/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service

import com.netease.yunxin.lib_live_pk_service.bean.AnchorPkInfo
import com.netease.yunxin.lib_live_pk_service.bean.PkInfo
import com.netease.yunxin.lib_live_pk_service.delegate.PkDelegate
import com.netease.yunxin.lib_live_pk_service.impl.PkServiceImpl
import com.netease.yunxin.lib_network_kt.NetRequestCallback

/**
 * pk service
 */
interface PkService {
    companion object {

        /**
         * get pkService instance
         */
        @JvmStatic
        fun shareInstance(): PkService {
            return PkServiceImpl
        }

        /**
         * destroy pkService instance
         */
        @JvmStatic
        fun destroyInstance() {
            PkServiceImpl.destroyInstance()
        }
    }

    /**
     * init pk service
     */
    fun init(roomId: String)

    /**
     * set Delegate
     */
    fun setDelegate(delegate: PkDelegate)

    /**
     * remove delegate
     */
    fun removeDelegate(delegate: PkDelegate)

    /**
     * request Pk for other anchor
     * accountId:the anchor you want pk
     */
    fun requestPk(accountId: String, callback: NetRequestCallback<AnchorPkInfo>)

    /**
     * cancel Pk request
     */
    fun cancelPkRequest(callback: NetRequestCallback<Unit>)

    /**
     * accept pk request
     */
    fun acceptPk(callback: NetRequestCallback<AnchorPkInfo>)

    /**
     * reject pk request
     */
    fun rejectPkRequest(callback: NetRequestCallback<Unit>)

    /**
     * stop pk
     */
    fun stopPk(callback: NetRequestCallback<Unit>)

    /**
     * fetch pk Info
     */
    fun fetchPkInfo(callback: NetRequestCallback<PkInfo>)

}