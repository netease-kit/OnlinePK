/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.impl

import android.graphics.Rect
import com.netease.lava.nertc.sdk.NERtcCallbackEx
import com.netease.lava.nertc.sdk.stats.NERtcAudioVolumeInfo

interface NERtcCallbackTemp : NERtcCallbackEx {
    override fun onJoinChannel(p0: Int, p1: Long, p2: Long) {
        //TODO("Not yet implemented")
    }

    override fun onLeaveChannel(p0: Int) {
        //TODO("Not yet implemented")
    }

    override fun onUserJoined(p0: Long) {
        //TODO("Not yet implemented")
    }

    override fun onUserLeave(p0: Long, p1: Int) {
        //TODO("Not yet implemented")
    }

    override fun onUserAudioStart(uid: Long) {
        //TODO("Not yet implemented")
    }

    override fun onUserAudioStop(p0: Long) {
        //TODO("Not yet implemented")
    }

    override fun onUserVideoStart(uid: Long, p1: Int) {
        //TODO("Not yet implemented")
    }

    override fun onUserVideoStop(uid: Long) {
        //TODO("Not yet implemented")
    }

    override fun onDisconnect(p0: Int) {
        //TODO("Not yet implemented")
    }

    override fun onClientRoleChange(p0: Int, p1: Int) {
        //TODO("Not yet implemented")
    }

    override fun onUserSubStreamVideoStart(p0: Long, p1: Int) {
        //TODO("Not yet implemented")
    }

    override fun onUserSubStreamVideoStop(p0: Long) {
        //TODO("Not yet implemented")
    }

    override fun onUserAudioMute(p0: Long, p1: Boolean) {
        //TODO("Not yet implemented")
    }

    override fun onUserVideoMute(p0: Long, p1: Boolean) {
        //TODO("Not yet implemented")
    }

    override fun onFirstAudioDataReceived(p0: Long) {
        //TODO("Not yet implemented")
    }

    override fun onFirstVideoDataReceived(p0: Long) {
        //TODO("Not yet implemented")
    }

    override fun onFirstAudioFrameDecoded(p0: Long) {
        //TODO("Not yet implemented")
    }

    override fun onFirstVideoFrameDecoded(p0: Long, p1: Int, p2: Int) {
        //TODO("Not yet implemented")
    }

    override fun onUserVideoProfileUpdate(p0: Long, p1: Int) {
        //TODO("Not yet implemented")
    }

    override fun onAudioDeviceChanged(p0: Int) {
        //TODO("Not yet implemented")
    }

    override fun onAudioDeviceStateChange(p0: Int, p1: Int) {
        //TODO("Not yet implemented")
    }

    override fun onVideoDeviceStageChange(p0: Int) {
        //TODO("Not yet implemented")
    }

    override fun onConnectionTypeChanged(p0: Int) {
        //TODO("Not yet implemented")
    }

    override fun onReconnectingStart() {
        //TODO("Not yet implemented")
    }

    override fun onReJoinChannel(p0: Int, p1: Long) {
        //TODO("Not yet implemented")
    }

    override fun onAudioMixingStateChanged(p0: Int) {
        //TODO("Not yet implemented")
    }

    override fun onAudioMixingTimestampUpdate(p0: Long) {
        //TODO("Not yet implemented")
    }

    override fun onAudioEffectFinished(p0: Int) {
        //TODO("Not yet implemented")
    }

    override fun onLocalAudioVolumeIndication(p0: Int) {
        //TODO("Not yet implemented")
    }

    override fun onRemoteAudioVolumeIndication(p0: Array<out NERtcAudioVolumeInfo>?, p1: Int) {
        //TODO("Not yet implemented")
    }

    override fun onLiveStreamState(p0: String?, p1: String?, p2: Int) {
        //TODO("Not yet implemented")
    }

    override fun onConnectionStateChanged(p0: Int, p1: Int) {
        //TODO("Not yet implemented")
    }

    override fun onCameraFocusChanged(p0: Rect?) {
        //TODO("Not yet implemented")
    }

    override fun onCameraExposureChanged(p0: Rect?) {
        //TODO("Not yet implemented")
    }

    override fun onRecvSEIMsg(p0: Long, p1: String?) {
        //TODO("Not yet implemented")
    }

    override fun onError(p0: Int) {
        //TODO("Not yet implemented")
    }

    override fun onWarning(p0: Int) {
        //TODO("Not yet implemented")
    }

    override fun onAudioRecording(p0: Int, p1: String?) {
        //TODO("Not yet implemented")
    }

    override fun onMediaRelayStatesChange(p0: Int, p1: String?) {
        //TODO("Not yet implemented")
    }

    override fun onMediaRelayReceiveEvent(p0: Int, p1: Int, p2: String?) {
        //TODO("Not yet implemented")
    }
}