/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.lib_live_room_service.impl

import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioEffectOption
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioMixingOption

/**
 *
 */
object AudioOption {

    private val engine: NERtcEx by lazy { NERtcEx.getInstance() }

    //audio device for enable earBack
    var audioDevice: Int = 0

    fun enableLocalAudio(enable: Boolean): Boolean {
        return engine.enableLocalAudio(enable) == NERtcConstants.ErrorCode.OK
    }

    fun muteLocalAudio(mute: Boolean): Boolean {
        return engine.muteLocalAudioStream(mute) == NERtcConstants.ErrorCode.OK
    }

    fun setAudioCaptureVolume(volume: Int) {
        engine.adjustRecordingSignalVolume(volume)
    }

    /**
     * pair first:enableEarBack success
     * pair second：have connect headset
     */
    fun enableEarBack(enable: Boolean, volume: Int): Pair<Boolean, Boolean> {
        return if (audioDevice == NERtcConstants.AudioDevice.BLUETOOTH_HEADSET ||
            audioDevice == NERtcConstants.AudioDevice.WIRED_HEADSET
        ) {
            Pair(
                engine.enableEarback(enable, volume) == NERtcConstants.ErrorCode.OK,
                true
            )
        } else Pair(false, second = false)
    }


    fun startAudioMixing(option: NERtcCreateAudioMixingOption): Boolean {
        return engine.startAudioMixing(option) == NERtcConstants.ErrorCode.OK
    }


    fun playEffect(id: Int, option: NERtcCreateAudioEffectOption): Boolean {
        return engine.playEffect(id, option) == NERtcConstants.ErrorCode.OK
    }


    fun stopAudioMixing(): Boolean {
        return engine.stopAudioMixing() == NERtcConstants.ErrorCode.OK
    }


    fun stopEffect(id: Int): Boolean {
        return engine.stopEffect(id) == NERtcConstants.ErrorCode.OK
    }


    fun setAudioMixingSendVolume(volume: Int): Boolean {
        return engine.setAudioMixingSendVolume(volume) == NERtcConstants.ErrorCode.OK
    }

    fun setAudioMixingPlaybackVolume(volume: Int): Boolean {
        return engine.setAudioMixingPlaybackVolume(volume) == NERtcConstants.ErrorCode.OK
    }

    fun setEffectSendVolume(id: Int, volume: Int): Boolean {
        return engine.setEffectSendVolume(id, volume) == NERtcConstants.ErrorCode.OK
    }

    fun setEffectPlaybackVolume(id: Int, volume: Int): Boolean {
        return engine.setEffectPlaybackVolume(id, volume) == NERtcConstants.ErrorCode.OK
    }

    fun stopAllEffects(): Boolean {
        return engine.stopAllEffects() == NERtcConstants.ErrorCode.OK
    }

    fun muteRemoteUserAudio(uid: Long, mute: Boolean): Boolean {
        return if (mute) {
            engine.adjustUserPlaybackSignalVolume(uid, 0) == NERtcConstants.ErrorCode.OK
        } else {
            engine.adjustUserPlaybackSignalVolume(uid, 100) == NERtcConstants.ErrorCode.OK
        }
    }
}