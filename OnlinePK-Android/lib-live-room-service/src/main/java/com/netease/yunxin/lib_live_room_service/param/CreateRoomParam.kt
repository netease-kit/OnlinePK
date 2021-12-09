/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.param

import com.netease.lava.nertc.sdk.video.NERtcEncodeConfig
import com.netease.yunxin.lib_live_room_service.Constants

data class CreateRoomParam(
    val roomTopic: String?,
    val cover: String?,
    val roomType: Int,
    val videoWidth: Int,
    val videoHeight: Int,
    val frameRate: NERtcEncodeConfig.NERtcVideoFrameRate,
    val mAudioScenario: Int,
    val isFrontCam: Boolean = true,
    val pushType: Int = Constants.PushType.PUSH_TYPE_CDN
)