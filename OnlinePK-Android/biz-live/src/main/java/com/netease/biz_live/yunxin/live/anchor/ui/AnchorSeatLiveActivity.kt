/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.anchor.ui

import android.content.Context
import android.content.Intent
import android.hardware.Camera
import android.os.Bundle
import android.view.View
import androidx.lifecycle.ViewModelProvider
import com.blankj.utilcode.util.NetworkUtils
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.R
import com.netease.biz_live.databinding.SeatLiveAnchorLayoutBinding
import com.netease.biz_live.yunxin.live.anchor.dialog.AudienceConnectDialog
import com.netease.biz_live.yunxin.live.anchor.viewmodel.LiveBaseViewModel
import com.netease.biz_live.yunxin.live.anchor.viewmodel.SeatViewModel
import com.netease.biz_live.yunxin.live.chatroom.ChatRoomMsgCreator
import com.netease.biz_live.yunxin.live.model.SeatMemberInfo
import com.netease.biz_live.yunxin.live.ui.widget.LinkSeatsAudienceRecycleView
import com.netease.biz_live.yunxin.live.utils.ClickUtils
import com.netease.lava.nertc.sdk.video.NERtcEncodeConfig
import com.netease.yunxin.android.lib.network.common.NetworkClient
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.Constants
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.lib_live_room_service.param.CreateRoomParam
import com.netease.yunxin.lib_live_room_service.param.LiveStreamTaskRecorder
import com.netease.yunxin.lib_network_kt.NetRequestCallback
import com.netease.yunxin.nertc.demo.basic.BuildConfig
import com.netease.yunxin.seatlibrary.CompletionCallback
import com.netease.yunxin.seatlibrary.seat.SeatOptions
import com.netease.yunxin.seatlibrary.seat.event.AvRoomUser
import com.netease.yunxin.seatlibrary.seat.model.SeatInfo
import com.netease.yunxin.seatlibrary.seat.service.SeatService
import com.netease.yunxin.seatlibrary.seat.state.SeatState
import java.util.*

class AnchorSeatLiveActivity : AnchorBaseLiveActivity() {

    companion object{
        @JvmStatic
        fun startActivity(context: Context){
            context.startActivity(Intent(context, AnchorSeatLiveActivity::class.java))
        }
    }

    val seatService by lazy { SeatService.sharedInstance() }

    private var streamTask: LiveStreamTaskRecorder? = null

    private val seatViewModel by lazy {
        ViewModelProvider(
            this,
            ViewModelProvider.NewInstanceFactory()
        ).get(SeatViewModel::class.java)
    }

    private val seatViewBinding by lazy {
        SeatLiveAnchorLayoutBinding.inflate(layoutInflater, baseViewBinding.flyContainer, true)
    }

    override fun initContainer() {
        seatViewBinding.audienceSeatsView.setUseScene(LinkSeatsAudienceRecycleView.UseScene.ANCHOR)
    }

    override fun setListener() {
        super.setListener()
        baseViewBinding.ivConnect.visibility = View.VISIBLE
        baseViewBinding.ivConnect.setOnClickListener { showConnectDialog() }
    }

