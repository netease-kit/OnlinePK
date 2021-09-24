/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.bean

import java.io.Serializable

/**
 * 直播参数
 */
data class LiveConfig(//	直播拉流地址
    val httpPullUrl: String,
    // rtmp直播拉流地址
    val rtmpPullUrl: String,
    //hls拉流地址
    val hlsPullUrl: String,
    //	推流地址pushUrl
    val pushUrl: String,
    //	直播频道Cid
    val cid: String
) : Serializable