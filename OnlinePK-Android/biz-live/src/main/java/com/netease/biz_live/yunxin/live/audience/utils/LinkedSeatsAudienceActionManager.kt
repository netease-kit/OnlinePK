/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.utils

import android.annotation.SuppressLint
import android.widget.ImageView
import androidx.fragment.app.FragmentActivity
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.ui.dialog.LinkSeatsStatusDialog
import com.netease.biz_live.yunxin.live.audience.ui.view.DurationStatisticTimer.DurationUtil
import com.netease.biz_live.yunxin.live.ui.BeautyControl
import com.netease.lava.nertc.sdk.video.NERtcVideoView
import com.netease.yunxin.lib_live_room_service.LiveRoomService
import com.netease.yunxin.seatlibrary.Attachment
import com.netease.yunxin.seatlibrary.CompletionCallback
import com.netease.yunxin.seatlibrary.seat.constant.SeatAVState
import com.netease.yunxin.seatlibrary.seat.params.AcceptSeatPickParams
import com.netease.yunxin.seatlibrary.seat.params.ApplySeatParams
import com.netease.yunxin.seatlibrary.seat.params.SeatRequestParams
import com.netease.yunxin.seatlibrary.seat.params.SetSeatAVMuteStateParams
import com.netease.yunxin.seatlibrary.seat.service.SeatService

/**
 * @author sunkeding
 * 连麦中的观众的相关动作管理
 */

@SuppressLint("StaticFieldLeak")
object LinkedSeatsAudienceActionManager {
    private val seatService by lazy {
        SeatService.sharedInstance()
    }

    private val roomService by lazy {
        LiveRoomService.sharedInstance()
    }

    /**
     * 美颜控制
     */
    private var beautyControl: BeautyControl? = null


    @JvmField
    var enableLocalVideo = true
    @JvmField
    var enableLocalAudio = true


    /**
     * 连麦状态弹窗，内部包含美颜，滤镜，挂断，摄像头，麦克风等操作
     */
    private var linkSeatsStatusDialog: LinkSeatsStatusDialog? = null

    fun joinRtcChannel(token: String, channelName: String, uid: Long) {
        roomService.joinRtcChannel(token, channelName, uid)
    }

    /**
     * 举手申请上麦
     */
    fun applySeat(callback: CompletionCallback<String>) {
        val params = ApplySeatParams(null)
        seatService.applySeat(params,callback)
    }

    /**
     * 取消申请上麦
     *
     * @param leaveSeatCallback
     */
    fun cancelSeatApply(
        leaveSeatCallback: CompletionCallback<Void>
    ) {
        val params = SeatRequestParams()
        seatService.cancelSeatApply(params,leaveSeatCallback)
    }

    /**
     * 同意主播的抱麦请求
     *
     * @param callback
     */
    fun acceptSeatPick(callback: CompletionCallback<Void>) {
        val param = AcceptSeatPickParams()
        seatService.acceptSeatPick(param,callback)
    }

    /**
     * 拒绝主播的抱麦请求
     *
     * @param callback
     */
    fun rejectSeatPick( callback: CompletionCallback<Void>) {
        val params =  SeatRequestParams()
        seatService.rejectSeatPick(params,callback)
    }

    /**
     * 设置麦位静音状态
     *
     * @param indexes  序号数组
     * @param state    静音状态
     * @param ext      json扩展
     * @param callback
     */
    fun setSeatAudioMuteState(
        state: Boolean,
        callback: CompletionCallback<Void>
    ) {
        val params = SetSeatAVMuteStateParams(state = if (state) SeatAVState.OPEN else SeatAVState.CLOSE)
        seatService.setSeatAudioMuteState(params,callback)
    }

    /**
     * 设置麦位视频状态
     *
     * @param state    开闭状态
     * @param callback
     */
    fun setSeatVideoMuteState(
        state: Boolean,
        callback: CompletionCallback<Void>
    ) {
        val params = SetSeatAVMuteStateParams(state = if (state) SeatAVState.OPEN else SeatAVState.CLOSE)
        seatService.setSeatVideoMuteState(params,callback)
    }

    /**
     * 离开麦位
     */
    fun leaveSeat( callback: CompletionCallback<Void>) {
        seatService.leaveSeat(Attachment(),callback)
    }

    fun leaveChannel() {
        roomService.leaveRtcChannel()
    }

    /**
     * 打开连麦状态设置弹窗
     *
     */
    fun showLinkSeatsStatusDialog(activity: FragmentActivity) {
        if (linkSeatsStatusDialog == null) {
            linkSeatsStatusDialog = LinkSeatsStatusDialog(activity, this)
        }
        linkSeatsStatusDialog?.show()
    }

