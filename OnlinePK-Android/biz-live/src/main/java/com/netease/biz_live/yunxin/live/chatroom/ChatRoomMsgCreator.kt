/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.chatroom

import android.graphics.Color
import com.blankj.utilcode.util.Utils
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.audience.utils.ChatMessageSpannableStr
import com.netease.biz_live.yunxin.live.utils.SpUtils
import com.netease.yunxin.nertc.module.base.sdk.NESdkBase

/**
 * Created by luc on 2020/11/11.
 */
object ChatRoomMsgCreator {
    /**
     * 文字高亮颜色
     */
    private val HIGH_COLOR = Color.parseColor("#99ffffff")

    /**
     * 文本信息颜色
     */
    private const val COMMON_COLOR = Color.WHITE

    /**
     * 进入房间
     */
    fun createRoomEnter(userNickName: String?): CharSequence {
        return ChatMessageSpannableStr.Builder()
            .append(userNickName, HIGH_COLOR)
            .append(" ")
            .append(Utils.getApp().getString(R.string.biz_live_enter_room), HIGH_COLOR)
            .build()
            .getMessageInfo()
    }

    /**
     * 离开房间
     */
    fun createRoomExit(userNickName: String?): CharSequence {
        return ChatMessageSpannableStr.Builder()
            .append(userNickName, HIGH_COLOR)
            .append(" ")
            .append(Utils.getApp().getString(R.string.biz_live_leave_room), HIGH_COLOR)
            .build()
            .getMessageInfo()
    }

    /**
     * 上麦
     */
    fun createSeatEnter(userNickName: String?): CharSequence {
        return ChatMessageSpannableStr.Builder()
            .append(userNickName, HIGH_COLOR)
            .append(" ")
            .append(Utils.getApp().getString(R.string.biz_live_has_success_enter_seat), HIGH_COLOR)
            .build()
            .getMessageInfo()
    }

    /**
     * 下麦
     */
    fun createSeatExit(userNickName: String?): CharSequence {
        return ChatMessageSpannableStr.Builder()
            .append(userNickName, HIGH_COLOR)
            .append(" ")
            .append(Utils.getApp().getString(R.string.biz_live_has_leave_seat), HIGH_COLOR)
            .build()
            .getMessageInfo()
    }

    /**
     * 创建非主播发送的文本消息
     */
    fun createText(userNickName: String?, msg: String?): CharSequence {
        return createText(false, userNickName, msg)
    }

    /**
     * 创建文本消息并标记是否由主播发送
     *
     * @param isAnchor     true 主播发送，false 非主播发送
     * @param userNickName 发送方昵称
     * @param msg          消息内容
     */
    fun createText(isAnchor: Boolean, userNickName: String?, msg: String?): CharSequence {
        val builder = ChatMessageSpannableStr.Builder()
        if (isAnchor) {
            val context = NESdkBase.instance.context
            val width = SpUtils.dp2pix(context!!, 30f)
            val height = SpUtils.dp2pix(context, 15f)
            builder.append(context, R.drawable.icon_msg_anchor_flag, width, height)
                ?.append(" ")
        }
        return builder
            .append(userNickName, HIGH_COLOR)
            .append(": ", HIGH_COLOR)
            .append(msg, COMMON_COLOR)
            .build()
            .getMessageInfo()
    }

    /**
     * 创建发送礼物消息
     *
     * @param userNickName 发送方昵称
     * @param giftCount    赠送礼物数量
     * @param giftRes      礼物资源id
     */
    fun createGiftReward(userNickName: String?, giftCount: Int, giftRes: Int): CharSequence? {
        val context = NESdkBase.instance.context
        val gifSize = SpUtils.dp2pix(context!!, 22f)
        return ChatMessageSpannableStr.Builder()
            .append(userNickName, HIGH_COLOR)
            .append(": ", HIGH_COLOR)
            .append(Utils.getApp().getString(R.string.biz_live_donate) + " × ", COMMON_COLOR)
            .append(giftCount.toString(), COMMON_COLOR)
            .append(Utils.getApp().getString(R.string.biz_live_count), COMMON_COLOR)
            .append(" ")
            .append(context, giftRes, gifSize, gifSize)
            ?.build()
            ?.getMessageInfo()
    }
}