/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.view

import android.Manifest
import android.annotation.SuppressLint
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import com.blankj.utilcode.util.NetworkUtils
import com.blankj.utilcode.util.PermissionUtils
import com.blankj.utilcode.util.SizeUtils
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.ui.dialog.LinkSeatsStatusDialog
import com.netease.biz_live.yunxin.live.audience.utils.AccountUtil
import com.netease.biz_live.yunxin.live.audience.utils.AudienceDialogControl
import com.netease.biz_live.yunxin.live.audience.utils.LinkedSeatsAudienceActionManager
import com.netease.biz_live.yunxin.live.chatroom.ChatRoomMsgCreator
import com.netease.biz_live.yunxin.live.model.SeatMemberInfo
import com.netease.biz_live.yunxin.live.ui.widget.LinkSeatsAudienceRecycleView
import com.netease.lava.nertc.sdk.video.NERtcVideoView
import com.netease.yunxin.android.lib.network.common.NetworkClient
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.login.sdk.AuthorManager
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.BuildConfig
import com.netease.yunxin.seatlibrary.CompletionCallback
import com.netease.yunxin.seatlibrary.seat.SeatOptions
import com.netease.yunxin.seatlibrary.seat.constant.Reason
import com.netease.yunxin.seatlibrary.seat.constant.SeatAVState
import com.netease.yunxin.seatlibrary.seat.delegate.SeatDelegate
import com.netease.yunxin.seatlibrary.seat.event.*
import com.netease.yunxin.seatlibrary.seat.model.SeatInfo
import com.netease.yunxin.seatlibrary.seat.params.ApplySeatParams
import com.netease.yunxin.seatlibrary.seat.service.SeatService
import com.netease.yunxin.seatlibrary.seat.state.SeatState
import java.util.*


@SuppressLint("ViewConstructor")
class SeatAudienceContentView(activity: BaseActivity) : BaseAudienceContentView(activity) {

    companion object{
        const val LOG_TAG  = "SeatAudienceContentView"
    }

    val seatService by lazy {
        SeatService.sharedInstance()
    }

    /**
     * 等待主播接受连麦申请的浮层
     */
    private var waitAnchorAcceptFloatLayer: WaitAnchorAcceptView? = null

    /**
     * 弹窗控制
     */
    private var audienceDialogControl: AudienceDialogControl? = null

    /**
     * 观众端连麦管理
     */
    private val linkedSeatsAudienceActionManager by lazy {
        LinkedSeatsAudienceActionManager
    }

    /**
     * 右边的连麦观众列表，如果自己也是连麦观众，需要把自己放首位
     * 有人上麦就添加，有人下麦就移除，默认隐藏，展示RTC画面就把linkSeatsRv显示出来，确保不会因为isLinkingSeats刷新过程中有人上麦导致的UI显示异常问题
     */
    private var linkSeatsRv: LinkSeatsAudienceRecycleView? = null

    /**
     * 是否正在连麦，连麦的话需要展示主播的RTC流，否则的话展示主播的CDN流
     */
    private var isLinkingSeats = false

    /**
     * 当自己是连麦观众时，需要播放主播的RTC流
     */
    var rtcVideoView: NERtcVideoView? = null

