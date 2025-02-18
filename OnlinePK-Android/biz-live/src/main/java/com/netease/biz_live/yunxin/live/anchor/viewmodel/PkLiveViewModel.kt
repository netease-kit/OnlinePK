/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.viewmodel

import android.os.CountDownTimer
import android.text.TextUtils
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.netease.biz_live.yunxin.live.anchor.ui.AnchorPkLiveActivity
import com.netease.lava.nertc.sdk.LastmileProbeResult
import com.netease.lava.nertc.sdk.NERtcAsrCaptionResult
import com.netease.lava.nertc.sdk.NERtcUserJoinExtraInfo
import com.netease.lava.nertc.sdk.NERtcUserLeaveExtraInfo
import com.netease.lava.nertc.sdk.audio.NERtcAudioStreamType
import com.netease.lava.nertc.sdk.video.NERtcVideoStreamType
import com.netease.yunxin.lib_live_pk_service.PkService
import com.netease.yunxin.lib_live_pk_service.bean.PkActionMsg
import com.netease.yunxin.lib_live_pk_service.bean.PkEndInfo
import com.netease.yunxin.lib_live_pk_service.bean.PkPunishInfo
import com.netease.yunxin.lib_live_pk_service.bean.PkStartInfo
import com.netease.yunxin.lib_live_pk_service.delegate.PkDelegate
import com.netease.yunxin.lib_live_room_service.LiveRoomService
import com.netease.yunxin.lib_live_room_service.impl.NERtcCallbackTemp
import java.nio.ByteBuffer

/**
 * viewModel for [AnchorPkLiveActivity]
 */
class PkLiveViewModel : ViewModel() {

    companion object {
        const val PK_STATE_IDLE = 0
        const val PK_STATE_REQUEST = 1
        const val PK_STATE_AGREED = 2
        const val PK_STATE_PKING = 3
        const val PK_STATE_PUNISH = 4
    }

    var pkState = 0

    private var inviteTimerTask: PkCountTimeTask? = null

    private var agreeTimerTask: PkCountTimeTask? = null

    var currentPkConfig: PkConfigInfo? = null

    /**
     * the pk request you have received
     */
    val pkActionData = MutableLiveData<PkActionMsg?>()


    val pkStartData = MutableLiveData<PkStartInfo?>()

    val punishData = MutableLiveData<PkPunishInfo?>()

    /**
     * Count down timeOut data
     */
    val countDownTimeOutData = MutableLiveData<Boolean>()

    val pkEndData = MutableLiveData<PkEndInfo?>()
    val pkOtherAnchorJoinedData = MutableLiveData<Long>()
    var otherAnchorUid = 0L

    private val pkDelegate = object : PkDelegate {
        /**
         * anchor received pk request
         */
        override fun onPkRequestReceived(pkActionMsg: PkActionMsg) {
            pkState = PK_STATE_REQUEST
            pkActionData.postValue(pkActionMsg)
        }

        /**
         * anchor's pk request been rejected
         */
        override fun onPkRequestRejected(pkActionMsg: PkActionMsg) {
            pkState = PK_STATE_IDLE
            pkActionData.postValue(pkActionMsg)
        }

        /**
         * pk request have been canceled
         */
        override fun onPkRequestCancel(pkActionMsg: PkActionMsg) {
            pkState = PK_STATE_IDLE
            pkActionData.postValue(pkActionMsg)
        }

        /**
         * pk request have been accepted
         */
        override fun onPkRequestAccept(pkActionMsg: PkActionMsg) {
            pkState = PK_STATE_AGREED
            pkActionData.postValue(pkActionMsg)
        }

        /**
         * pk request time out
         */
        override fun onPkRequestTimeout(pkActionMsg: PkActionMsg) {
            pkState = PK_STATE_IDLE
            currentPkConfig = null
            pkActionData.postValue(pkActionMsg)
        }

        /**
         * pk state changed,pk start
         */
        override fun onPkStart(startInfo: PkStartInfo) {
            pkState = PK_STATE_PKING
            pkStartData.postValue(startInfo)
        }

        /**
         * pk state changed,punish start
         */
        override fun onPunishStart(punishInfo: PkPunishInfo) {
            pkState = PK_STATE_PUNISH
            punishData.postValue(punishInfo)
        }

        /**
         * pk state changed,pk end
         */
        override fun onPkEnd(endInfo: PkEndInfo) {
            pkState = PK_STATE_IDLE
            currentPkConfig = null
            pkEndData.postValue(endInfo)
        }

    }

