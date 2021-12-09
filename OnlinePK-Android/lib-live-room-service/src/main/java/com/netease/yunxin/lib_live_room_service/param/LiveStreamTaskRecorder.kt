/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.param

import com.netease.yunxin.lib_live_room_service.Constants
import kotlin.math.abs

data class LiveStreamTaskRecorder(
    val pushUrl: String,
    val selfUid: Long
) {


    val taskId = abs(pushUrl.hashCode()).toString()

    val audienceUid: MutableSet<Long> = HashSet()

    var otherAnchorUid: Long? = null

    var muteOther: Boolean = false

    var type: Int = Constants.LiveType.LIVE_TYPE_DEFAULT

    fun addAudienceUid(uid: Long) {
        audienceUid.add(uid)
    }

    fun removeAudienceUid(uid: Long) {
        audienceUid.remove(uid)
    }

}