    val seatDelegate = object :SeatDelegate{
        /**
         * 收到上麦申请
         */
        override fun onSeatApplyRequest(event: SeatApplyEvent) {
            //audience need no impl
        }

        /**
         * 上麦申请被取消的回调
         */
        override fun onSeatApplyRequestCanceled(event: SeatApplyEvent) {
            //audience need no impl
        }

        /**
         * 收到报麦申请同意
         */
        override fun onSeatPickAccepted(event: SeatPickEvent) {
            //audience need no impl
        }

        /**
         * 收到报麦申请被拒绝
         */
        override fun onSeatPickRejected(event: SeatPickEvent) {
            //audience need no impl
        }

        /**
         * 麦位加入的回调
         */
        override fun onSeatEntered(event: SeatEnterEvent) {
            val member = SeatMemberInfo(event.seatInfo, event.avRoomUser)
            onUserEnterSeat(member, fetchInfo = true, true)
        }

        /**
         * 麦位离开的回调
         */
        override fun onSeatLeft(event: SeatLeaveEvent) {
            ALog.d(LOG_TAG, "onSeatLeft ")
            onUserExitSeat(SeatMemberInfo(event.seatInfo, event.avRoomUser))
        }

        /**
         * 收到报麦申请
         */
        override fun onSeatPickRequest(event: SeatPickRequestEvent) {
            getAudienceDialogControl()?.showAnchorInviteDialog(
                activity,
                object : AudienceDialogControl.JoinSeatsListener {
                    override fun acceptInvite() {
                        ALog.d(LOG_TAG, "acceptInvite")
                        linkedSeatsAudienceActionManager.acceptSeatPick(
                            object : CompletionCallback<Void> {
                                override fun success(info: Void?) {
                                    val permissions = arrayOf<String?>(
                                        Manifest.permission.CAMERA,
                                        Manifest.permission.RECORD_AUDIO
                                    )
                                    PermissionUtils.permission(*permissions)
                                        .callback(object : PermissionUtils.FullCallback {
                                            override fun onGranted(granted: MutableList<String?>) {
                                                joinRtcAndShowRtcUI(event.avRoomUser)
                                            }

                                            override fun onDenied(
                                                deniedForever: MutableList<String?>,
                                                denied: MutableList<String?>
                                            ) {
                                                ToastUtils.showShort(activity.getString(R.string.biz_live_permission_error_tips))
                                                joinRtcAndShowRtcUI(event.avRoomUser)
                                            }
                                        }).request()
                                }

                                override fun error(code: Int, msg: String) {
                                    ALog.d(LOG_TAG, "acceptSeatPick onError:$msg")
                                    ToastUtils.showShort(msg)
                                }
                            })
                    }

                    override fun rejectInvite() {
                        ALog.d(LOG_TAG, "rejectInvite")
                        linkedSeatsAudienceActionManager.rejectSeatPick(
                            object : CompletionCallback<Void> {
                                override fun success(info: Void?) {
                                    ToastUtils.showShort(R.string.biz_live_you_have_success_reject_anchor_invite)
                                }

                                override fun error(code: Int, msg: String) {
                                    ALog.d(LOG_TAG, "rejectSeatPick onError:$msg")
                                    ToastUtils.showShort(msg)
                                }
                            })
                    }
                })
        }

        /**
         * 抱麦申请被取消的回调
         */
        override fun onSeatPickRequestCanceled(event: SeatPickRequestEvent) {
            //audience need no impl
        }

        /**
         * 申请上麦被同意
         */
        override fun onSeatApplyAccepted(event: SeatApplyEvent) {
            ALog.d(LOG_TAG, "onSeatApplyAccepted")
            val permissions =
                arrayOf<String?>(Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO)
            PermissionUtils.permission(*permissions).callback(object :
                PermissionUtils.FullCallback {
                override fun onGranted(granted: MutableList<String?>) {
                    joinRtcAndShowRtcUI(event.avRoomUser!!)
                }

                override fun onDenied(
                    deniedForever: MutableList<String?>,
                    denied: MutableList<String?>
                ) {
                    ToastUtils.showShort(activity.getString(R.string.biz_live_permission_error_tips))
                    joinRtcAndShowRtcUI(event.avRoomUser!!)
                }
            }).request()
        }

        /**
         * 申请上麦被拒绝
         */
        override fun onSeatApplyRejected(event: SeatApplyEvent) {
            ALog.d(LOG_TAG, "onSeatApplyRejected")
            waitAnchorAcceptFloatLayer?.visibility = GONE
            infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_ENABLE)
            getAudienceDialogControl()?.showAnchorRejectDialog(activity)
        }

