/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.ui.view

import android.content.Context
import android.graphics.Matrix
import android.graphics.PointF
import android.util.AttributeSet
import android.view.TextureView
import com.blankj.utilcode.util.ScreenUtils
import com.netease.biz_live.yunxin.live.audience.utils.PlayerControl
import com.netease.biz_live.yunxin.live.audience.utils.PlayerControl.PlayerNotify
import com.netease.biz_live.yunxin.live.audience.utils.PlayerVideoSizeUtils
import com.netease.biz_live.yunxin.live.audience.utils.PlayerVideoSizeUtils.adjustViewSizePosition
import com.netease.biz_live.yunxin.live.utils.SpUtils
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.Constants
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig

/**
 * 播放直播间的CDN流
 */
class CDNStreamTextureView : TextureView {
    /**
     * 播放器控制，通过注册 TextureView 实现，控制播放器的
     */
    private var playerControl: PlayerControl? = null
    private var activity: BaseActivity? = null
    private var canRender = false

    /**
     * 是否正在连麦
     */
    private var isLinkingSeats = false

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
        activity = context as BaseActivity?
    }

    fun setUp(canRender: Boolean) {
        this.canRender = canRender
    }

    fun reset() {
        getPlayerControl()?.reset()
    }

    fun prepare(liveInfo: LiveInfo?) {
        getPlayerControl()?.prepareToPlay(liveInfo?.live?.liveConfig?.rtmpPullUrl, this)
    }

    fun setLinkingSeats(linkingSeats: Boolean) {
        isLinkingSeats = linkingSeats
        post {
            if (isLinkingSeats) {
                adjustVideoSizeForLinkSeats()
            } else {
                adjustVideoSizeForNormal()
            }
        }
    }

    fun release() {
        if (playerControl != null) {
            playerControl?.release()
            playerControl = null
        }
    }

    /**
     * 播放器控制回调
     */
    private val playerNotify: PlayerNotify = object : PlayerNotify {
        override fun onPreparing() {
            ALog.e(TAG, "player, preparing")
        }

        override fun onPlaying() {
            changeErrorState(false, AudienceErrorStateView.TYPE_ERROR)
            ALog.e(TAG, "player, playing")
        }

        override fun onError() {
            changeErrorState(true, AudienceErrorStateView.TYPE_ERROR)
            ALog.e(TAG, "player, error")
        }

        override fun onVideoSizeChanged(width: Int, height: Int) {
            if (height == Constants.StreamLayout.PK_LIVE_HEIGHT) {
                adjustVideoSizeForPk(false)
            } else if (isLinkingSeats) {
                adjustVideoSizeForLinkSeats()
            } else {
                adjustVideoSizeForNormal()
            }
            ALog.e(TAG, "video size changed, width is $width, height is $height")
        }
    }

    private fun adjustVideoSizeForLinkSeats() {
        // 宽满屏，VideoView按视频的宽高比同比例放大，VideoView在屏幕居中展示
        // 目标视频比例
        val videoWidth: Float = Constants.StreamLayout.SIGNAL_HOST_LIVE_WIDTH.toFloat()
        val videoHeight: Float = Constants.StreamLayout.SIGNAL_HOST_LIVE_HEIGHT.toFloat()
        val viewWidth = ScreenUtils.getScreenWidth()
        val viewHeight = ScreenUtils.getScreenHeight()
        // 填充满 720*1280区域
        val matrix = Matrix()
        // 平移 使 view 中心和 video 中心一致
        matrix.preTranslate((viewWidth - videoWidth) / 2f, (viewHeight - videoHeight) / 2f)
        //缩放 view 至原视频大小
        matrix.preScale(videoWidth / viewWidth, videoHeight / viewHeight)
        matrix.postScale(
            viewWidth / videoWidth,
            viewWidth / videoWidth,
            viewWidth / 2f,
            viewHeight / 2f
        )
        setTransform(matrix)
        postInvalidate()
    }

    fun adjustVideoSizeForPk(isPrepared: Boolean) {
        val width = SpUtils.getScreenWidth(activity!!)
        val height = (width / Constants.StreamLayout.WH_RATIO_PK).toInt()
        val x = width / 2f
        val y = StatusBarConfig.getStatusBarHeight(activity) + SpUtils.dp2pix(
            activity!!,
            64f
        ) + height / 2f
        val pivot = PointF(x, y)
        ALog.e(TAG, "pk video view center point is $pivot")
        if (isPrepared) {
            PlayerVideoSizeUtils.adjustForPreparePk(this, pivot)
        } else {
            PlayerVideoSizeUtils.adjustViewSizePosition(this, true, pivot)
        }
    }

    fun adjustVideoSizeForNormal() {
        adjustViewSizePosition(this)
    }

    /**
     * 获取播放器播放控制
     */
    fun getPlayerControl(): PlayerControl? {
        if (playerControl == null || playerControl?.isReleased() == true) {
            playerControl = PlayerControl(activity!!, playerNotify)
            return playerControl
        }
        return playerControl
    }

    private fun changeErrorState(error: Boolean, type: Int) {
        if (!canRender) {
            return
        }
        if (error) {
            getPlayerControl()?.reset()
            if (type == AudienceErrorStateView.TYPE_FINISHED) {
                release()
            } else {
                getPlayerControl()?.release()
            }
        }
    }

    companion object {
        private const val TAG: String = "MyTextureView"
    }
}