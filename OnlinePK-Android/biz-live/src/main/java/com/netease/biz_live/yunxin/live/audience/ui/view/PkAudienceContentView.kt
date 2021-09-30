/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.view

import android.annotation.SuppressLint
import android.text.TextUtils
import com.blankj.utilcode.util.ToastUtils
import com.netease.biz_live.yunxin.live.audience.utils.AudiencePKControl
import com.netease.biz_live.yunxin.live.ui.widget.PKControlView
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_pk_service.Constants
import com.netease.yunxin.lib_live_pk_service.PkService
import com.netease.yunxin.lib_live_pk_service.bean.*
import com.netease.yunxin.lib_live_pk_service.delegate.PkDelegate
import com.netease.yunxin.lib_live_room_service.bean.reward.RewardAudience
import com.netease.yunxin.lib_live_room_service.chatroom.RewardMsg
import com.netease.yunxin.lib_network_kt.NetRequestCallback
import com.netease.yunxin.nertc.demo.basic.BaseActivity


@SuppressLint("ViewConstructor")
class PkAudienceContentView(activity: BaseActivity) : BaseAudienceContentView(activity) {

    companion object{
        const val LOG_TAG = "PkAudienceContentView"
        const val CODE_NO_PK = 55004
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
                if (TextUtils.equals(liveInfo?.anchor?.accountId, startInfo.invitee.accountId)) {
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
           getAudiencePKControl().onPunishmentStart(pkResult,punishInfo.pkPenaltyCountDown)
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
                    liveInfo?.anchor?.accountId
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
                    liveInfo?.anchor?.accountId
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
        pkService.init(liveInfo!!.live.roomId)
        pkService.setDelegate(pkDelegate)
        if (liveInfo?.live?.status == com.netease.yunxin.lib_live_room_service.Constants.LiveStatus.LIVE_STATUS_ON_PUNISHMENT
            || liveInfo?.live?.status == com.netease.yunxin.lib_live_room_service.Constants.LiveStatus.LIVE_STATUS_PKING
        ) {
            pkService.fetchPkInfo(object : NetRequestCallback<PkInfo> {
                override fun success(info: PkInfo?) {
                    info?.let {
                        val selfAnchor: PkUserInfo
                        val otherAnchor: PkUserInfo
                        val selfReward: PkReward
                        val otherReward: PkReward
                        if (TextUtils.equals(liveInfo?.anchor?.accountId, it.invitee.accountId)) {
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
                            Constants.PkStatus.PK_STATUS_PKING -> {
                                isPking = true
                                getAudiencePKControl().onPkStart(otherAnchor, it.countDown, false)
                            }
                            Constants.PkStatus.PK_STATUS_PUNISHMENT -> {
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
                                getAudiencePKControl().onPunishmentStart(pkResult, it.countDown)

                            }
                        }
                        getAudiencePKControl().onAnchorCoinChanged(
                            selfReward.rewardCoinTotal, otherReward.rewardCoinTotal,
                            transferOfAudienceList(selfReward.rewardTop),
                            transferOfAudienceList(otherReward.rewardTop)
                        )
                    }

                }

                override fun error(code: Int, msg: String) {
                    if (code != CODE_NO_PK) {
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

}