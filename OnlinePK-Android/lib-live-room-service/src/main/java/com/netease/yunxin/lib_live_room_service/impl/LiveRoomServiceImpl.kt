/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.impl

import android.content.Context
import com.netease.lava.nertc.sdk.*
import com.netease.lava.nertc.sdk.video.NERtcRemoteVideoStreamType
import com.netease.lava.nertc.sdk.video.NERtcVideoConfig
import com.netease.nimlib.sdk.chatroom.model.ChatRoomInfo
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.BuildConfig
import com.netease.yunxin.lib_live_room_service.Constants
import com.netease.yunxin.lib_live_room_service.LiveRoomService
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.lib_live_room_service.chatroom.control.ChatRoomControl
import com.netease.yunxin.lib_live_room_service.delegate.LiveRoomDelegate
import com.netease.yunxin.lib_live_room_service.param.CreateRoomParam
import com.netease.yunxin.lib_live_room_service.param.ErrorInfo
import com.netease.yunxin.lib_live_room_service.param.LiveStreamTaskRecorder
import com.netease.yunxin.lib_live_room_service.repository.LiveRoomRepository
import com.netease.yunxin.lib_network_kt.NetRequestCallback
import com.netease.yunxin.lib_network_kt.network.Request
import kotlinx.coroutines.*

object LiveRoomServiceImpl : LiveRoomService {

    const val LOG_TAG = "LiveRoomServiceImpl"

    var delegate: LiveRoomDelegate? = null
    var rtcDelegate: NERtcCallbackTemp? = null

    var liveInfo: LiveInfo? = null

    private val engine: NERtcEx by lazy { NERtcEx.getInstance() }

    private var roomScope: CoroutineScope? = null

    private var isAnchor: Boolean = false

    private val rtcCallback: NERtcCallbackEx = object : NERtcCallbackTemp {
        override fun onUserJoined(uid: Long) {
            super.onUserJoined(uid)
            ALog.d(LOG_TAG, "onUserJoined,uid:$uid")
            rtcDelegate?.onUserJoined(uid)
        }

        override fun onDisconnect(p0: Int) {
            super.onDisconnect(p0)
            if (isAnchor) {
                delegate?.onError(
                    ErrorInfo(
                        true,
                        Constants.ErrorCode.RTC_DISCONNECT,
                        "rtc disconnect"
                    )
                )
            }
        }

        override fun onAudioMixingStateChanged(p0: Int) {
            super.onAudioMixingStateChanged(p0)
            delegate?.onAudioMixingFinished()
        }

        override fun onAudioEffectFinished(p0: Int) {
            super.onAudioEffectFinished(p0)
            delegate?.onAudioEffectFinished(p0)
        }

        override fun onJoinChannel(p0: Int, p1: Long, p2: Long, p3: Long) {
            super.onJoinChannel(p0, p1, p2, p3)
            if (p0 != NERtcConstants.ErrorCode.OK) {
                ALog.d(LOG_TAG, "join rtc error code = $p0")
                delegate?.onError(ErrorInfo(true, p0, "join rtc error"))
            } else {
                ALog.d(LOG_TAG, "join rtc success,p0:$p0,p1:$p1,p2:$p2,p3:$p3")
                liveInfo?.let {
                    val liveRecoder =
                        LiveStreamTaskRecorder(it.live.liveConfig.pushUrl, it.anchor.roomUid!!)
                    LiveStream.addLiveStreamTask(liveRecoder)
                }
            }
        }

        override fun onUserAudioStart(uid: Long) {
            ALog.i(LOG_TAG,"onUserAudioStart$uid")
            super.onUserAudioStart(uid)
        }

        override fun onUserVideoStart(uid: Long, p1: Int) {
            ALog.i(LOG_TAG, "onUserVideoStart$uid")
            engine.subscribeRemoteVideoStream(
                uid,
                NERtcRemoteVideoStreamType.kNERtcRemoteVideoStreamTypeHigh,
                true
            )
            super.onUserVideoStart(uid, p1)
        }

        override fun onUserVideoStop(uid: Long) {
            ALog.i(LOG_TAG, "onUserVideoStop$uid")
            engine.subscribeRemoteVideoStream(
                uid,
                NERtcRemoteVideoStreamType.kNERtcRemoteVideoStreamTypeHigh,
                false
            )
            super.onUserVideoStop(uid)
        }

        override fun onAudioDeviceChanged(p0: Int) {
            AudioOption.audioDevice = p0
            super.onAudioDeviceChanged(p0)
        }
    }

