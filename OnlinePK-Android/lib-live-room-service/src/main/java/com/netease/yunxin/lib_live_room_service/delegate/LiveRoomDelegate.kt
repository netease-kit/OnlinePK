/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.delegate

import com.netease.yunxin.lib_live_room_service.bean.LiveUser
import com.netease.yunxin.lib_live_room_service.chatroom.RewardMsg
import com.netease.yunxin.lib_live_room_service.chatroom.TextWithRoleAttachment
import com.netease.yunxin.lib_live_room_service.param.ErrorInfo

interface LiveRoomDelegate {
    /**
     * error occur when live,if serious stop live and exit
     */
    fun onError(errorInfo: ErrorInfo)

    /**
     * room destroy，audience exit room
     */
    fun onRoomDestroy()

    /**
     * user count in room changed
     */
    fun onUserCountChange(userCount: Int)

    /**
     * receive text message
     */
    fun onRecvRoomTextMsg(nickname: String, attachment: TextWithRoleAttachment)

    /**
     * user enter live room
     */
    fun onUserEntered(nickname: String)

    /**
     * user left live room
     */
    fun onUserLeft(nickname: String)

    /**
     * kicked out by login in other set
     */
    fun onKickedOut()

    /**
     * anchor leave chatRoom
     */
    fun onAnchorLeave()

    /**
     * audience reward a gift
     */
    fun onUserReward(rewardInfo: RewardMsg)

    /**
     * audio effect callback
     */
    fun onAudioEffectFinished(effectId: Int)

    /**
     * audio mixing callback
     */
    fun onAudioMixingFinished()

    /**
     * audience change
     * ten audience will return in live room
     */
    fun onAudienceChange(infoList: MutableList<LiveUser>)
}