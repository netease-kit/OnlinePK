/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.view

import android.annotation.SuppressLint
import android.text.TextUtils
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.yunxin.live.audience.utils.AudiencePKControl
import com.netease.biz_live.yunxin.live.floatplay.AudienceData
import com.netease.biz_live.yunxin.live.floatplay.CDNStreamTextureView
import com.netease.biz_live.yunxin.live.ui.widget.PKControlView
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_pk_service.PkConstants
import com.netease.yunxin.lib_live_pk_service.PkService
import com.netease.yunxin.lib_live_pk_service.bean.*
import com.netease.yunxin.lib_live_pk_service.delegate.PkDelegate
import com.netease.yunxin.lib_live_room_service.Constants
import com.netease.yunxin.lib_live_room_service.LiveTypeManager
import com.netease.yunxin.lib_live_room_service.bean.reward.RewardAudience
import com.netease.yunxin.lib_live_room_service.chatroom.RewardMsg
import com.netease.yunxin.lib_network_kt.NetRequestCallback
import com.netease.yunxin.nertc.demo.basic.BaseActivity


@SuppressLint("ViewConstructor")
class PkAudienceContentView(activity: BaseActivity) : BaseAudienceContentView(activity) {

    companion object{
        const val LOG_TAG = "PkAudienceContentView"
    }

    val pkService by lazy {
        PkService.shareInstance()
    }

    var isPking = false

    /**
     * pk 状态整体控制
     */
    private var audiencePKControl: AudiencePKControl? = null

    /**
     * 是否是被邀请方
     */
    private var isInvited = false

    private val pkDelegate = object : PkDelegate {
        /**
         * pk state changed,pk start
         */
        override fun onPkStart(startInfo: PkStartInfo) {
            val otherAnchor: PkUserInfo =
                if (TextUtils.equals(audienceViewModel?.data!!.liveInfo?.anchor?.accountId, startInfo.invitee.accountId)) {
                    isInvited = false
                    startInfo.inviter
                } else {
                    isInvited = true
                    startInfo.invitee
            }
            isPking = true
            getAudiencePKControl().onPkStart(otherAnchor,startInfo.pkCountDown)
        }

        /**
         * pk state changed,punish start
         */
        override fun onPunishStart(punishInfo: PkPunishInfo) {
            isPking = false
            val pkResult = if(punishInfo.inviteeRewards == punishInfo.inviterRewards){
                PKControlView.PK_RESULT_DRAW
            }else if (isInvited && punishInfo.inviteeRewards > punishInfo.inviterRewards){
                PKControlView.PK_RESULT_SUCCESS
            }else{
                PKControlView.PK_RESULT_FAILED
            }
           getAudiencePKControl().onPunishmentStart(null, pkResult, punishInfo.pkPenaltyCountDown)
        }

        /**
         * pk state changed,pk end
         */
        override fun onPkEnd(endInfo: PkEndInfo) {
            getAudiencePKControl().onPkEnd()
            isPking = false
        }

    }

    override fun onUserRewardImpl(rewardInfo: RewardMsg) {
        super.onUserRewardImpl(rewardInfo)
        if (isPking) {
            when {
                TextUtils.equals(
                    rewardInfo.anchorReward.accountId,
                    audienceViewModel?.data!!.liveInfo?.anchor?.accountId
                ) -> {
                    getAudiencePKControl().onAnchorCoinChanged(
                        rewardInfo.anchorReward.pkRewardTotal,
                        rewardInfo.otherAnchorReward!!.pkRewardTotal,
                        rewardInfo.anchorReward.pkRewardTop,
                        rewardInfo.otherAnchorReward!!.pkRewardTop
                    )
                }
                TextUtils.equals(
                    rewardInfo.otherAnchorReward!!.accountId,
                    audienceViewModel?.data!!.liveInfo?.anchor?.accountId
                ) -> {
                    getAudiencePKControl().onAnchorCoinChanged(
                        rewardInfo.otherAnchorReward!!.pkRewardTotal,
                        rewardInfo.anchorReward.pkRewardTotal,
                        rewardInfo.otherAnchorReward!!.pkRewardTop,
                        rewardInfo.anchorReward.pkRewardTop
                    )
                }
                else -> {
                    ALog.e(LOG_TAG, "reward is not for this live room")
                }
            }
        }
    }