    fun destroy() {
        delegate = null
        ChatRoomControl.destroy()
        engine.release()
        roomScope?.cancel()
        roomScope = null
        liveInfo = null
    }


    /**
     * setup with Options
     */
    override fun setupWithOptions(context: Context, appKey: String) {
        val videoConfig = NERtcVideoConfig()
        videoConfig.frontCamera = true //默认是前置摄像头
        engine.setLocalVideoConfig(videoConfig)
        val options = NERtcOption()
        if (BuildConfig.DEBUG) {
            options.logLevel = NERtcConstants.LogLevel.INFO
        } else {
            options.logLevel = NERtcConstants.LogLevel.WARNING
        }
        try {
            engine.init(context, appKey, rtcCallback, options)
        } catch (e: Throwable) {
            return
        }
        roomScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    }

    /**
     * add delegate for call back,you can add only one
     */
    override fun addDelegate(delegate: LiveRoomDelegate) {
        this.delegate = delegate
        ChatRoomControl.init(delegate)
    }

    /**
     * remove the delegate you add before
     */
    override fun removeDelegate(delegate: LiveRoomDelegate) {
        this.delegate = null
    }

    /**
     * create a live room
     * roomType [Constants]
     */
    override fun createRoom(param: CreateRoomParam, callback: NetRequestCallback<LiveInfo>) {
        isAnchor = true
        val videoConfig = NERtcVideoConfig()
        videoConfig.width = param.videoWidth
        videoConfig.height = param.videoHeight
        videoConfig.videoCropMode = NERtcConstants.VideoCropMode.CROP_16x9
        videoConfig.frameRate = param.frameRate
        videoConfig.frontCamera = param.isFrontCam
        engine.setLocalVideoConfig(videoConfig)
        if (param.mAudioScenario == NERtcConstants.AudioScenario.MUSIC) {
            engine.setAudioProfile(
                NERtcConstants.AudioProfile.HIGH_QUALITY_STEREO,
                param.mAudioScenario
            )
        } else {
            engine.setAudioProfile(NERtcConstants.AudioProfile.HIGH_QUALITY, param.mAudioScenario)
        }
        engine.setChannelProfile(NERtcConstants.RTCChannelProfile.COMMUNICATION)
        engine.setClientRole(NERtcConstants.UserRole.CLIENT_ROLE_BROADCASTER)
        val parameters = NERtcParameters()
        parameters.set(NERtcParameters.KEY_PUBLISH_SELF_STREAM, true)
        engine.setParameters(parameters)
        engine.enableLocalVideo(true)
        roomScope?.launch {
            Request.request(
                { LiveRoomRepository.createLiveRoom(param.roomTopic, param.cover, param.roomType,param.pushType) },
                success = {
                    it?.let {
                        anchorJoinRoom(it, callback)
                    }
                },
                error = { code, msg ->
                    callback.error(code, msg)
                }
            )
        }
    }

    /**
     * 主播加入房间（聊天室和rtc）
     */
    private fun anchorJoinRoom(liveInfo: LiveInfo, callback: NetRequestCallback<LiveInfo>) {
        this.liveInfo = liveInfo
        val rtcResult = engine.joinChannel(
            liveInfo.anchor.roomCheckSum,
            liveInfo.live.roomCname,
            liveInfo.anchor.roomUid!!
        )
        if (rtcResult == NERtcConstants.ErrorCode.OK) {
            joinChatRoom(liveInfo, callback)
        } else {
            callback.error(rtcResult, "join rtc channel failed")
        }
    }


    /**
     * 加入聊天室
     */
    private fun joinChatRoom(liveInfo: LiveInfo, callback: NetRequestCallback<LiveInfo>) {
        ChatRoomControl.joinChatRoom(
            liveInfo.live.chatRoomId,
            if (isAnchor) liveInfo.anchor else liveInfo.joinUserInfo!!,
            isAnchor,
            object : NetRequestCallback<Unit> {
                override fun error(code: Int, msg: String) {
                    callback.error(code, msg)
                }

                override fun success(info: Unit?) {
                    callback.success(liveInfo)
                }

            })
    }


    /**
     * destroy the room you create before
     */
    override fun destroyRoom(callback: NetRequestCallback<Unit>) {
        if (liveInfo != null) {
            roomScope?.launch {
                Request.request(
                    { LiveRoomRepository.closeRoom(liveInfo!!.live.roomId) },
                    success = {
                        callback.success()
                        leaveChatRoomAndRtc()
                    },
                    error = { code: Int, msg: String ->
                        callback.error(code, msg)
                    }
                )
            }
        } else {
            callback.error(Constants.ErrorCode.ROOM_ID_EMPTY, "roomId is empty")
        }
    }