    /**
     * create a live room
     */
    override fun createLiveRoom(
        width: Int,
        height: Int,
        frameRate: NERtcEncodeConfig.NERtcVideoFrameRate,
        audioScenario: Int
    ) {
        val createRoomParam = CreateRoomParam(
            baseViewBinding.previewAnchor.getTopic(),
            baseViewBinding.previewAnchor.getLiveCoverPic(),
            Constants.LiveType.LIVE_TYPE_SEAT,
            width, height, frameRate, audioScenario,
            cameraFacing == Camera.CameraInfo.CAMERA_FACING_FRONT
        )
        roomService.createRoom(createRoomParam, callback = object : NetRequestCallback<LiveInfo> {
            override fun success(info: LiveInfo?) {
                info?.let {
                    liveInfo = it
                    val options = SeatOptions(
                        BuildConfig.BASE_URL,
                        BuildConfig.APP_KEY,
                        NetworkClient.getInstance().accessToken,
                        it.anchor.accountId,
                        it.live.roomId,
                        false
                    )
                    seatService.setupWithOptions(this@AnchorSeatLiveActivity, options)
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

    override fun onNetworkConnected(networkType: NetworkUtils.NetworkType?) {
        super.onNetworkConnected(networkType)
        liveInfo?.let {
            seatService.seatInfos(object : CompletionCallback<List<SeatInfo>> {
                override fun success(info: List<SeatInfo>?) {
                    val tempMembers: MutableList<SeatMemberInfo> =
                        ArrayList(seatViewBinding.audienceSeatsView.getMemberList())

                    info?.let { it1 ->
                        val onSeatMember: List<SeatInfo> = it1.filter {
                            it.status == SeatState.SEAT_SATE_ON_SEAT
                        }

                        if (onSeatMember.isNotEmpty()) {
                            //已经不再麦位的观众下麦
                            for (member in tempMembers) {
                                if (!onSeatMember.contains(member.seatInfo)) {
                                    onUserExitSeat(member, false)
                                }
                            }

                            //现有麦位上的观众上麦
                            val uids: MutableList<Long> = ArrayList()
                            for (member in onSeatMember) {
                                if (seatViewBinding.audienceSeatsView.contains(member.accountId) == false) {
                                    onUserEnterSeat(
                                        SeatMemberInfo(
                                            member,
                                            AvRoomUser("", member.avRoomUid, "", null)
                                        ), false
                                    )
                                }
                                uids.add(member.avRoomUid)
                            }
                            //更新推流信息
                            streamTask?.let {
                                it.type = Constants.LiveType.LIVE_TYPE_SEAT
                                it.audienceUid.clear()
                                it.audienceUid.addAll(uids)
                                roomService.updateLiveStream(it)
                            }
                        } else {
                            //观众全部下麦
                            for (member in tempMembers) {
                                onUserExitSeat(member, false)
                            }
                            streamTask?.let {
                                it.type = Constants.LiveType.LIVE_TYPE_DEFAULT
                                it.audienceUid.clear()
                                roomService.updateLiveStream(it)
                            }
                        }
                    }

                }

                override fun error(code: Int, msg: String) {
                    ToastUtils.showLong(msg)
                }

            })
        }
    }

    override fun onRoomLiveStart() {
        super.onRoomLiveStart()
        seatViewModel.init()
        observeSeatData()
        liveInfo?.let {
            streamTask = LiveStreamTaskRecorder(it.live.liveConfig.pushUrl, it.anchor.roomUid!!)
        }
    }

    /**
     * 展示连麦dialog
     */
    private fun showConnectDialog() {
        if (ClickUtils.isFastClick()) {
            return
        }
        baseViewBinding.viewRedPoint.visibility = View.GONE
        seatViewBinding.viewAction.hide()
        val audienceConnectDialog = AudienceConnectDialog()
        val bundle = Bundle()
        bundle.putString(AudienceConnectDialog.ROOM_ID, liveInfo?.live?.roomId)
        audienceConnectDialog.arguments = bundle
        audienceConnectDialog.show(supportFragmentManager, "audienceConnectDialog")
    }

    private fun observeSeatData() {
        seatViewModel.applyUserData.observe(this, {
            showAudienceApply()
            baseViewBinding.viewRedPoint.visibility = View.VISIBLE
        })

        seatViewModel.pickRejectData.observe(this, {
            ToastUtils.showLong(R.string.biz_live_audience_reject_link_seats_invited)
        })

        seatViewModel.seatUserData.observe(this, {
            if (it.first) {
                onUserEnterSeat(it.second)
            } else {
                onUserExitSeat(it.second)
            }
        })

        seatViewModel.avMuteSeatData.observe(this, {
            onSeatAvStateChange(it)
        })
    }

    private fun onSeatAvStateChange(member: SeatMemberInfo) {
        seatViewBinding.audienceSeatsView.updateItem(member)
    }

    /**
     * 用户上麦
     *
     * @param member
     */
    private fun onUserEnterSeat(member: SeatMemberInfo, updateStream: Boolean = true) {
        seatViewBinding.audienceSeatsView.appendItem(member)
        baseViewBinding.crvMsgList.appendItem(ChatRoomMsgCreator.createSeatEnter(member.seatInfo.nickName))
        if (updateStream) {
            streamTask?.let {
                it.type = Constants.LiveType.LIVE_TYPE_SEAT
                it.addAudienceUid(member.avRoomUser!!.avRoomUid)
                roomService.updateLiveStream(it)
            }
        }
    }

    /**
     * 用户离开麦位
     *
     * @param member
     */
    private fun onUserExitSeat(member: SeatMemberInfo, updateStream: Boolean = true) {
        seatViewBinding.audienceSeatsView.remove(member)
        baseViewBinding.crvMsgList.appendItem(ChatRoomMsgCreator.createSeatExit(member.seatInfo.nickName))
        if (updateStream) {
            streamTask?.let {
                it.removeAudienceUid(member.avRoomUser!!.avRoomUid)
                if (it.audienceUid.size <= 0) {
                    it.type = Constants.LiveType.LIVE_TYPE_DEFAULT
                } else {
                    it.type = Constants.LiveType.LIVE_TYPE_SEAT
                }
                roomService.updateLiveStream(it)
            }
        }
    }

    private fun showAudienceApply() {
        if (!seatViewBinding.viewAction.isShowing()) {
            seatViewBinding.viewAction.setText(getString(R.string.biz_live_accept_new_pick_seat))
                ?.setBlackButton(true, getString(R.string.biz_live_ignore)) { }
                ?.setColorButton(getString(R.string.biz_live_click_see)) { showConnectDialog() }
                ?.show()
        }
    }
}