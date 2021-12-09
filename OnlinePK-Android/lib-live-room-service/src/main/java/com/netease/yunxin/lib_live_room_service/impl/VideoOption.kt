/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.impl

import android.view.View
import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.lava.nertc.sdk.video.NERtcVideoCallback
import com.netease.lava.nertc.sdk.video.NERtcVideoView
import com.netease.yunxin.kit.alog.ALog

object VideoOption {

    private val engine by lazy {
        NERtcEx.getInstance()
    }


    fun setupRemoteVideoCanvas(canvas: NERtcVideoView?, uid: Long, isTop: Boolean): Boolean {
        canvas?.setZOrderMediaOverlay(isTop)
        canvas?.setMirror(true)
        canvas?.visibility = View.VISIBLE
        ALog.i(LiveRoomServiceImpl.LOG_TAG, "setup Remote video canvas uid:$uid")
        return engine.setupRemoteVideoCanvas(canvas, uid) == NERtcConstants.ErrorCode.OK
    }

    fun setupLocalVideoCanvas(canvas: NERtcVideoView?, isTop: Boolean): Boolean {
        canvas?.setZOrderMediaOverlay(isTop)
        canvas?.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_BALANCED)
        return engine.setupLocalVideoCanvas(canvas) == NERtcConstants.ErrorCode.OK
    }

    fun setVideoCallback(callback: NERtcVideoCallback?, needI420: Boolean) {
        engine.setVideoCallback(callback, needI420)
    }

    fun switchCamera(): Boolean {
        return engine.switchCamera() == NERtcConstants.ErrorCode.OK
    }

    fun enableLocalVideo(enable: Boolean): Boolean {
        return engine.enableLocalVideo(enable) == NERtcConstants.ErrorCode.OK
    }

    fun startVideoPreview(): Boolean {
        return engine.startVideoPreview() == NERtcConstants.ErrorCode.OK
    }

    fun stopVideoPreview(): Boolean {
        return engine.stopVideoPreview() == NERtcConstants.ErrorCode.OK
    }

    fun setVoiceBeautifierPreset(beautifierType: Int) {
        NERtcEx.getInstance().setVoiceBeautifierPreset(beautifierType)
    }

    fun setAudioEffectPreset(voiceChangerType: Int) {
        NERtcEx.getInstance().setAudioEffectPreset(voiceChangerType)
    }
}