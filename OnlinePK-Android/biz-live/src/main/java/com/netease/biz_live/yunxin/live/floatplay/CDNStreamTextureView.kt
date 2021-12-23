/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.floatplay

import android.content.Context
import android.graphics.Matrix
import android.graphics.PointF
import android.graphics.SurfaceTexture
import android.util.AttributeSet
import android.view.TextureView
import com.blankj.utilcode.util.ActivityUtils
import com.blankj.utilcode.util.ScreenUtils

import com.netease.biz_live.yunxin.live.audience.utils.PlayerVideoSizeUtils
import com.netease.biz_live.yunxin.live.utils.SpUtils
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.Constants
import com.netease.yunxin.lib_live_room_service.bean.LiveInfo
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig

/**
 * 播放直播间的CDN流
 */
class CDNStreamTextureView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : TextureView(context, attrs) {

    /**
     * 是否正在连麦
     */
    private var isLinkingSeats = false

    private var isPK = false;

    private val playerNotify=object :
        LiveVideoPlayerManager.PlayerNotify {
        override fun onPreparing() {
            FloatPlayLogUtil.log(TAG ,"onPreparing()")
        }

        override fun onPlaying() {
            FloatPlayLogUtil.log(TAG ,"onPlaying()")
        }

        override fun onError() {
            FloatPlayLogUtil.log(TAG ,"onError()")
        }

        override fun onVideoSizeChanged(width: Int, height: Int) {
            FloatPlayLogUtil.log(TAG , "onVideoSizeChanged(),width:$width,height:$height")
            isPK = isPkSize(width,height)
            refreshTextureView()
        }

        override fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int) {
            FloatPlayLogUtil.log(TAG ,"onSurfaceTextureAvailable()")
            refreshTextureView()
        }

    }


    fun prepare(liveInfo: LiveInfo?) {
        val rtmpPullUrl = liveInfo?.live?.liveConfig?.rtmpPullUrl
        FloatPlayLogUtil.log(TAG,",prepare():$rtmpPullUrl,CDNStreamTextureView2:$this")
        rtmpPullUrl?.let {
            ALog.d(TAG,"prepare(),playNotify:$playerNotify")
            LiveVideoPlayerManager.getInstance().addVideoPlayerObserver(playerNotify)
            LiveVideoPlayerManager.getInstance().startPlay(rtmpPullUrl, this)
        }

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
        val width = SpUtils.getScreenWidth(context)
        val height = (width / Constants.StreamLayout.WH_RATIO_PK).toInt()
        val x = width / 2f
        val y = StatusBarConfig.getStatusBarHeight(ActivityUtils.getTopActivity()) + SpUtils.dp2pix(
            context,
            64f
        ) + height / 2f
        val pivot = PointF(x, y)
        FloatPlayLogUtil.log(TAG, "pk video view center point is $pivot")
        if (isPrepared) {
            PlayerVideoSizeUtils.adjustForPreparePk(this, pivot)
        } else {
            PlayerVideoSizeUtils.adjustViewSizePosition(this, true, pivot)
        }

    }

    fun adjustVideoSizeForNormal() {
        PlayerVideoSizeUtils.adjustViewSizePosition(this)
    }


    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        LiveVideoPlayerManager.getInstance().removeVideoPlayerObserver(playerNotify)
    }

    companion object {
        private const val TAG: String = "CDNStreamTextureView"
        fun isPkSize(videoWidth:Int,videoHeight:Int):Boolean{
            if (videoWidth==0||videoHeight==0){
                return false
            }
            return videoWidth/videoHeight == Constants.StreamLayout.PK_LIVE_WIDTH*2/Constants.StreamLayout.PK_LIVE_HEIGHT
        }

        fun isSingleAnchorSize(videoWidth:Int,videoHeight:Int):Boolean{
            if (videoWidth==0||videoHeight==0){
                return false
            }
            return videoWidth/videoHeight == Constants.StreamLayout.SIGNAL_HOST_LIVE_WIDTH/Constants.StreamLayout.SIGNAL_HOST_LIVE_HEIGHT
        }
    }

    fun refreshTextureView(){
        if (isPK) {
            adjustVideoSizeForPk(false)
        } else if (isLinkingSeats) {
            adjustVideoSizeForLinkSeats()
        } else {
            adjustVideoSizeForNormal()
        }
    }

}