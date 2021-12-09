/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.utils

import android.graphics.Matrix
import android.graphics.PointF
import android.view.TextureView
import com.blankj.utilcode.util.ScreenUtils
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.lib_live_room_service.Constants

/**
 * Created by wangqiang04 on 1/8/21.
 *
 *
 * 当用户观看主播 pk 状态与 单人状态互相切换时需要更改当前视频 view 的尺寸大小适配
 */
object PlayerVideoSizeUtils {
    private const val TAG="PlayerVideoSizeUtils"
    /**
     * 调整播放区域以及位置，单人直播下以[LiveStreamParams#SIGNAL_HOST_LIVE_WIDTH][Constants.StreamLayout.SIGNAL_HOST_LIVE_HEIGHT]
     * 比例确定播放区域的大小，放缩到没有黑边；
     *
     *
     * pk 直播下以[LiveStreamParams#PK_LIVE_WIDTH][Constants.StreamLayout.PK_LIVE_HEIGHT]
     * 比例确定播放区域大小，放缩到一边填充完全为准；
     *
     * @param isPk 是否为 pk 状态
     */
    /**
     * 调整播放区域以及位置（更改成 单人直播状态）
     */
    @JvmOverloads
    fun adjustViewSizePosition(
        renderView: TextureView?,
        isPk: Boolean = false,
        pivot: PointF? = null
    ) {
        if (renderView == null) {
            return
        }
       ALog.d(TAG,"adjustViewSizePosition")
        renderView.post(Runnable {
            val width = renderView.width
            val height = renderView.height
            if (isPk && pivot != null) {
                adjustForPk(renderView, width, height, pivot)
            } else {
                adjustForNormal(
                    renderView,
                    ScreenUtils.getScreenWidth().toFloat(),
                    ScreenUtils.getScreenHeight().toFloat()
                )
            }
        })
    }

    /**
     * pk 态下页面调整
     */
    private fun adjustForPk(
        renderView: TextureView,
        viewWidth: Int,
        viewHeight: Int,
        pivot: PointF
    ) {
        ALog.d(TAG,"adjustForPk:viewWidth:$viewWidth,viewHeight:$viewHeight,pivot:$pivot")
        val videoWidth: Float = (Constants.StreamLayout.PK_LIVE_WIDTH * 2).toFloat()
        val videoHeight: Float = Constants.StreamLayout.PK_LIVE_HEIGHT.toFloat()
        val matrix = Matrix()
        matrix.preTranslate((viewWidth - videoWidth) / 2f, (viewHeight - videoHeight) / 2f)
        matrix.preScale(videoWidth / viewWidth, videoHeight / viewHeight)
        matrix.postScale(1.0f, 1.0f, viewWidth / 2f, viewHeight / 2f)

        // 填充满页面整体区域
        val sx = viewWidth / videoWidth
        val sy = viewHeight / videoHeight
        val minScale = sx.coerceAtMost(sy)
        matrix.postScale(minScale, minScale, viewWidth / 2f, viewHeight / 2f)
        matrix.postTranslate(pivot.x - viewWidth / 2f, pivot.y - viewHeight / 2f)
        renderView.setTransform(matrix)
        renderView.postInvalidate()
    }

    /**
     * 单人直播下页面调整
     */
    private fun adjustForNormal(renderView: TextureView, viewWidth: Float, viewHeight: Float) {
        ALog.d(TAG,"adjustForNormal:viewWidth:$viewWidth,viewHeight:$viewHeight")
        // 目标视频比例
        val videoWidth: Float = Constants.StreamLayout.SIGNAL_HOST_LIVE_WIDTH.toFloat()
        val videoHeight: Float = Constants.StreamLayout.SIGNAL_HOST_LIVE_HEIGHT.toFloat()

        // 填充满 720*1280区域
        val matrix = Matrix()
        // 平移 使 view 中心和 video 中心一致
        matrix.preTranslate((viewWidth - videoWidth) / 2f, (viewHeight - videoHeight) / 2f)
        // 缩放 view 至原视频大小
        matrix.preScale(videoWidth / viewWidth, videoHeight / viewHeight)
        //        // 放缩至 720*1280
        matrix.postScale(1.0f, 1.0f, viewWidth / 2f, viewHeight / 2f)
        //        // 填充满页面整体区域
        val sx = viewWidth / videoWidth
        val sy = viewHeight / videoHeight
        val maxScale = Math.max(sx, sy)
        matrix.postScale(maxScale, maxScale, viewWidth / 2f, viewHeight / 2f)
        renderView.setTransform(matrix)
        renderView.postInvalidate()
    }

    /**
     * 直播拉流时，当用户从单人进入 pk 状态由于拉流延迟问题出现
     * 信令和视频流不匹配状态，因此当接受到 pk 消息时，
     * 先将视频尺寸适配成 pk 尺寸宽度的一半，避免
     * 视频流拉伸
     */
    fun adjustForPreparePk(renderView: TextureView?, pivot: PointF) {
        if (renderView == null) {
            return
        }
        ALog.d(TAG,"adjustForPreparePk:pivot:$pivot")
        renderView.post(Runnable {
            val width = renderView.width
            val height = renderView.height
            adjustForPreparePk(renderView, width, height, pivot)
        })
    }

    private fun adjustForPreparePk(
        renderView: TextureView,
        viewWidth: Int,
        viewHeight: Int,
        pivot: PointF
    ) {
        ALog.d(TAG,"adjustForPreparePk:viewWidth:$viewWidth,viewHeight:$viewHeight,pivot:$pivot")
        val tempWidth: Float = Constants.StreamLayout.PK_LIVE_WIDTH.toFloat()
        val tempHeight: Float = Constants.StreamLayout.PK_LIVE_HEIGHT.toFloat()
        val videoWidth: Float = Constants.StreamLayout.SIGNAL_HOST_LIVE_WIDTH.toFloat()
        val videoHeight: Float = Constants.StreamLayout.SIGNAL_HOST_LIVE_HEIGHT.toFloat()
        var sx = tempWidth / videoWidth
        var sy = tempHeight / videoHeight
        val maxScale = sx.coerceAtLeast(sy)
        val matrix = Matrix()
        matrix.preTranslate((viewWidth - videoWidth) / 2f, (viewHeight - videoHeight) / 2f)
        matrix.preScale(videoWidth / viewWidth, videoHeight / viewHeight)
        matrix.postScale(maxScale, maxScale, viewWidth / 2f, viewHeight / 2f)

        // 填充满页面整体区域
        sx = viewWidth / 2f / tempWidth
        sy = viewHeight / tempHeight
        val minScale = sx.coerceAtMost(sy)
        matrix.postScale(minScale, minScale, viewWidth / 2f, viewHeight / 2f)
        matrix.postTranslate(-viewWidth / 4f, pivot.y - viewHeight / 2f)
        renderView.setTransform(matrix)
        renderView.postInvalidate()
    }
}