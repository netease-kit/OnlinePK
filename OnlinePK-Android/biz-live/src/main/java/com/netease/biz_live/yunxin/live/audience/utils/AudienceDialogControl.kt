/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.utils

import android.app.Activity
import android.view.View
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.dialog.ChoiceDialog
import com.netease.biz_live.yunxin.live.dialog.TipsDialog

/**
 * @author sunkeding
 * 观众端弹窗管理
 */
class AudienceDialogControl {
    private var anchorInviteDialog: ChoiceDialog? = null
    private var tipsDialog: TipsDialog? = null

    /**
     * 主播拒绝了你的连麦申请
     */
    fun showAnchorRejectDialog(activity: Activity) {
        if (tipsDialog == null) {
            tipsDialog = TipsDialog(activity)
        }
        tipsDialog?.setCancelable(false)
        tipsDialog?.setContent(activity.getString(R.string.biz_live_anchor_reject_link_seats_apply))
        tipsDialog?.setPositive(
            activity.getString(R.string.biz_live_i_know),
            View.OnClickListener { v: View? -> tipsDialog?.dismiss() })
        if (tipsDialog?.isShowing == false) {
            tipsDialog?.show()
        }
    }

    /**
     * 主播邀请你上麦
     */
    fun showAnchorInviteDialog(activity: Activity, joinSeatsListener: JoinSeatsListener?) {
        if (anchorInviteDialog == null) {
            anchorInviteDialog = ChoiceDialog(activity)
        }
        anchorInviteDialog?.setCancelable(false)
        anchorInviteDialog?.setTitle(activity.getString(R.string.biz_live_invite_join_seats))
        anchorInviteDialog?.setContent(activity.getString(R.string.biz_live_anchor_invite_audience_join_seats))
        anchorInviteDialog?.setNegative(
            activity.getString(R.string.biz_live_reject),
            View.OnClickListener { v: View? ->
                joinSeatsListener?.rejectInvite()
                anchorInviteDialog?.dismiss()
            })
        anchorInviteDialog?.setPositive(
            activity.getString(R.string.biz_live_join_seats),
            View.OnClickListener { v: View? ->
                joinSeatsListener?.acceptInvite()
                anchorInviteDialog?.dismiss()
            })
        if (anchorInviteDialog?.isShowing == false) {
            anchorInviteDialog?.show()
        }
        if (joinSeatsListener != null) {
            setJoinSeatsListener(joinSeatsListener)
        }
    }

    fun dismissAnchorInviteDialog() {
        if (anchorInviteDialog != null && anchorInviteDialog?.isShowing == true) {
            anchorInviteDialog?.dismiss()
        }
    }

    fun setJoinSeatsListener(joinSeatsListener: JoinSeatsListener?) {
        this.joinSeatsListener = joinSeatsListener
    }

    private var joinSeatsListener: JoinSeatsListener? = null

    interface JoinSeatsListener {
        open fun acceptInvite()
        open fun rejectInvite()
    }
}