    override fun initLiveType(isRetry: Boolean) {
        super.initLiveType(isRetry)
        pkService.init(audienceViewModel?.data!!.liveInfo!!.live.roomId)
        pkService.setDelegate(pkDelegate)
        if (audienceViewModel?.data!!.liveInfo?.live?.status == com.netease.yunxin.lib_live_room_service.Constants.LiveStatus.LIVE_STATUS_ON_PUNISHMENT
            || audienceViewModel?.data!!.liveInfo?.live?.status == com.netease.yunxin.lib_live_room_service.Constants.LiveStatus.LIVE_STATUS_PKING
        ) {
            pkService.fetchPkInfo(object : NetRequestCallback<PkInfo> {
                override fun success(info: PkInfo?) {
                    info?.let {
                        val selfAnchor: PkUserInfo
                        val otherAnchor: PkUserInfo
                        val selfReward: PkReward
                        val otherReward: PkReward
                        if (TextUtils.equals(audienceViewModel?.data!!.liveInfo?.anchor?.accountId, it.invitee.accountId)) {
                            isInvited = true
                            selfAnchor = it.invitee
                            selfReward = it.inviteeReward
                            otherAnchor = it.inviter
                            otherReward = it.inviterReward
                        } else {
                            isInvited = false
                            selfAnchor = it.inviter
                            selfReward = it.inviterReward
                            otherAnchor = it.invitee
                            otherReward = it.inviteeReward
                        }
                        when (info.status) {
                            PkConstants.PkStatus.PK_STATUS_PKING -> {
                                isPking = true
                                getAudiencePKControl().onPkStart(otherAnchor, it.countDown, false)
                            }
                            PkConstants.PkStatus.PK_STATUS_PUNISHMENT -> {
                                val pkResult = when {
                                    selfAnchor.rewardTotal == otherAnchor.rewardTotal -> {
                                        PKControlView.PK_RESULT_DRAW
                                    }
                                    selfAnchor.rewardTotal > otherAnchor.rewardTotal -> {
                                        PKControlView.PK_RESULT_SUCCESS
                                    }
                                    else -> {
                                        PKControlView.PK_RESULT_FAILED
                                    }
                                }
                                getAudiencePKControl().onPunishmentStart(
                                    otherAnchor,
                                    pkResult,
                                    it.countDown,
                                    true
                                )

                            }
                        }
                        getAudiencePKControl().onAnchorCoinChanged(
                            selfReward.rewardCoinTotal, otherReward.rewardCoinTotal,
                            transferOfAudienceList(selfReward.rewardTop),
                            transferOfAudienceList(otherReward.rewardTop)
                        )
                    }
                    // 基于直播类型，来调整播放内容样式.
                    if (isPking){
                        LiveTypeManager.setCurrentLiveType(com.netease.yunxin.lib_live_room_service.Constants.LiveType.LIVE_TYPE_PK)
                    }else{
                        LiveTypeManager.setCurrentLiveType(com.netease.yunxin.lib_live_room_service.Constants.LiveType.LIVE_TYPE_DEFAULT)
                    }
                }

                override fun error(code: Int, msg: String) {
                    if (code != PkConstants.ErrorCode.CODE_NO_PK) {
                        ToastUtils.showLong(msg)
                    }
                }
            })
        }
    }

    /**
     * 观众列表数据结构转换
     */
    private fun transferOfAudienceList(audiences: List<PkRewardAudience>): List<RewardAudience> {
        val audienceList = ArrayList<RewardAudience>(audiences.size)
        for (audience in audiences) {
            audienceList.add(
                RewardAudience(
                    audience.accountId,
                    audience.imAccid,
                    audience.nickname,
                    audience.avatar,
                    audience.rewardCoin
                )
            )
        }
        return audienceList
    }

    private fun getAudiencePKControl(): AudiencePKControl {
        if (audiencePKControl == null) {
            audiencePKControl = AudiencePKControl()
            audiencePKControl!!.init(activity, videoView, infoBinding.root)
        }
        return audiencePKControl!!
    }

    override fun release() {
        super.release()
        audiencePKControl?.release()
        PkService.destroyInstance()
    }

    override fun adjustVideoSize(data: AudienceData) {
        // 现有的方案描述：PK蒙层与视频画面大小变更存在时间差，画面是CDN流，延迟2-5s，蒙层由透传消息触发。
        // 以下代码是解决小窗切换到大窗的瞬间直播状态发生变化导致PK蒙层与视频画面不匹配问题
        if (LiveTypeManager.getCurrentLiveType()== Constants.LiveType.LIVE_TYPE_DEFAULT
            &&CDNStreamTextureView.isSingleAnchorSize(data.videoInfo?.videoWidth!!,data.videoInfo?.videoHeight!!)) {
            videoView?.adjustVideoSizeForNormal()
            ALog.d(LOG_TAG,"adjustVideoSizeForNormal")
        }else if (LiveTypeManager.getCurrentLiveType()== Constants.LiveType.LIVE_TYPE_PK
            &&CDNStreamTextureView.isPkSize(data.videoInfo?.videoWidth!!,data.videoInfo?.videoHeight!!)){
            videoView?.adjustVideoSizeForPk(false)
            ALog.d(LOG_TAG,"adjustVideoSizeForPk")
        }else{
            // 继续走现有方案，与当前进直播间逻辑保持同步
            ALog.d(LOG_TAG,"adjust video canvas by onVideoSizeChanged callback")
        }
    }
}