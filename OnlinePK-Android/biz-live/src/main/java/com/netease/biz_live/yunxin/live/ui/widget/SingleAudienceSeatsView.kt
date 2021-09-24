/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.ui.widget

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.utils.AccountUtil
import com.netease.biz_live.yunxin.live.model.SeatMemberInfo
import com.netease.lava.nertc.sdk.video.NERtcVideoView
import com.netease.yunxin.android.lib.picture.ImageLoader
import com.netease.yunxin.lib_live_room_service.LiveRoomService
import com.netease.yunxin.seatlibrary.seat.constant.SeatAVState

/**
 * @author sunkeding
 * 单个连麦观众麦位视图
 */
class SingleAudienceSeatsView : FrameLayout {
    private var member: SeatMemberInfo? = null
    private var flMask: View? = null
    private var tvNickName: TextView? = null
    private var ivMicrophone: ImageView? = null
    private var ivHeader: ImageView? = null
    private var ivClose: ImageView? = null
    private var rtcView: NERtcVideoView? = null
    private val roomService by lazy { LiveRoomService.sharedInstance() }

    /**
     * 是否是主播
     */
    private var isAnchor = false

    constructor(context: Context) : super(context) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        init(context)
    }

    private fun init(context: Context?) {
        LayoutInflater.from(context).inflate(R.layout.biz_live_audience_seats_layout, this)
        flMask = findViewById(R.id.fl_mask)
        tvNickName = findViewById(R.id.tv_nickname)
        ivMicrophone = findViewById(R.id.iv_microphone)
        ivHeader = findViewById(R.id.iv_header)
        rtcView = findViewById(R.id.rtc_view)
        ivClose = findViewById(R.id.iv_close)
        ivClose?.setOnClickListener {
            if (closeSeatCallback != null && member != null) {
                closeSeatCallback?.closeSeat(member)
            }
        }
    }

    fun initLiveRoom(isAnchor: Boolean) {
        this.isAnchor = isAnchor
    }

    fun setData(member: SeatMemberInfo?) {
        if (member == null) {
            return
        }
        this.member = member
        tvNickName?.text = member.seatInfo.nickName
        ivMicrophone?.setImageResource(if (member.seatInfo.audioState == SeatAVState.OPEN) R.drawable.biz_live_microphone_open_status else R.drawable.biz_live_microphone_close_status)
        if (member.seatInfo.videoState == SeatAVState.OPEN) {
            ivHeader?.visibility = GONE
            flMask?.setBackgroundColor(Color.TRANSPARENT)
            try {
                if (!isAnchor && member.isSelf) {
                    roomService.getVideoOption().setupLocalVideoCanvas(rtcView, true)
                } else {
                    roomService.getVideoOption()
                        .setupRemoteVideoCanvas(rtcView, member.avRoomUser!!.avRoomUid, true)
                }
            } catch (e: NumberFormatException) {
                e.printStackTrace()
            }
        } else {
            ivHeader?.visibility = VISIBLE
            flMask?.setBackgroundColor(Color.parseColor("#222222"))
            ImageLoader.with(context.applicationContext)
                .circleLoad(member.seatInfo.avatar, ivHeader)
        }
        // 右上角x逻辑
        if (isAnchor) {
            ivClose?.visibility = VISIBLE
        } else {
            if (AccountUtil.isCurrentUser(member.seatInfo.accountId)) {
                ivClose?.visibility = VISIBLE
            } else {
                ivClose?.visibility = GONE
            }
        }
    }

    fun setCloseSeatCallback(closeSeatCallback: CloseSeatCallback?) {
        this.closeSeatCallback = closeSeatCallback
    }

    private var closeSeatCallback: CloseSeatCallback? = null

    interface CloseSeatCallback {
        /**
         * 点击右上角X的回调，主播端是把观众踢下麦，观众端是自己下麦
         */
        fun closeSeat(member: SeatMemberInfo?)
    }
}