    fun refreshLinkSeatDialog(position: Int, openState: Int) {
        if (linkSeatsStatusDialog != null && linkSeatsStatusDialog?.isShowing == true) {
            linkSeatsStatusDialog?.refreshLinkSeatDialog(position, openState)
        }
    }

    fun switchCamera(iv: ImageView?) {
        setSeatVideoMuteState(
            !enableLocalVideo,
            object : CompletionCallback<Void> {
                override fun success(info: Void?) {
                    enableLocalVideo = !enableLocalVideo
                    roomService.getVideoOption().enableLocalVideo(enableLocalVideo)
                    if (enableLocalVideo) {
                        iv?.setImageResource(R.drawable.biz_live_camera)
                    } else {
                        iv?.setImageResource(R.drawable.biz_live_camera_close)
                    }
                }

                override fun error(code: Int, msg: String) {
                    if (enableLocalVideo) {
                        iv?.setImageResource(R.drawable.biz_live_camera)
                    } else {
                        iv?.setImageResource(R.drawable.biz_live_camera_close)
                    }
                }
            })
    }

    fun switchMicrophone(iv: ImageView?) {
        setSeatAudioMuteState(
            !enableLocalAudio,
            object : CompletionCallback<Void> {
                override fun success(info: Void?) {
                    enableLocalAudio = !enableLocalAudio
                    roomService.getAudioOption().muteLocalAudio(!enableLocalAudio)
                    if (enableLocalAudio) {
                        iv?.setImageResource(R.drawable.biz_live_microphone)
                    } else {
                        iv?.setImageResource(R.drawable.biz_live_microphone_close)
                    }
                }

                override fun error(code: Int, msg: String) {
                    if (enableLocalAudio) {
                        iv?.setImageResource(R.drawable.biz_live_microphone)
                    } else {
                        iv?.setImageResource(R.drawable.biz_live_microphone_close)
                    }
                }
            })
    }

    fun setupRemoteView(neRtcVideoView: NERtcVideoView?, uid: Long) {
        roomService.getVideoOption().setupRemoteVideoCanvas(neRtcVideoView,uid,false)
    }

    /**
     * 打开美颜设置弹窗
     */
    fun showBeautySettingDialog(activity: FragmentActivity) {
        if (beautyControl == null) {
            beautyControl = BeautyControl(activity)
            beautyControl?.initFaceUI()
            beautyControl?.openBeauty()
        }
        beautyControl?.showBeautyDialog()
        if (linkSeatsStatusDialog?.isShowing == true) {
            linkSeatsStatusDialog?.dismiss()
        }
    }

    /**
     * 打开滤镜设置弹窗
     */
    fun showFilterSettingDialog(activity: FragmentActivity) {
        if (beautyControl == null) {
            beautyControl = BeautyControl(activity)
            beautyControl?.initFaceUI()
            beautyControl?.openBeauty()
        }
        beautyControl?.showFilterDialog()
        if (linkSeatsStatusDialog?.isShowing == true) {
            linkSeatsStatusDialog?.dismiss()
        }
    }

    /**
     * 销毁资源,会在 [com.netease.biz_live.yunxin.live.audience.ui.LiveAudienceActivity.finish]触发
     */
    fun onDestory() {
        if (linkSeatsStatusDialog != null) {
            if (linkSeatsStatusDialog?.isShowing == true) {
                linkSeatsStatusDialog?.dismiss()
            }
            linkSeatsStatusDialog = null
        }
        // 销毁美颜、滤镜相关资源
        if (beautyControl != null) {
            beautyControl?.onDestroy()
            beautyControl = null
        }
        DurationUtil.reset()
        enableLocalVideo = true
        enableLocalAudio = true
    }

    fun dismissAllDialog() {
        if (linkSeatsStatusDialog != null) {
            if (linkSeatsStatusDialog?.isShowing == true) {
                linkSeatsStatusDialog?.dismiss()
            }
        }
        // 销毁美颜、滤镜相关资源
        beautyControl?.dismissAllDialog()

    }

    fun enableVideo(open: Boolean) {
        roomService.getVideoOption().enableLocalVideo(open)
    }

    fun enableAudio(oepn: Boolean) {
        roomService.getAudioOption().muteLocalAudio(!oepn)
    }

    fun destoryInstance() {
        if (linkSeatsStatusDialog != null) {
            linkSeatsStatusDialog = null
        }
        if (beautyControl != null) {
            beautyControl = null
        }
        enableLocalVideo = true
        enableLocalAudio = true
    }
}