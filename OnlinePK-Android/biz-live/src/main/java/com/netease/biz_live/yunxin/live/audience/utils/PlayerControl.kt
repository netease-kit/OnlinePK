/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.utils

import android.graphics.SurfaceTexture
import android.text.TextUtils
import android.view.*
import android.view.TextureView.SurfaceTextureListener
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.netease.neliveplayer.sdk.NELivePlayer
import com.netease.neliveplayer.sdk.constant.NEBufferStrategy
import com.netease.neliveplayer.sdk.model.NEAutoRetryConfig
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import java.io.IOException

/**
 * Created by luc on 2020/11/11.
 *
 *
 * 包含播放器整体控制逻辑
 *
 *
 * 画面比例 single-720:1280, pk-720:640
 */
class PlayerControl(
    activity: BaseActivity,
    /**
     * 视频播放回调
     */
    private val notify: PlayerNotify?
) {
    /**
     * 播放器实例
     */
    private val player = NELivePlayer.create()

    /**
     * 内部播放器回调代理
     */
    private val innerNotify: PlayerNotify? = object : PlayerNotify {
        override fun onPreparing() {
            if (isReleased()) {
                return
            }
            notify?.onPreparing()
        }

        override fun onPlaying() {
            if (isReleased()) {
                return
            }
            notify?.onPlaying()
        }

        override fun onError() {
            if (isReleased()) {
                return
            }
            notify?.onError()
        }

        override fun onVideoSizeChanged(width: Int, height: Int) {
            if (isReleased()) {
                return
            }
            notify?.onVideoSizeChanged(width, height)
        }
    }

    /**
     * 播放器拉流准备完成回调
     */
    private val preparedListener: NELivePlayer.OnPreparedListener? =
        NELivePlayer.OnPreparedListener {
            if (isReleased()) {
                return@OnPreparedListener
            }
            // 视频开始播放
            player?.start()
            ALog.e("PlayerControl", "player is playing.")
            // 播放回调
            innerNotify?.onPlaying()
        }

    /**
     * 播放器拉流错误回调
     */
    private val errorListener: NELivePlayer.OnErrorListener =
        NELivePlayer.OnErrorListener { neLivePlayer: NELivePlayer?, errorCode: Int, extra: Int ->
            player.release()
            ALog.e("PlayerControl", "errorCode is $errorCode, extra info is $extra")
            innerNotify?.onError()
            true
        }

    /**
     * 播放器拉流尺寸变化回调
     */
    private val videoSizeChangedListener: NELivePlayer.OnVideoSizeChangedListener? =
        NELivePlayer.OnVideoSizeChangedListener { neLivePlayer: NELivePlayer?, width: Int, height: Int, sarNum: Int, sarDen: Int ->
            if (isReleased()) {
                return@OnVideoSizeChangedListener
            }
            ALog.e("PlayerControl", "video size is Changed, width is $width, height is $height")
            innerNotify?.onVideoSizeChanged(width, height)
        }

    /**
     * 视频渲染区域
     */
    private var renderView: TextureView? = null

    /**
     * 当前播放的视频Url
     */
    private var currentUrl: String? = null

    /**
     * 播放器重置
     */
    fun reset() {
        player.reset()
    }

    /**
     * 进行播放准备，设置 拉流地址，视频渲染区域
     *
     * @param url        拉流地址
     * @param renderView 视频渲染区域
     */
    fun prepareToPlay(url: String?, renderView: TextureView?) {
        currentUrl = url
        this.renderView = renderView
        renderView?.visibility = View.VISIBLE
        doPreparePlayAction()
    }

    /**
     * 执行预播放准备动作
     */
    private fun doPreparePlayAction() {
        // 回调准备中回调
        innerNotify?.onPreparing()
        if (isReleased()) {
            return
        }
        val retryConfig = NEAutoRetryConfig()
        retryConfig.count = 1
        retryConfig.delayArray = longArrayOf(5)
        player.setAutoRetryConfig(retryConfig)
        // 直播缓存策略，速度优先
        player.setBufferStrategy(NEBufferStrategy.NELPTOPSPEED)
        // 设置相关回调
        player.setOnPreparedListener(preparedListener)
        player.setOnErrorListener(errorListener)
        player.setOnVideoSizeChangedListener(videoSizeChangedListener)
        // 保证渲染view为可见的
        renderView?.visibility = View.VISIBLE
        // 设置拉流地址
        try {
            player.dataSource = currentUrl
        } catch (e: IOException) {
            e.printStackTrace()
            // 拉流错误直接回到错误
            innerNotify?.onError()
        }
        // prepare 阶段，当前 textureView 存在可用的 surface
        if (renderView?.isAvailable == true) {
            // 设置surface并调用异步接口
            player.setSurface(Surface(renderView?.surfaceTexture))
            player.prepareAsync()
        } else {
            // 若 surface 不可用，需要监听回调信息
            renderView?.surfaceTextureListener = object : SurfaceTextureListener {
                override fun onSurfaceTextureAvailable(
                    surface: SurfaceTexture,
                    width: Int,
                    height: Int
                ) {
                    player.setSurface(Surface(surface))
                    player.prepareAsync()
                }

                override fun onSurfaceTextureSizeChanged(
                    surface: SurfaceTexture,
                    width: Int,
                    height: Int
                ) {
                }

                override fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean {
                    return true
                }

                override fun onSurfaceTextureUpdated(surface: SurfaceTexture) {}
            }
        }
    }

    /**
     * 播放器资源释放避免内存占用过大
     */
    fun release() {
        player?.release()
        renderView = null
        currentUrl = null
    }

    /**
     * 当前播放器是否已经资源释放
     */
    fun isReleased(): Boolean {
        return TextUtils.isEmpty(currentUrl) || renderView == null || player == null
    }

    /**
     * 自定义封装播放器回调
     */
    interface PlayerNotify {
        /**
         * 播放器开始准备阶段调用
         */
        open fun onPreparing()

        /**
         * 播放器完成准备刚进入播放时回调
         */
        open fun onPlaying()

        /**
         * 拉流过程中出现错误或设置拉流地址有误回调
         */
        open fun onError()

        /**
         * 拉流资源尺寸发生变化时回调
         *
         * @param width  当前视频流宽度
         * @param height 当前视频流高度
         */
        open fun onVideoSizeChanged(width: Int, height: Int)
    }

    /**
     * 播放器构造
     *
     * @param activity 播放器所在 activity，通过声明周期监听控制播放器暂停，播放
     * @param notify   视频控制回调
     */
    init {

        // 页面声明周期监听 控制播放器 播放/暂停
        activity.lifecycle.addObserver(LifecycleEventObserver { source: LifecycleOwner?, event: Lifecycle.Event? ->
            if (event == Lifecycle.Event.ON_DESTROY || event == Lifecycle.Event.ON_PAUSE && activity.isFinishing) {
                release()
            }
        })
    }
}