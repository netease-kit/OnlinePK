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
     * ???????????????????????????????????????
     */
    private var waitAnchorAcceptFloatLayer: WaitAnchorAcceptView? = null

    /**
     * ????????????
     */
    private var audienceDialogControl: AudienceDialogControl? = null

    /**
     * ?????????????????????
     */
    private val linkedSeatsAudienceActionManager by lazy {
        LinkedSeatsAudienceActionManager
    }

    /**
     * ???????????????????????????????????????????????????????????????????????????????????????
     * ?????????????????????????????????????????????????????????????????????RTC????????????linkSeatsRv?????????????????????????????????isLinkingSeats????????????????????????????????????UI??????????????????
     */
    private var linkSeatsRv: LinkSeatsAudienceRecycleView? = null

    /**
     * ??????????????????????????????????????????????????????RTC?????????????????????????????????CDN???
     */
    private var isLinkingSeats = false

    /**
     * ???????????????????????????????????????????????????RTC???
     */
    var rtcVideoView: NERtcVideoView? = null

    val seatDelegate = object :SeatDelegate{
        /**
         * ??????????????????
         */
        override fun onSeatApplyRequest(event: SeatApplyEvent) {
            //audience need no impl
        }

        /**
         * ??????????????????????????????
         */
        override fun onSeatApplyRequestCanceled(event: SeatApplyEvent) {
            //audience need no impl
        }

        /**
         * ????????????????????????
         */
        override fun onSeatPickAccepted(event: SeatPickEvent) {
            //audience need no impl
        }

        /**
         * ???????????????????????????
         */
        override fun onSeatPickRejected(event: SeatPickEvent) {
            //audience need no impl
        }

        /**
         * ?????????????????????
         */
        override fun onSeatEntered(event: SeatEnterEvent) {
            val member = SeatMemberInfo(event.seatInfo, event.avRoomUser)
            onUserEnterSeat(member, fetchInfo = true, true)
        }

        /**
         * ?????????????????????
         */
        override fun onSeatLeft(event: SeatLeaveEvent) {
            ALog.d(LOG_TAG, "onSeatLeft ")
            onUserExitSeat(SeatMemberInfo(event.seatInfo, event.avRoomUser))
        }

        /**
         * ??????????????????
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
         * ??????????????????????????????
         */
        override fun onSeatPickRequestCanceled(event: SeatPickRequestEvent) {
            //audience need no impl
        }

        /**
         * ?????????????????????
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
         * ?????????????????????
         */
        override fun onSeatApplyRejected(event: SeatApplyEvent) {
            ALog.d(LOG_TAG, "onSeatApplyRejected")
            waitAnchorAcceptFloatLayer?.visibility = GONE
            infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_ENABLE)
            getAudienceDialogControl()?.showAnchorRejectDialog(activity)
        }

        /**
         * ????????????????????????
         */
        override fun onSeatAudioMuteStateChanged(event: SeatStateChangeEvent) {
            ALog.d(LOG_TAG, "onSeatAudioMuteStateChanged")
            if (AccountUtil.isCurrentUser(event.seatInfo.accountId) &&
                !AccountUtil.isCurrentUser(event.responder.accountId)
            ) {
                //?????????????????????????????????????????????????????????
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
         * ????????????????????????
         */
        override fun onSeatVideoMuteStateChanged(event: SeatStateChangeEvent) {
            ALog.d(LOG_TAG, "onSeatVideoMuteStateChanged")
            if (AccountUtil.isCurrentUser(event.seatInfo.accountId) &&
                !AccountUtil.isCurrentUser(event.responder.accountId)
            ) {
                //?????????????????????????????????????????????????????????
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
         * ????????????????????????
         */
        override fun onSeatStateChanged(event: SeatStateChangeEvent) {
            if (event.seatInfo.status == SeatState.SEAT_SATE_IDLE
                && event.reason == Reason.TIME_OUT
            ) {
                //????????????
                if (waitAnchorAcceptFloatLayer?.isShown == true) {
                    waitAnchorAcceptFloatLayer?.visibility = View.GONE

                    waitAnchorAcceptFloatLayer?.tvCancel?.isEnabled = true
                }
                //??????????????????
                getAudienceDialogControl()?.dismissAnchorInviteDialog()

                //??????????????????
                infoBinding.btnMultiFunction.setType(
                    MultiFunctionButton.Type.APPLY_SEAT_ENABLE
                )
            }
        }

        /**
         * ??????????????????????????????
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
        //????????????????????????CDN?????????RTC??????????????????????????????RTC???
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
        //???????????????????????????
        addSelfToLinkSeatsRv(member)
        infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.LINK_SEATS_SETTING)
        // ??????RTC?????????
        if (rtcVideoView == null) {
            rtcVideoView = NERtcVideoView(context)
            addView(rtcVideoView, 0, generateDefaultLayoutParams())
        }
        //???????????????RTC?????????
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
                        //?????????????????????????????????
                        for (member in tempMembers) {
                            if (!onSeatMember.contains(member.seatInfo)) {
                                onUserExitSeat(member, showRoomMsg)
                            }
                        }

                        //??????????????????????????????
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
     * ??????????????????
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
     * ????????????
     *
     * @param member
     */
    private fun onUserEnterSeat(member: SeatMemberInfo, fetchInfo: Boolean, showRoomMsg: Boolean) {
        if (AccountUtil.isCurrentUser(member.seatInfo.accountId)) {
            //????????????????????????????????????
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
                //????????????
                infoBinding.btnMultiFunction.setType(MultiFunctionButton.Type.APPLY_SEAT_DISABLE)
                seatService.applySeat(ApplySeatParams(null), object : CompletionCallback<String> {
                    override fun success(info: String?) {
                        waitAnchorAcceptFloatLayer?.visibility = VISIBLE
                    }

                    override fun error(code: Int, msg: String) {
                        //??????????????????
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
        // ??????????????????????????????RTC??????
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