    private fun leaveChatRoomAndRtc() {
        engine.leaveChannel()
        ChatRoomControl.leaveChatRoom()
    }

    /**
     * enter a room
     */
    override fun enterRoom(roomId: String, callback: NetRequestCallback<LiveInfo>) {
        isAnchor = false
        roomScope?.launch {
            Request.request({
                LiveRoomRepository.enterRoom(roomId)
            }, success = {
                engine.enableLocalVideo(true)
                liveInfo = it
                it?.let { joinChatRoom(it, callback) }
            }, error = { code: Int, msg: String ->
                callback.error(code, msg)
            })
        }
    }

    /**
     * leave a room
     */
    override fun leaveRoom(callback: NetRequestCallback<Unit>) {
        ChatRoomControl.leaveChatRoom()
    }

    /**
     * update push stream task
     */
    override fun updateLiveStream(liveRecoder: LiveStreamTaskRecorder,callback: NetRequestCallback<Int>?): Int {
        val task = LiveStream.getStreamTask(liveRecoder)
        task.layout = when (liveRecoder.type) {
            Constants.LiveType.LIVE_TYPE_DEFAULT -> {
                LiveStream.getSignalAnchorStreamLayout(liveRecoder)
            }
            Constants.LiveType.LIVE_TYPE_PK -> {
                LiveStream.getPkLiveStreamLayout(liveRecoder)
            }
            Constants.LiveType.LIVE_TYPE_SEAT -> {
                LiveStream.getSeatLiveStreamLayout(liveRecoder)
            }
            else -> null
        }
        return LiveStream.updateStreamTask(task,callback)
    }

    /**
     * send a gift to anchor
     */
    override fun reward(giftId: Int, callback: NetRequestCallback<Unit>) {
        if (liveInfo != null) {
            roomScope?.launch {
                Request.request(
                    { LiveRoomRepository.reward(liveInfo!!.live.roomId, giftId) },
                    success = {
                        callback.success()
                    },
                    error = { code: Int, msg: String ->
                        callback.error(code, msg)
                    }
                )
            }
        } else {
            callback.error(Constants.ErrorCode.ROOM_ID_EMPTY, "roomId is empty")
        }
    }

    override fun startChannelMediaRelay(token: String, channelName: String, uid: Long): Boolean {
        //初始化目标房间结构体
        val addRelayConfig = NERtcMediaRelayParam().ChannelMediaRelayConfiguration()
        //设置目标房间1
        val dstInfoA = NERtcMediaRelayParam().ChannelMediaRelayInfo(token, channelName, uid)
        addRelayConfig.setDestChannelInfo(channelName, dstInfoA)
        //开启转发
        val result = NERtcEx.getInstance().startChannelMediaRelay(addRelayConfig)
        return if (result == NERtcConstants.ErrorCode.ENGINE_ERROR_CHANNEL_MEDIARELAY_STATE_INVALID) {
            NERtcEx.getInstance()
                .updateChannelMediaRelay(addRelayConfig) == NERtcConstants.ErrorCode.OK
        } else {
            result == NERtcConstants.ErrorCode.OK
        }
    }

    override fun stopChannelMediaRelay(): Int {
        return NERtcEx.getInstance().stopChannelMediaRelay()
    }

    /**
     * join rtc channel
     */
    override fun joinRtcChannel(token: String, channelName: String, uid: Long) {
        engine.joinChannel(token, channelName, uid)
    }

    /**
     * leave rtc channel
     */
    override fun leaveRtcChannel() {
        engine.leaveChannel()
    }

    /**
     * send text message to chatRoom
     */
    override fun sendTextMessage(msg: String) {
        ChatRoomControl.sendTextMsg(isAnchor, msg)
    }


    /**
     * get audio option
     */
    override fun getAudioOption(): AudioOption {
        return AudioOption
    }

    /**
     * get video option
     */
    override fun getVideoOption(): VideoOption {
        return VideoOption
    }

    override fun addNERTCDelegate(delegate: NERtcCallbackTemp) {
        rtcDelegate=delegate
    }

    override fun queryChatRoomInfo(roomId: String, callback: NetRequestCallback<ChatRoomInfo>) {
        ChatRoomControl.queryChatRoomInfo(roomId, callback)
    }
}