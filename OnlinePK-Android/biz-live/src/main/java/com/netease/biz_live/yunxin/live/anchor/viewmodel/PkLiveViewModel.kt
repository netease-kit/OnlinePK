/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.viewmodel

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.netease.biz_live.yunxin.live.anchor.ui.AnchorPkLiveActivity
import com.netease.yunxin.lib_live_pk_service.PkService
import com.netease.yunxin.lib_live_pk_service.bean.PkActionMsg
import com.netease.yunxin.lib_live_pk_service.bean.PkEndInfo
import com.netease.yunxin.lib_live_pk_service.bean.PkPunishInfo
import com.netease.yunxin.lib_live_pk_service.bean.PkStartInfo
import com.netease.yunxin.lib_live_pk_service.delegate.PkDelegate

/**
 * viewModel for [AnchorPkLiveActivity]
 */
class PkLiveViewModel : ViewModel() {


    /**
     * the pk request you have received
     */
    val pkActionData = MutableLiveData<PkActionMsg?>()


    val pkStartData = MutableLiveData<PkStartInfo?>()

    val punishData = MutableLiveData<PkPunishInfo?>()

    val pkEndData = MutableLiveData<PkEndInfo?>()

    private val pkDelegate = object : PkDelegate {
        /**
         * anchor received pk request
         */
        override fun onPkRequestReceived(pkActionMsg: PkActionMsg) {
            pkActionData.postValue(pkActionMsg)
        }

        /**
         * anchor's pk request been rejected
         */
        override fun onPkRequestRejected(pkActionMsg: PkActionMsg) {
            pkActionData.postValue(pkActionMsg)
        }

        /**
         * pk request have been canceled
         */
        override fun onPkRequestCancel(pkActionMsg: PkActionMsg) {
            pkActionData.postValue(pkActionMsg)
        }

        /**
         * pk request have been accepted
         */
        override fun onPkRequestAccept(pkActionMsg: PkActionMsg) {
            pkActionData.postValue(pkActionMsg)
        }

        /**
         * pk request time out
         */
        override fun onPkRequestTimeout(pkActionMsg: PkActionMsg) {
            pkActionData.postValue(pkActionMsg)
        }

        /**
         * pk state changed,pk start
         */
        override fun onPkStart(startInfo: PkStartInfo) {
            pkStartData.postValue(startInfo)
        }

        /**
         * pk state changed,punish start
         */
        override fun onPunishStart(punishInfo: PkPunishInfo) {
            punishData.postValue(punishInfo)
        }

        /**
         * pk state changed,pk end
         */
        override fun onPkEnd(endInfo: PkEndInfo) {
            pkEndData.postValue(endInfo)
        }

    }

    fun init() {
        PkService.shareInstance().setDelegate(pkDelegate)
        pkActionData.value = null
        pkEndData.value = null
        pkStartData.value = null
        punishData.value = null
    }
}