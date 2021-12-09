/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service

import android.content.Context
import com.netease.nimlib.sdk.chatroom.model.ChatRoomInfo
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.lib_live_room_service.delegate.LiveRoomDelegate
import com.netease.yunxin.lib_live_room_service.impl.AudioOption
import com.netease.yunxin.lib_live_room_service.impl.LiveRoomServiceImpl
import com.netease.yunxin.lib_live_room_service.impl.NERtcCallbackTemp
import com.netease.yunxin.lib_live_room_service.impl.VideoOption
import com.netease.yunxin.lib_live_room_service.param.CreateRoomParam
import com.netease.yunxin.lib_live_room_service.param.LiveStreamTaskRecorder
import com.netease.yunxin.lib_network_kt.NetRequestCallback

interface LiveRoomService {

    companion object {
        @JvmStatic
        fun sharedInstance(): LiveRoomService {
            return LiveRoomServiceImpl
        }

        @JvmStatic
        fun destroyInstance() {
            LiveRoomServiceImpl.destroy()
        }


    }

    /**
     * setup with Options
     */
    fun setupWithOptions(context: Context, appKey: String)

    /**
     * add delegate for call back,you can add only one
     */
    fun addDelegate(delegate: LiveRoomDelegate)

    /**
     * remove the delegate you add before
     */
    fun removeDelegate(delegate: LiveRoomDelegate)

    /**
     * create a live room
     * roomType [Constants.LiveType]
     */
    fun createRoom(param: CreateRoomParam, callback: NetRequestCallback<LiveInfo>)

    /**
     * destroy the room you create before
     */
    fun destroyRoom(callback: NetRequestCallback<Unit>)

    /**
     * enter a room
     */
    fun enterRoom(roomId: String, callback: NetRequestCallback<LiveInfo>)

    /**
     * leave a room
     */
    fun leaveRoom(callback: NetRequestCallback<Unit>)

    /**
     * update push stream task
     */
    fun updateLiveStream(liveRecoder: LiveStreamTaskRecorder,callback: NetRequestCallback<Int>? = null): Int

    /**
     * send a gift to anchor
     */
    fun reward(giftId: Int, callback: NetRequestCallback<Unit>)

    /**
     * start channel media relay
     */
    fun startChannelMediaRelay(token: String, channelName: String, uid: Long): Boolean

    /**
     * stop channel media relay
     */
    fun stopChannelMediaRelay(): Int

    /**
     * join rtc channel
     */
    fun joinRtcChannel(token: String, channelName: String, uid: Long)

    /**
     * leave rtc channel
     */
    fun leaveRtcChannel()

    /**
     * send text message to chatRoom
     */
    fun sendTextMessage(msg: String)

    /**
     * get audio option
     */
    fun getAudioOption(): AudioOption

    /**
     * get video option
     */
    fun getVideoOption(): VideoOption

    /**
     * add delegate for rtc callback
     */
    fun addNERTCDelegate(delegate: NERtcCallbackTemp)

    /**
     *  query chatroom info
     */
    fun queryChatRoomInfo(roomId: String,callback: NetRequestCallback<ChatRoomInfo>)
}