        /**
         * 麦位声音状态回调
         */
        override fun onSeatAudioMuteStateChanged(event: SeatStateChangeEvent) {
            ALog.d(LOG_TAG, "onSeatAudioMuteStateChanged")
            if (AccountUtil.isCurrentUser(event.seatInfo.accountId) &&
                !AccountUtil.isCurrentUser(event.responder.accountId)
            ) {
                //主播端对连麦观众进行了麦位音视频的操作
                 if (LinkedSeatsAudienceActionManager.enableLocalAudio && event.seatInfo.audioState == SeatAVState.CLOSE) {
                     ToastUtils.showShort(activity.getString(R.string.biz_live_anchor_close_your_microphone))
                     linkedSeatsAudienceActionManager.refreshLinkSeatDialog(
                         LinkSeatsStatusDialog.MICROPHONE_POSITION,
                         event.seatInfo.audioState
                     )
                     linkedSeatsAudienceActionManager.enableAudio(false)
                } else if (!LinkedSeatsAudienceActionManager.enableLocalAudio && event.seatInfo.audioState == SeatAVState.OPEN) {
                     ToastUtils.showShort(activity.getString(R.string.biz_live_anchor_open_your_microphone))
                     linkedSeatsAudienceActionManager.refreshLinkSeatDialog(
                         LinkSeatsStatusDialog.MICROPHONE_POSITION,
                         event.seatInfo.audioState
                     )
                     linkedSeatsAudienceActionManager.enableAudio(true)
                }

                LinkedSeatsAudienceActionManager.enableLocalAudio =
                    event.seatInfo.audioState == SeatAVState.OPEN
            }
            linkSeatsRv?.updateItem(SeatMemberInfo(event.seatInfo,event.avRoomUser))
        }

        /**
         * 麦位视频状态回调
         */
        override fun onSeatVideoMuteStateChanged(event: SeatStateChangeEvent) {
            ALog.d(LOG_TAG, "onSeatVideoMuteStateChanged")
            if (AccountUtil.isCurrentUser(event.seatInfo.accountId) &&
                !AccountUtil.isCurrentUser(event.responder.accountId)
            ) {
                //主播端对连麦观众进行了麦位音视频的操作
                if (LinkedSeatsAudienceActionManager.enableLocalVideo && event.seatInfo.videoState == SeatAVState.CLOSE) {
                    ToastUtils.showShort(activity.getString(R.string.biz_live_anchor_close_your_camera))
                    linkedSeatsAudienceActionManager.refreshLinkSeatDialog(
                        LinkSeatsStatusDialog.CAMERA_POSITION,
                        event.seatInfo.videoState
                    )
                    linkedSeatsAudienceActionManager.enableVideo(false)
                } else if (!LinkedSeatsAudienceActionManager.enableLocalVideo && event.seatInfo.videoState == SeatAVState.OPEN) {
                    ToastUtils.showShort(activity.getString(R.string.biz_live_anchor_open_your_camera))
                    linkedSeatsAudienceActionManager.refreshLinkSeatDialog(
                        LinkSeatsStatusDialog.CAMERA_POSITION,
                        event.seatInfo.videoState
                    )
                    linkedSeatsAudienceActionManager.enableVideo(true)
                }

                LinkedSeatsAudienceActionManager.enableLocalVideo =
                    event.seatInfo.videoState == SeatAVState.OPEN
            }
            linkSeatsRv?.updateItem(SeatMemberInfo(event.seatInfo,event.avRoomUser))
        }

        /**
         * 麦位开关状态回调
         */
        override fun onSeatStateChanged(event: SeatStateChangeEvent) {
            if (event.seatInfo.status == SeatState.SEAT_SATE_IDLE
                && event.reason == Reason.TIME_OUT
            ) {
                //请求超时
                if (waitAnchorAcceptFloatLayer?.isShown == true) {
                    waitAnchorAcceptFloatLayer?.visibility = View.GONE

                    waitAnchorAcceptFloatLayer?.tvCancel?.isEnabled = true
                }
                //邀请超时处理
                getAudienceDialogControl()?.dismissAnchorInviteDialog()

                //连麦按钮重置
                infoBinding.btnMultiFunction.setType(
                    MultiFunctionButton.Type.APPLY_SEAT_ENABLE
                )
            }
        }

