/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service

object Constants {

    object LiveType {
        const val LIVE_TYPE_DEFAULT = 0
        const val LIVE_TYPE_PK = 2
        const val LIVE_TYPE_SEAT = 3
    }

    object PushType{
        const val PUSH_TYPE_CDN = 0
        const val PUSH_TYPE_RTC = 1
    }

    object ErrorCode {
        const val RTC_DISCONNECT = 1
        const val ROOM_ID_EMPTY = 2
    }

    object MsgType {
        const val MSG_TYPE_REWARD = 1001
    }

    object LiveStatus{
        const val LIVE_STATUS_NO_START =  0//	未开始
        const val LIVE_STATUS_LIVING =  1 //	直播中
        const val LIVE_STATUS_PKING =  2 //	PK 直播中
        const val LIVE_STATUS_PK_END =  3 //	PK 结束
        const val LIVE_STATUS_LIVE_END =  4	//直播结束
        const val LIVE_STATUS_ON_PUNISHMENT =  5	//惩罚阶段
        const val LIVE_STATUS_ON_SEAT =  6	//连麦中
        const val LIVE_STATUS_PK_INVITE =  7	//邀请 PK 中
        const val LIVE_STATUS_PK_INVITED = 8	//被邀请 PK 中
    }

    object StreamLayout {
        //signal live stream layout
        const val SIGNAL_HOST_LIVE_WIDTH = 720
        const val SIGNAL_HOST_LIVE_HEIGHT = 1280

        //pk live stream layout
        const val PK_LIVE_WIDTH = 360
        const val PK_LIVE_HEIGHT = 640
        const val WH_RATIO_PK = PK_LIVE_WIDTH * 2f / PK_LIVE_HEIGHT

        //mutil seat live stream
        //麦位宽度
        const val AUDIENCE_LINKED_WIDTH = 132

        //麦位高度
        const val AUDIENCE_LINKED_HEIGHT = 170

        //观众麦位距离左侧
        const val AUDIENCE_LINKED_LEFT_MARGIN = 575

        //观众麦位距离顶部
        const val AUDIENCE_LINKED_FIRST_TOP_MARGIN = 200

        //观众麦位之间距离
        const val AUDIENCE_LINKED_BETWEEN_MARGIN = 12
    }
}