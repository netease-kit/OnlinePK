/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_pk_service

object PkConstants {
    object PkAction {
        const val PK_INVITE = 1
        const val PK_ACCEPT = 2
        const val PK_REJECT = 3
        const val PK_CANCEL = 4
        const val PK_TIME_OUT = 5
    }

    object PkMsgType {
        const val PK_ACTION = 2000//pk 邀请，接受，拒绝，取消等操作
        const val PK_START = 2001//	PK 开始消息
        const val PK_PUNISH = 2002//	PK 惩罚开始消息
        const val PK_STOP = 2003//	PK 结束消息
    }

    object PkStatus{
        const val PK_STATUS_IDLE = 0//	未开始
        const val PK_STATUS_PKING =1//	PK 中
        const val PK_STATUS_END =2	//PK 结束
        const val PK_STATUS_CANCELED =3	//已取消
        const val PK_STATUS_REJECTED = 4    //已拒绝
        const val PK_STATUS_INVITED = 5//	邀请中
        const val PK_STATUS_PUNISHMENT = 6    //惩罚中
    }

    object FailedReason {
        //  1：action time out ，2：join rtc channel fail
        const val ACTION_TIME_OUT = 1
        const val JOIN_RTC_CHANNEL_FAILED = 2
    }

    object ErrorCode {
        //no pk info
        const val CODE_NO_PK = 55004
    }
}