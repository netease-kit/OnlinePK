/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.ui

import android.content.Context
import android.content.Intent
import android.hardware.Camera
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import androidx.lifecycle.ViewModelProvider
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.R
import com.netease.biz_live.databinding.PkLiveAnchorLayoutBinding
import com.netease.biz_live.yunxin.live.anchor.dialog.AnchorListDialog
import com.netease.biz_live.yunxin.live.anchor.viewmodel.LiveBaseViewModel
import com.netease.biz_live.yunxin.live.anchor.viewmodel.PkLiveViewModel
import com.netease.biz_live.yunxin.live.constant.LiveTimeDef
import com.netease.biz_live.yunxin.live.dialog.ChoiceDialog
import com.netease.biz_live.yunxin.live.ui.widget.PKControlView
import com.netease.biz_live.yunxin.live.ui.widget.PKVideoView
import com.netease.lava.nertc.sdk.video.NERtcEncodeConfig
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_pk_service.Constants.PkAction
import com.netease.yunxin.lib_live_pk_service.PkService
import com.netease.yunxin.lib_live_pk_service.bean.*
import com.netease.yunxin.lib_live_room_service.Constants
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.lib_live_room_service.bean.reward.AnchorRewardInfo
import com.netease.yunxin.lib_live_room_service.chatroom.RewardMsg
import com.netease.yunxin.lib_live_room_service.param.CreateRoomParam
import com.netease.yunxin.lib_live_room_service.param.LiveStreamTaskRecorder
import com.netease.yunxin.lib_network_kt.NetRequestCallback

class AnchorPkLiveActivity : AnchorBaseLiveActivity() {

    companion object {
        const val LOG_TAG = "AnchorPkLiveActivity"

        const val ANCHOR_LIST_DIALOG_TAG = "anchorListDialog"

        const val PK_STATE_IDLE = 0
        const val PK_STATE_REQUEST = 1
        const val PK_STATE_PKING = 2
        const val PK_STATE_PUNISH = 3

        @JvmStatic
        fun startActivity(context:Context){
            context.startActivity(Intent(context, AnchorPkLiveActivity::class.java))
        }
    }

    private val pkViewModel by lazy {
        ViewModelProvider(
            this,
            ViewModelProvider.NewInstanceFactory()
        ).get(PkLiveViewModel::class.java)
    }

    val pkService by lazy { PkService.shareInstance() }

    val pkViewBind by lazy {
        PkLiveAnchorLayoutBinding.inflate(layoutInflater, baseViewBinding.flyContainer, true)
    }

    private var pkVideoView: PKVideoView? = null
    private var countDownTimer: PKControlView.WrapperCountDownTimer? = null

    private var pkRequestDialog: ChoiceDialog? = null
    private var pkInviteedDialog: ChoiceDialog? = null
    private var stopPkDialog: ChoiceDialog? = null
    private var anchorListDialog: AnchorListDialog? = null

    private var selfStopPk = false

    private var otherAnchor: PkUserInfo? = null

    private var pkState = 0

    override fun initContainer() {
    }

