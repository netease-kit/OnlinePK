/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.viewmodel

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.netease.biz_live.yunxin.live.anchor.ui.AnchorSeatLiveActivity
import com.netease.biz_live.yunxin.live.model.SeatMemberInfo
import com.netease.yunxin.seatlibrary.seat.delegate.SeatDelegate
import com.netease.yunxin.seatlibrary.seat.event.*
import com.netease.yunxin.seatlibrary.seat.service.SeatService

/**
 * viewModel for [AnchorSeatLiveActivity]
 */
class SeatViewModel : ViewModel() {

    val seatUserData = MutableLiveData<Pair<Boolean, SeatMemberInfo>>()

    val applyUserData = MutableLiveData<SeatUser>()

    val pickRejectData = MutableLiveData<SeatUser>()

    val avMuteSeatData = MutableLiveData<SeatMemberInfo>()

    val seatDelegate = object : SeatDelegate {
        /**
         * 收到上麦申请
         */
        override fun onSeatApplyRequest(event: SeatApplyEvent) {
            applyUserData.postValue(event.responder)
        }

        /**
         * 上麦申请被取消的回调
         */
        override fun onSeatApplyRequestCanceled(event: SeatApplyEvent) {
            //need not implement
        }

        /**
         * 收到报麦申请同意
         */
        override fun onSeatPickAccepted(event: SeatPickEvent) {
            //anchor need not implement
        }

        /**
         * 收到报麦申请被拒绝
         */
        override fun onSeatPickRejected(event: SeatPickEvent) {
            pickRejectData.postValue(event.responder)
        }

        /**
         * 麦位加入的回调
         */
        override fun onSeatEntered(event: SeatEnterEvent) {
            val seatMember = SeatMemberInfo(event.seatInfo, event.avRoomUser)
            seatUserData.postValue(Pair(true, seatMember))
        }

        /**
         * 麦位离开的回调
         */
        override fun onSeatLeft(event: SeatLeaveEvent) {
            val seatMember = SeatMemberInfo(event.seatInfo, event.avRoomUser)
            seatUserData.postValue(Pair(false, seatMember))
        }

        /**
         * 收到报麦申请
         */
        override fun onSeatPickRequest(event: SeatPickRequestEvent) {
            //anchor need not implement
        }

        /**
         * 抱麦申请被取消的回调
         */
        override fun onSeatPickRequestCanceled(event: SeatPickRequestEvent) {
            //anchor need not implement
        }

        /**
         * 申请上麦被同意
         */
        override fun onSeatApplyAccepted(event: SeatApplyEvent) {
            //anchor need not implement
        }

        /**
         * 申请上麦被拒绝
         */
        override fun onSeatApplyRejected(event: SeatApplyEvent) {
            //anchor need not implement
        }

        /**
         * 麦位声音状态回调
         */
        override fun onSeatAudioMuteStateChanged(event: SeatStateChangeEvent) {
            val seatMember = SeatMemberInfo(event.seatInfo, event.avRoomUser)
            avMuteSeatData.postValue(seatMember)
        }

        /**
         * 麦位视频状态回调
         */
        override fun onSeatVideoMuteStateChanged(event: SeatStateChangeEvent) {
            val seatMember = SeatMemberInfo(event.seatInfo, event.avRoomUser)
            avMuteSeatData.postValue(seatMember)
        }

        /**
         * 麦位开关状态回调
         */
        override fun onSeatStateChanged(event: SeatStateChangeEvent) {
            // need not implement
        }

        /**
         * 自定义状态变更的回调
         */
        override fun onSeatCustomInfoChanged(event: SeatStateChangeEvent) {
            // need not implement
        }

    }

    fun init() {
        SeatService.sharedInstance().addDelegate(seatDelegate)
    }
}