    /**
     * Stat invite count timer
     *
     * @param leftTime second
     */
    fun startInviteCountTimer(leftTime: Int?, newPkId: String?) {
        leftTime?.let {
            inviteTimerTask?.cancel()
            inviteTimerTask = object : PkCountTimeTask(newPkId, it * 1000L) {
                /**
                 * Callback fired on regular interval.
                 * @param millisUntilFinished The amount of time until finished.
                 */
                override fun onTick(millisUntilFinished: Long) {
                    currentPkConfig?.let { config ->
                        if (pkState != PK_STATE_REQUEST && TextUtils.equals(pkId, config.pkId)) {
                            cancel()
                        }
                    }
                }

                /**
                 * Callback fired when the time is up.
                 */
                override fun onFinish() {
                    currentPkConfig?.let { config ->
                        if (pkState == PK_STATE_REQUEST && TextUtils.equals(pkId, config.pkId)) {
                            pkState = PK_STATE_IDLE
                            countDownTimeOutData.postValue(true)
                        }
                    }
                }
            }
            inviteTimerTask?.start()
        }
    }

    /**
     * Start agree count timer
     *
     * @param leftTime second
     */
    fun startAgreeCountTimer(leftTime: Int?, newPkId: String?) {
        inviteTimerTask?.let {
            if (TextUtils.equals(it.pkId, newPkId)) {
                it.cancel()
            }
        }
        leftTime?.let {
            agreeTimerTask?.cancel()
            agreeTimerTask = object : PkCountTimeTask(newPkId, it * 1000L) {
                /**
                 * Callback fired on regular interval.
                 * @param millisUntilFinished The amount of time until finished.
                 */
                override fun onTick(millisUntilFinished: Long) {
                    currentPkConfig?.let { config ->
                        if (pkState != PK_STATE_AGREED && TextUtils.equals(pkId, config.pkId)) {
                            cancel()
                        }
                    }

                }

                /**
                 * Callback fired when the time is up.
                 */
                override fun onFinish() {
                    currentPkConfig?.let { config ->
                        if (pkState == PK_STATE_AGREED && TextUtils.equals(pkId, config.pkId)) {
                            pkState = PK_STATE_IDLE
                            countDownTimeOutData.postValue(true)
                        }
                    }
                }
            }
            agreeTimerTask?.start()
        }
    }

    override fun onCleared() {
        super.onCleared()
        inviteTimerTask?.cancel()
        agreeTimerTask?.cancel()
        inviteTimerTask = null
        agreeTimerTask = null
    }