    override fun setListener() {
        super.setListener()
        pkViewBind.ivRequestPk.setOnClickListener {
            when (pkState) {
                PK_STATE_IDLE -> {
                    showAnchorListDialog()
                }
                PK_STATE_PKING, PK_STATE_PUNISH -> {
                    showStopPkDialog()
                }
                else -> {
                    ToastUtils.showShort(R.string.biz_live_is_pking_please_try_again_later)
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pkViewBind.pkControlView.getVideoContainer()?.removeAllViews()
    }

    override fun initView() {
        super.initView()
        baseViewBinding.rlyConnect.visibility = View.GONE
    }

    override fun onRoomLiveStart() {
        super.onRoomLiveStart()
        pkViewModel.init()
        observePkData()
    }

    /**
     * 展示主播列表供选择
     */
    private fun showAnchorListDialog() {
        if (anchorListDialog != null && anchorListDialog!!.isVisible) {
            return
        }
        if (anchorListDialog == null) {
            anchorListDialog = AnchorListDialog()
        }
        anchorListDialog!!.setSelectAnchorListener(object : AnchorListDialog.SelectAnchorListener {
            override fun onAnchorSelect(liveInfo: LiveInfo) {
                //show pk confirm dialog
                if (pkRequestDialog == null) {
                    pkRequestDialog = ChoiceDialog(this@AnchorPkLiveActivity)
                        .setTitle(getString(R.string.biz_live_invite_pk))
                        .setNegative(getString(R.string.biz_live_cancel), null)
                    pkRequestDialog?.setCancelable(false)
                }
                pkRequestDialog?.setContent(
                    getString(R.string.biz_live_sure_invite) + "“" + liveInfo.anchor.nickname + "”" + getString(
                        R.string.biz_live_for_pk
                    )
                )
                    ?.setPositive(getString(R.string.biz_live_determine)) {
                        requestPk(liveInfo.anchor.accountId, liveInfo.anchor.nickname)
                    }
                if (pkRequestDialog?.isShowing == false) {
                    pkRequestDialog?.show()
                }
            }

        })
        if (anchorListDialog?.isAdded == false) {
            anchorListDialog?.show(supportFragmentManager, ANCHOR_LIST_DIALOG_TAG)
        } else {
            anchorListDialog?.dismiss()
        }
    }

    private var isInvite: Boolean = false

    /**
     * create a live room
     */
    override fun createLiveRoom(
        videoProfile: Int,
        frameRate: NERtcEncodeConfig.NERtcVideoFrameRate,
        audioScenario: Int
    ) {
        val createRoomParam = CreateRoomParam(
            baseViewBinding.previewAnchor.getTopic(),
            baseViewBinding.previewAnchor.getLiveCoverPic(),
            Constants.LiveType.LIVE_TYPE_PK,
            videoProfile, frameRate, audioScenario,
            cameraFacing == Camera.CameraInfo.CAMERA_FACING_FRONT
        )
        roomService.createRoom(createRoomParam, callback = object : NetRequestCallback<LiveInfo> {
            override fun success(info: LiveInfo?) {
                info?.let {
                    liveInfo = it
                    pkService.init(it.live.roomId)
                    onRoomLiveStart()
                }
            }

            override fun error(code: Int, msg: String) {
                ToastUtils.showShort(msg)
                ALog.e(LiveBaseViewModel.LOG_TAG, "createRoom error $msg code:$code")
                finish()
            }

        })
    }

    private fun observePkData() {
        pkViewModel.pkActionData.observe(this, {
            when (it?.action) {
                PkAction.PK_INVITE -> {
                    onReceivedPkRequest(it)
                }
                PkAction.PK_ACCEPT -> {
                    onPkAccept(it)
                }
                PkAction.PK_CANCEL -> {
                    onPkRequestCancel()
                }
                PkAction.PK_REJECT -> {
                    onPkRequestRejected()
                }
                PkAction.PK_TIME_OUT -> {
                    onTimeout()
                }
            }
        })

        pkViewModel.pkStartData.observe(this, {
            onPkStart(it)
        })

        pkViewModel.punishData.observe(this, {
            onPunishStart(it)
        })

        pkViewModel.pkEndData.observe(this, {
            onPkEnd(it)
        })

    }

    override fun clearLocalImage() {
        super.clearLocalImage()
        pkVideoView?.getLocalVideo()?.clearImage()
    }

    fun onReceivedPkRequest(action: PkActionMsg) {
        isInvite = false
        pkState = PK_STATE_REQUEST
        if (pkInviteedDialog == null) {
            pkInviteedDialog = ChoiceDialog(this)
                .setTitle(getString(R.string.biz_live_invite_pk))
            pkInviteedDialog?.setCancelable(false)
        }
        pkInviteedDialog?.setContent("“" + action.actionAnchor.nickname + "”" + getString(R.string.biz_live_invite_you_pk_whether_to_accept))
            ?.setPositive(getString(R.string.biz_live_accept)) {
                acceptPkRequest(
                    action.actionAnchor.channelName,
                    action.targetAnchor.checkSum,
                    action.targetAnchor.roomUid
                )
            }
            ?.setNegative(getString(R.string.biz_live_reject)) {
                rejectPkRequest()
            }
        if (pkInviteedDialog?.isShowing == false) {
            pkInviteedDialog?.show()
        }
        if (anchorListDialog != null && anchorListDialog?.isVisible == true) {
            anchorListDialog?.dismiss()
        }
        if (pkRequestDialog != null && pkRequestDialog!!.isShowing) {
            pkRequestDialog!!.dismiss()
        }
    }

    fun onPkRequestCancel() {
        if (pkInviteedDialog != null && pkInviteedDialog!!.isShowing) {
            pkInviteedDialog?.dismiss()
            pkState = PK_STATE_IDLE
        }
        ToastUtils.showShort(getString(R.string.biz_live_the_other_cancel_invite))
    }

    fun onPkRequestRejected() {
        ToastUtils.showShort(R.string.biz_live_the_other_party_reject_your_accept)
        pkViewBind.viewAction.hide()
        pkState = PK_STATE_IDLE
    }

    fun onPkAccept(action: PkActionMsg) {
        isInvite = true
        pkViewBind.viewAction.hide()
        pkViewBind.llyPkProgress.visibility = View.VISIBLE
        ALog.d(
            LOG_TAG, "startChannelMediaRelay selfChannel: channelName ="
                    + liveInfo?.live?.roomCname + " channelCid = " + liveInfo?.live?.roomCid + " uid = "
                    + liveInfo?.anchor?.roomUid + " other Channel: channelName = " + action.actionAnchor.channelName
                    + " uid = " + action.targetAnchor.roomUid
        )
        roomService.startChannelMediaRelay(
            action.targetAnchor.checkSum,
            action.actionAnchor.channelName, action.targetAnchor.roomUid
        )
    }

    /**
     * 结束PK dialog
     */
    private fun showStopPkDialog() {
        if (stopPkDialog == null) {
            stopPkDialog = ChoiceDialog(this)
            stopPkDialog?.setTitle(getString(R.string.biz_live_end_pk))
            stopPkDialog?.setContent(getString(R.string.biz_live_stop_pk_dialog_content))
            stopPkDialog?.setPositive(
                getString(R.string.biz_live_immediate_end)
            ) {
                stopPk()
            }
            stopPkDialog?.setNegative(getString(R.string.biz_live_cancel), null)
        }
        stopPkDialog?.show()
    }

    fun onPkStart(startInfo: PkStartInfo?) {
        if (startInfo == null) {
            return
        }
        pkViewBind.llyPkProgress.visibility = View.GONE
        ImageLoader.with(this).circleLoad(R.drawable.icon_stop_pk, pkViewBind.ivRequestPk)
        otherAnchor = if (isInvite) startInfo.invitee else startInfo.inviter
        if (pkVideoView == null) {
            pkVideoView = PKVideoView(this)
        }
        pkViewBind.pkControlView.getVideoContainer()?.removeAllViews()
        pkViewBind.pkControlView.getVideoContainer()?.addView(pkVideoView)
        roomService.getVideoOption().setupLocalVideoCanvas(pkVideoView?.getLocalVideo(), false)
        roomService.getVideoOption()
            .setupRemoteVideoCanvas(pkVideoView?.getRemoteVideo(), otherAnchor!!.roomUid, true)
        pkVideoView?.getRemoteVideo()?.setMirror(true)
        baseViewBinding.videoView.visibility = View.GONE
        pkViewBind.pkControlView.visibility = View.VISIBLE
        // pk 控制状态重置
        pkViewBind.pkControlView.reset()

        // 更新对方主播信息
        pkViewBind.pkControlView.updatePkAnchorInfo(otherAnchor!!.nickname, otherAnchor!!.avatar)
        // 开始定时器
        countDownTimer?.stop()
        countDownTimer = pkViewBind.pkControlView.createCountDownTimer(
            LiveTimeDef.TYPE_PK,
            startInfo.pkCountDown * 1000L
        )
        countDownTimer?.start()
        selfStopPk = false
        pkState = PK_STATE_PKING
        //update push live stream
        liveInfo?.let {
            val liveRecoder =
                LiveStreamTaskRecorder(it.live.liveConfig.pushUrl, it.anchor.roomUid!!)
            liveRecoder.type = Constants.LiveType.LIVE_TYPE_PK
            liveRecoder.otherAnchorUid = otherAnchor!!.roomUid
            roomService.updateLiveStream(liveRecoder)
        }

    }

    fun onPunishStart(punishInfo: PkPunishInfo?) {
        if (punishInfo == null) {
            return
        }
        pkState = PK_STATE_PUNISH
        // 发送 pk 结束消息
        val anchorWin: Int = if (punishInfo.inviteeRewards == punishInfo.inviterRewards) {
            0
        } else if (!isInvite) {
            if (punishInfo.inviteeRewards > punishInfo.inviterRewards) 1 else -1
        } else {
            if (punishInfo.inviteeRewards < punishInfo.inviterRewards) 1 else -1
        } // 当前主播是否 pk 成功
        // 展示pk结果
        pkViewBind.pkControlView.handleResultFlag(true, anchorWin)
        // 惩罚开始倒计时
        countDownTimer?.stop()

        if (anchorWin != 0) {
            countDownTimer = pkViewBind.pkControlView.createCountDownTimer(
                LiveTimeDef.TYPE_PUNISHMENT,
                punishInfo.pkPenaltyCountDown * 1000L
            )
            countDownTimer?.start()
        }
    }

    private fun onPkEnd(endInfo: PkEndInfo?) {
        if (endInfo == null) {
            return
        }
        roomService.stopChannelMediaRelay()
        countDownTimer?.stop()
        ImageLoader.with(this).circleLoad(R.drawable.icon_pk, pkViewBind.ivRequestPk)
        pkViewBind.pkControlView.getVideoContainer()?.removeAllViews()
        pkViewBind.pkControlView.visibility = View.GONE
        baseViewBinding.videoView.visibility = View.VISIBLE
        roomService.getVideoOption().setupLocalVideoCanvas(baseViewBinding.videoView, false)
        if (endInfo.reason == 1 && !endInfo.countDownEnd && !selfStopPk) {
            ToastUtils.showShort("“" + otherAnchor?.nickname + getString(R.string.biz_live_end_of_pk))
        }
        if (stopPkDialog?.isShowing == true) {
            stopPkDialog?.dismiss()
        }
        //update push live stream
        liveInfo?.let {
            val liveRecoder =
                LiveStreamTaskRecorder(it.live.liveConfig.pushUrl, it.anchor.roomUid!!)
            liveRecoder.type = Constants.LiveType.LIVE_TYPE_DEFAULT
            liveRecoder.otherAnchorUid = null
            roomService.updateLiveStream(liveRecoder)
        }
        otherAnchor = null
        pkState = PK_STATE_IDLE
    }

    fun onTimeout() {
        if (!isInvite) {
            if (pkInviteedDialog != null && pkInviteedDialog?.isShowing == true) {
                pkInviteedDialog?.dismiss()
                ToastUtils.showShort(R.string.biz_live_pk_request_time_out)
            }
        } else {
            pkViewBind.viewAction.hide()
            ToastUtils.showShort(R.string.biz_live_pk_request_time_out)
        }
        pkViewBind.llyPkProgress.visibility = View.GONE
        pkState = PK_STATE_IDLE
    }

    override fun onUserReward(reward: RewardMsg) {
        if (pkState == PK_STATE_PKING) {
            val selfRewardInfo: AnchorRewardInfo
            val otherAnchor: AnchorRewardInfo

            if (TextUtils.equals(
                    liveInfo?.anchor?.accountId,
                    reward.anchorReward.accountId
                )
            ) {
                selfRewardInfo = reward.anchorReward
                otherAnchor = reward.otherAnchorReward!!
            } else {
                selfRewardInfo = reward.otherAnchorReward!!
                otherAnchor = reward.anchorReward
            }
            pkViewBind.pkControlView.updateScore(
                selfRewardInfo.pkRewardTotal,
                otherAnchor.pkRewardTotal
            )
            pkViewBind.pkControlView.updateRanking(
                selfRewardInfo.pkRewardTop?.toMutableList(),
                otherAnchor.pkRewardTop?.toMutableList()
            )
        }
        super.onUserReward(reward)
    }

    fun requestPk(accId: String, nickname: String) {
        pkService.requestPk(accId, object : NetRequestCallback<Unit> {
            override fun success(info: Unit?) {
                isInvite = true
                pkViewBind.viewAction.setText(
                    getString(R.string.biz_live_invite) + nickname + getString(
                        R.string.biz_live_pk_linking
                    )
                )
                    ?.setColorButton(getString(R.string.biz_live_cancel)) { cancelRequest() }
                    ?.show()
                pkState = PK_STATE_REQUEST
            }

            override fun error(code: Int, msg: String) {
                ToastUtils.showShort(getString(R.string.biz_live_invite_failed) + ":" + msg)
            }

        })
    }

    private fun cancelRequest() {
        pkService.cancelPkRequest(object : NetRequestCallback<Unit> {
            override fun success(info: Unit?) {
                pkViewBind.viewAction.hide()
                pkState = PK_STATE_IDLE
            }

            override fun error(code: Int, msg: String) {
                ToastUtils.showShort(msg)
            }

        })
    }

    private fun rejectPkRequest() {
        pkService.rejectPkRequest(object : NetRequestCallback<Unit> {
            override fun success(info: Unit?) {
                pkViewBind.viewAction.hide()
                pkState = PK_STATE_IDLE
            }

            override fun error(code: Int, msg: String) {
                ToastUtils.showShort(msg)
            }

        })
    }

    private fun acceptPkRequest(cname: String, token: String, uid: Long) {
        pkService.acceptPk(object : NetRequestCallback<Unit> {
            override fun success(info: Unit?) {
                if (pkState == PK_STATE_REQUEST) {
                    pkViewBind.viewAction.hide()
                    pkViewBind.llyPkProgress.visibility = View.VISIBLE
                    roomService.startChannelMediaRelay(token, cname, uid)
                }
            }

            override fun error(code: Int, msg: String) {
                ToastUtils.showShort(msg)
            }

        })
    }

    private fun stopPk() {
        pkService.stopPk(object : NetRequestCallback<Unit> {
            override fun success(info: Unit?) {
                selfStopPk = true
            }

            override fun error(code: Int, msg: String) {
                ToastUtils.showShort(msg)
            }

        })
    }

    override fun onDestroy() {
        super.onDestroy()
        PkService.destroyInstance()
    }

}