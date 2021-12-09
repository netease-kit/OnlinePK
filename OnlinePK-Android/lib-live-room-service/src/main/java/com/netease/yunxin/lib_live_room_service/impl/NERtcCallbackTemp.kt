/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.impl

import android.graphics.Rect
import com.netease.lava.nertc.sdk.NERtcCallbackEx
import com.netease.lava.nertc.sdk.stats.NERtcAudioVolumeInfo
import com.netease.lava.nertc.sdk.video.NERtcVideoStreamType

interface NERtcCallbackTemp : NERtcCallbackEx {
    override fun onJoinChannel(p0: Int, p1: Long, p2: Long, p3: Long) {

    }

    override fun onLeaveChannel(p0: Int) {

    }

    override fun onUserJoined(p0: Long) {

    }

    override fun onUserLeave(p0: Long, p1: Int) {

    }

    override fun onUserAudioStart(uid: Long) {

    }

    override fun onUserAudioStop(p0: Long) {

    }

    override fun onUserVideoStart(uid: Long, p1: Int) {

    }

    override fun onUserVideoStop(uid: Long) {

    }

    override fun onDisconnect(p0: Int) {

    }

    override fun onClientRoleChange(p0: Int, p1: Int) {

    }

    override fun onUserSubStreamVideoStart(p0: Long, p1: Int) {

    }

    override fun onUserSubStreamVideoStop(p0: Long) {

    }

    override fun onUserAudioMute(p0: Long, p1: Boolean) {

    }

    override fun onUserVideoMute(p0: Long, p1: Boolean) {

    }

    override fun onFirstAudioDataReceived(p0: Long) {

    }

    override fun onFirstVideoDataReceived(p0: Long) {

    }

    override fun onFirstAudioFrameDecoded(p0: Long) {

    }

    override fun onFirstVideoFrameDecoded(p0: Long, p1: Int, p2: Int) {

    }

    override fun onUserVideoProfileUpdate(p0: Long, p1: Int) {

    }

    override fun onAudioDeviceChanged(p0: Int) {

    }

    override fun onAudioDeviceStateChange(p0: Int, p1: Int) {

    }

    override fun onVideoDeviceStageChange(p0: Int) {

    }

    override fun onConnectionTypeChanged(p0: Int) {

    }

    override fun onReconnectingStart() {

    }

    override fun onReJoinChannel(p0: Int, p1: Long) {

    }

    override fun onAudioMixingStateChanged(p0: Int) {

    }

    override fun onAudioMixingTimestampUpdate(p0: Long) {

    }

    override fun onAudioEffectFinished(p0: Int) {

    }

    override fun onLocalAudioVolumeIndication(p0: Int) {

    }

    override fun onRemoteAudioVolumeIndication(p0: Array<out NERtcAudioVolumeInfo>?, p1: Int) {

    }

    override fun onLiveStreamState(p0: String?, p1: String?, p2: Int) {

    }

    override fun onConnectionStateChanged(p0: Int, p1: Int) {

    }

    override fun onCameraFocusChanged(p0: Rect?) {

    }

    override fun onCameraExposureChanged(p0: Rect?) {

    }

    override fun onRecvSEIMsg(p0: Long, p1: String?) {

    }

    override fun onError(p0: Int) {

    }

    override fun onWarning(p0: Int) {

    }

    override fun onAudioRecording(p0: Int, p1: String?) {

    }

    override fun onMediaRelayStatesChange(p0: Int, p1: String?) {

    }

    override fun onMediaRelayReceiveEvent(p0: Int, p1: Int, p2: String?) {

    }

}