    private val roomRTCCallback: NERtcCallbackTemp = object : NERtcCallbackTemp {
        override fun onUserJoined(uid: Long) {
            otherAnchorUid = uid
            pkOtherAnchorJoinedData.postValue(otherAnchorUid)
        }

        override fun onUserJoined(uid: Long, joinExtraInfo: NERtcUserJoinExtraInfo?) {
        }

        override fun onUserLeave(uid: Long, reason: Int, leaveExtraInfo: NERtcUserLeaveExtraInfo?) {
        }

        override fun onUserVideoStart(
            uid: Long,
            streamType: NERtcVideoStreamType?,
            maxProfile: Int
        ) {
        }

        override fun onUserVideoStop(uid: Long, streamType: NERtcVideoStreamType?) {
        }

        override fun onUserVideoMute(streamType: NERtcVideoStreamType?, uid: Long, muted: Boolean) {
        }

        override fun onFirstVideoDataReceived(streamType: NERtcVideoStreamType?, uid: Long) {
        }

        override fun onFirstVideoFrameDecoded(
            streamType: NERtcVideoStreamType?,
            userID: Long,
            width: Int,
            height: Int
        ) {
        }

        override fun onLocalAudioVolumeIndication(volume: Int, vadFlag: Boolean) {
        }

        override fun onLocalAudioFirstPacketSent(audioStreamType: NERtcAudioStreamType?) {
        }

        override fun onFirstVideoFrameRender(
            userID: Long,
            streamType: NERtcVideoStreamType?,
            width: Int,
            height: Int,
            elapsedTime: Long
        ) {
        }

        override fun onAudioEffectTimestampUpdate(id: Long, timestampMs: Long) {
        }

        override fun onApiCallExecuted(apiName: String?, result: Int, message: String?) {
        }

        override fun onAsrCaptionStateChanged(asrState: Int, code: Int, message: String?) {
        }

        override fun onAsrCaptionResult(
            result: Array<out NERtcAsrCaptionResult>?,
            resultCount: Int
        ) {
        }

        override fun onLocalPublishFallbackToAudioOnly(
            isFallback: Boolean,
            streamType: NERtcVideoStreamType?
        ) {
        }

        override fun onRemoteSubscribeFallbackToAudioOnly(
            uid: Long,
            isFallback: Boolean,
            streamType: NERtcVideoStreamType?
        ) {
        }

        override fun onLastmileQuality(quality: Int) {
        }

        override fun onLastmileProbeResult(result: LastmileProbeResult?) {
        }

        override fun onMediaRightChange(
            isAudioBannedByServer: Boolean,
            isVideoBannedByServer: Boolean
        ) {
        }

        override fun onRemoteVideoSizeChanged(
            userId: Long,
            videoType: NERtcVideoStreamType?,
            width: Int,
            height: Int
        ) {
        }

        override fun onLocalVideoRenderSizeChanged(
            videoType: NERtcVideoStreamType?,
            width: Int,
            height: Int
        ) {
        }

        override fun onVirtualBackgroundSourceEnabled(enabled: Boolean, reason: Int) {
        }

        override fun onUserSubStreamAudioStart(uid: Long) {
        }

        override fun onUserSubStreamAudioStop(uid: Long) {
        }

        override fun onUserSubStreamAudioMute(uid: Long, muted: Boolean) {
        }

        override fun onPermissionKeyWillExpire() {
        }

        override fun onUpdatePermissionKey(key: String?, error: Int, timeout: Int) {
        }

        override fun onLocalVideoWatermarkState(
            videoStreamType: NERtcVideoStreamType?,
            state: Int
        ) {
        }

        override fun onUserDataStart(uid: Long) {
        }

        override fun onUserDataStop(uid: Long) {
        }

        override fun onUserDataReceiveMessage(
            uid: Long,
            bufferData: ByteBuffer?,
            bufferSize: Long
        ) {
        }

        override fun onUserDataStateChanged(uid: Long) {
        }

        override fun onUserDataBufferedAmountChanged(uid: Long, previousAmount: Long) {
        }

        override fun onLabFeatureCallback(key: String?, param: Any?) {
        }
    }

    fun init() {
        LiveRoomService.sharedInstance().addNERTCDelegate(roomRTCCallback)
        PkService.shareInstance().setDelegate(pkDelegate)
        pkActionData.value = null
        pkEndData.value = null
        pkStartData.value = null
        punishData.value = null
        pkOtherAnchorJoinedData.value = null
    }

    abstract class PkCountTimeTask(
        val pkId: String?,
        val millisInFuture: Long,
        val countDownInterval: Long = COUNT_DOWN_INTERVAL
    ) :
        CountDownTimer(millisInFuture, countDownInterval) {

        companion object {
            const val COUNT_DOWN_INTERVAL = 1000L
        }

    }

    data class PkConfigInfo(
        val pkId: String?,
        val agreeTaskTime: Int?,
        val inviteTaskTime: Int?
    )
}