        /**
         * 自定义状态变更的回调
         */
        override fun onSeatCustomInfoChanged(event: SeatStateChangeEvent) {
            //not impl here
        }

    }

    private fun getAudienceDialogControl(): AudienceDialogControl? {
        if (audienceDialogControl == null) {
            audienceDialogControl = AudienceDialogControl()
        }
        return audienceDialogControl
    }

    private fun joinRtcAndShowRtcUI(avRoomUser: AvRoomUser) {
        //需要把主播画面的CDN流改为RTC流，右边需要添加小的RTC流
        waitAnchorAcceptFloatLayer?.visibility = GONE
        errorStateView?.visibility = GONE
        try {
            linkedSeatsAudienceActionManager.joinRtcChannel(
                avRoomUser.avRoomCheckSum, avRoomUser.avRoomCName, avRoomUser.avRoomUid
            )
        } catch (e: NumberFormatException) {
            e.printStackTrace()
        }
    }

    private fun showRtcView(member: SeatMemberInfo, fetchSeat: Boolean) {
        //添加自己到连麦控件
        addSelfToLinkSeatsRv(member)
        infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.LINK_SEATS_SETTING)
        // 添加RTC流播放
        if (rtcVideoView == null) {
            rtcVideoView = NERtcVideoView(context)
            addView(rtcVideoView, 0, generateDefaultLayoutParams())
        }
        //设置主播的RTC流画面
        linkedSeatsAudienceActionManager.setupRemoteView(rtcVideoView, audienceViewModel?.data!!.liveInfo!!.anchor.roomUid!!)
        rtcVideoView?.visibility = VISIBLE
        videoView?.visibility = GONE
        linkSeatsRv?.visibility = VISIBLE

        if (fetchSeat) {
            fetchSeatInfo(false)
        }

        getAudienceDialogControl()?.dismissAnchorInviteDialog()
    }

    private fun fetchSeatInfo(showRoomMsg: Boolean) {
        seatService.seatInfos(object : CompletionCallback<List<SeatInfo>> {
            override fun success(info: List<SeatInfo>?) {
                val tempMembers: MutableList<SeatMemberInfo> =
                    ArrayList(linkSeatsRv?.getMemberList())

                info?.let { it1 ->
                    val onSeatMember: List<SeatInfo> = it1.filter {
                        it.status == SeatState.SEAT_SATE_ON_SEAT
                    }

                    if (onSeatMember.isNotEmpty()) {
                        //已经不再麦位的观众下麦
                        for (member in tempMembers) {
                            if (!onSeatMember.contains(member.seatInfo)) {
                                onUserExitSeat(member, showRoomMsg)
                            }
                        }

                        //现有麦位上的观众上麦
                        for (member in onSeatMember) {
                            if (linkSeatsRv?.contains(member.accountId) == false) {
                                onUserEnterSeat(
                                    SeatMemberInfo(
                                        member,
                                        AvRoomUser("", member.avRoomUid, "", null)
                                    ),
                                    fetchInfo = false, showRoomMsg = false
                                )
                            }
                        }
                    } else {
                        for (member in tempMembers) {
                            onUserExitSeat(member, showRoomMsg)
                        }
                    }
                }
            }

            override fun error(code: Int, msg: String) {
                ToastUtils.showLong(msg)
            }

        })
    }

    /**
     * 用户离开麦位
     *
     * @param member
     */
    private fun onUserExitSeat(member: SeatMemberInfo, showRoomMsg: Boolean = true) {
        if (AccountUtil.isCurrentUser(member.seatInfo.accountId)) {
            roomService.leaveRtcChannel()
            showCdnView()
            infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_ENABLE)
            isLinkingSeats = false
            linkedSeatsAudienceActionManager.dismissAllDialog()
        } else {
            linkSeatsRv?.remove(member)
            if (!isLinkingSeats) {
                videoView?.setLinkingSeats(
                    linkSeatsRv?.haveMemberInSeats() == true && linkSeatsRv?.contains(
                        AuthorManager.getUserInfo()!!.accountId
                    ) == false
                )
            }
        }
        if (showRoomMsg) {
            infoBinding.crvMsgList.appendItem(ChatRoomMsgCreator.createSeatExit(member.seatInfo.nickName))
        }
    }

    /**
     * 用户上麦
     *
     * @param member
     */
    private fun onUserEnterSeat(member: SeatMemberInfo, fetchInfo: Boolean, showRoomMsg: Boolean) {
        if (AccountUtil.isCurrentUser(member.seatInfo.accountId)) {
            //设置本次连麦的开始时间戳
            isLinkingSeats = true
            DurationStatisticTimer.DurationUtil.setBeginTimeStamp(System.currentTimeMillis())
            showRtcView(member, fetchInfo)
        } else {
            if (isLinkingSeats) {
                linkSeatsRv?.appendItem(member)
            }
            if (!isLinkingSeats) {
                videoView?.setLinkingSeats(true)
            }
        }
        if (showRoomMsg) {
            infoBinding.crvMsgList.appendItem(ChatRoomMsgCreator.createSeatEnter(member.seatInfo.nickName))
        }

    }

    override fun onNetworkConnected(networkType: NetworkUtils.NetworkType) {
        super.onNetworkConnected(networkType)
        fetchSeatInfo(true)
    }

    private fun addSelfToLinkSeatsRv(member: SeatMemberInfo) {
        member.isSelf = true
        linkSeatsRv?.appendItem(0, member)
    }

    override fun renderData(info: LiveInfo) {
        super.renderData(info)
        linkSeatsRv = LinkSeatsAudienceRecycleView(context)
        linkSeatsRv?.visibility = GONE
        linkSeatsRv?.setUseScene(LinkSeatsAudienceRecycleView.UseScene.AUDIENCE)
        val params = LayoutParams(SizeUtils.dp2px(88f), LayoutParams.WRAP_CONTENT)
        params.topMargin = SizeUtils.dp2px(108f)
        params.rightMargin = SizeUtils.dp2px(6f)
        params.gravity = Gravity.TOP or Gravity.END
        addView(linkSeatsRv, params)
        val params2 = LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, SizeUtils.dp2px(44f))
        params2.topMargin = SizeUtils.dp2px(108f)
        waitAnchorAcceptFloatLayer = WaitAnchorAcceptView(context)
        waitAnchorAcceptFloatLayer?.setCancelApplySeatClickCallback(object :
            WaitAnchorAcceptView.CancelApplySeatClickCallback {
            override fun cancel() {
                infoBinding.btnMultiFunction.setType(
                    MultiFunctionButton.Type.APPLY_SEAT_ENABLE
                )
            }
        })
        addView(waitAnchorAcceptFloatLayer, params2)
        waitAnchorAcceptFloatLayer?.visibility = GONE
        infoBinding.btnMultiFunction.setOnButtonClickListener(object :
            MultiFunctionButton.OnButtonClickListener {
            override fun applySeat() {
                //按钮置灰
                infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_DISABLE)
                seatService.applySeat(ApplySeatParams(null), object : CompletionCallback<String> {
                    override fun success(info: String?) {
                        waitAnchorAcceptFloatLayer?.visibility = VISIBLE
                    }

                    override fun error(code: Int, msg: String) {
                        //按钮重新点亮
                        ToastUtils.showLong(msg)
                        infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_ENABLE)
                    }

                })
            }

            override fun showLinkSeatsStatusDialog() {
                linkedSeatsAudienceActionManager.showLinkSeatsStatusDialog(activity)
            }
        })
    }

    override fun changeErrorState(error: Boolean, type: Int) {
        super.changeErrorState(error, type)
        linkSeatsRv?.visibility = GONE
        waitAnchorAcceptFloatLayer?.visibility = GONE
    }

    override fun showCdnView() {
        super.showCdnView()
        rtcVideoView?.visibility = GONE
        linkSeatsRv?.visibility = GONE
        isLinkingSeats = false
        linkSeatsRv?.clearItems()
    }

    override fun initLiveType(isRetry: Boolean) {
        super.initLiveType(isRetry)
        if (!isRetry) {
            val option = SeatOptions(
                BuildConfig.BASE_URL, BuildConfig.APP_KEY, NetworkClient.getInstance().accessToken,
                AuthorManager.getUserInfo()!!.accountId!!, audienceViewModel?.data!!.liveInfo!!.live.roomId, false
            )
            seatService.setupWithOptions(context, option)
            seatService.addDelegate(seatDelegate)
            infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_ENABLE)
        }
        fetchSeatInfo(false)
    }

    override fun release() {
        // 如果是连麦状态，离开RTC房间
        if (isLinkingSeats) {
            linkedSeatsAudienceActionManager.leaveSeat(
                object : CompletionCallback<Void> {

                    override fun success(info: Void?) {
                        linkedSeatsAudienceActionManager.leaveChannel()
                        SeatService.destroyInstance()
                    }

                    override fun error(code: Int, msg: String) {
                        ToastUtils.showLong(msg)
                        linkedSeatsAudienceActionManager.leaveChannel()
                        SeatService.destroyInstance()
                    }
                })
            isLinkingSeats = false
        }
        super.release()
    }

    override fun closeBtnClick() {
        finishLiveRoomActivity(true)
    }

}