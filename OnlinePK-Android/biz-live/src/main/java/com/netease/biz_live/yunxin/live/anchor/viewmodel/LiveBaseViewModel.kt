/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.viewmodel

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.netease.biz_live.yunxin.live.anchor.ui.AnchorBaseLiveActivity
import com.netease.biz_live.yunxin.live.chatroom.ChatRoomMsgCreator
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.LiveRoomService
import com.netease.yunxin.lib_live_room_service.bean.LiveUser
import com.netease.yunxin.lib_live_room_service.chatroom.RewardMsg
import com.netease.yunxin.lib_live_room_service.chatroom.TextWithRoleAttachment
import com.netease.yunxin.lib_live_room_service.delegate.LiveRoomDelegate
import com.netease.yunxin.lib_live_room_service.param.ErrorInfo

/**
 * viewModel for [AnchorBaseLiveActivity]
 */
class LiveBaseViewModel : ViewModel() {

    companion object {
        const val LOG_TAG = "LiveBaseViewModel"
    }


    val errorData = MutableLiveData<ErrorInfo>()

    val chatRoomMsgData = MutableLiveData<CharSequence>()

    val userAccountData = MutableLiveData<Int>()

    val rewardData = MutableLiveData<RewardMsg>()

    val audioEffectFinishData = MutableLiveData<Int>()

    val audioMixingFinishData = MutableLiveData<Boolean>()

    val audienceData = MutableLiveData<MutableList<LiveUser>>()

    val kickedOutData = MutableLiveData<Boolean>()

    private val roomCallback: LiveRoomDelegate = object : LiveRoomDelegate {
        override fun onError(errorInfo: ErrorInfo) {
            errorData.postValue(errorInfo)
        }

        override fun onRoomDestroy() {
            //this should be implemented with audience
        }

        override fun onUserCountChange(userCount: Int) {
            userAccountData.postValue(userCount)
        }

        override fun onRecvRoomTextMsg(nickname: String, attachment: TextWithRoleAttachment) {
            val content = attachment.msg
            val isAnchor = attachment.isAnchor
            ALog.d(LOG_TAG,"onRecvRoomTextMsg :$nickname")
            chatRoomMsgData.postValue(ChatRoomMsgCreator.createText(isAnchor, nickname, content))
        }

        override fun onUserEntered(nickname: String) {
            ALog.d(LOG_TAG, "onUserEntered :$nickname")
            chatRoomMsgData.postValue(ChatRoomMsgCreator.createRoomEnter(nickname))
        }

        override fun onUserLeft(nickname: String) {
            ALog.d(LOG_TAG, "onUserLeft :$nickname")
            chatRoomMsgData.postValue(ChatRoomMsgCreator.createRoomExit(nickname))
        }

        /**
         * kicked out by login in other set
         */
        override fun onKickedOut() {
            kickedOutData.postValue(true)
        }

        /**
         * anchor leave chatRoom
         */
        override fun onAnchorLeave() {
            kickedOutData.postValue(true)
        }

        override fun onUserReward(rewardInfo: RewardMsg) {
            rewardData.value = rewardInfo
        }

        override fun onAudioEffectFinished(effectId: Int) {
            audioEffectFinishData.postValue(effectId)
        }

        override fun onAudioMixingFinished() {
            audioMixingFinishData.postValue(true)
        }

        /**
         * audience change
         * ten audience will return in live room
         */
        override fun onAudienceChange(infoList: MutableList<LiveUser>) {
            audienceData.postValue(infoList)
        }

    }

    fun init() {
        LiveRoomService.sharedInstance().addDelegate(roomCallback)
    }


}