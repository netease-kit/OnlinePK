/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service.delegate

import com.netease.yunxin.lib_live_pk_service.bean.PkActionMsg
import com.netease.yunxin.lib_live_pk_service.bean.PkEndInfo
import com.netease.yunxin.lib_live_pk_service.bean.PkPunishInfo
import com.netease.yunxin.lib_live_pk_service.bean.PkStartInfo

interface PkDelegate {
    /**
     * anchor received pk request
     */
    fun onPkRequestReceived(pkActionMsg: PkActionMsg){}

    /**
     * anchor's pk request been rejected
     */
    fun onPkRequestRejected(pkActionMsg: PkActionMsg){}

    /**
     * pk request have been canceled
     */
    fun onPkRequestCancel(pkActionMsg: PkActionMsg){}

    /**
     * pk request have been accepted
     */
    fun onPkRequestAccept(pkActionMsg: PkActionMsg){}

    /**
     * pk request time out
     */
    fun onPkRequestTimeout(pkActionMsg: PkActionMsg){}

    /**
     * pk state changed,pk start
     */
    fun onPkStart(startInfo: PkStartInfo)

    /**
     * pk state changed,punish start
     */
    fun onPunishStart(punishInfo: PkPunishInfo)

    /**
     * pk state changed,pk end
     */
    fun onPkEnd(endInfo: PkEndInfo)
}