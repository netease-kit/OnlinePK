package com.netease.biz_live.yunxin.live.floatplay

import android.graphics.SurfaceTexture
import android.text.TextUtils
import android.view.Surface
import android.view.TextureView
import android.view.TextureView.SurfaceTextureListener
import com.netease.biz_live.yunxin.live.floatplay.FloatPlayLogUtil.log
import com.netease.neliveplayer.sdk.NELivePlayer
import com.netease.neliveplayer.sdk.constant.NEBufferStrategy
import com.netease.neliveplayer.sdk.model.NEAutoRetryConfig
import com.netease.yunxin.kit.alog.ALog
import java.io.IOException

class LiveVideoPlayerManager {
    private var player: NELivePlayer? = null
    private var preparedListener: NELivePlayer.OnPreparedListener? = null
    private var errorListener: NELivePlayer.OnErrorListener? = null
    private var videoSizeChangedListener: NELivePlayer.OnVideoSizeChangedListener? = null
    private val notifyArrayList: ArrayList<PlayerNotify>
    /**
     * 用来过滤textureView回调结束时，直播间已经切换到其他主播的case，防止player与画面不统一
     */
    private val hashMap = HashMap<TextureView, String>()
    private var currentVideoPath: String = ""

    fun addVideoPlayerObserver(playerNotify: PlayerNotify) {
        notifyArrayList.add(playerNotify)
        ALog.d(TAG,"addVideoPlayerObserver:add()")
    }

    fun removeVideoPlayerObserver(playerNotify: PlayerNotify) {
        notifyArrayList.remove(playerNotify)
        ALog.d(TAG,"addVideoPlayerObserver:remove()")
    }

    fun containsVideoPlayerObserver(playerNotify: PlayerNotify):Boolean {
        val result = notifyArrayList.contains(playerNotify)
        ALog.d(TAG,"containsVideoPlayerObserver:$result")
        return result

    }

    fun startPlay(videoPath: String, textureView: TextureView) {
        this.currentVideoPath = videoPath
        hashMap[textureView] = videoPath
        log(TAG, "startPlay(),videoPath:$videoPath,textureView:$textureView")
        try {
            if (!TextUtils.isEmpty(videoPath) && videoPath == player?.dataSource && player?.isPlaying!!) {
                log(TAG, "same videoPath")
            } else {
                log(TAG, "diff videoPath")
                player?.switchContentUrl(videoPath)
            }
            for (playerNotify in notifyArrayList) {
                playerNotify.onPreparing()
            }
        } catch (e: IOException) {
            e.printStackTrace()
            for (playerNotify in notifyArrayList) {
                playerNotify.onError()
            }
        }
        if (textureView.isAvailable) {
            val surface = Surface(textureView.surfaceTexture)
            player?.setSurface(surface)
            log(TAG, "startPlay:textureView.getSurfaceTexture()!=null")
        } else {
            textureView.surfaceTextureListener = object : SurfaceTextureListener {
                override fun onSurfaceTextureAvailable(
                    surface: SurfaceTexture,
                    width: Int,
                    height: Int
                ) {
                    if (currentVideoPath == hashMap[textureView]) {
                        player?.setSurface(Surface(surface))

                        for (playerNotify in notifyArrayList) {
                            playerNotify.onSurfaceTextureAvailable(surface, width, height)
                        }

                        log(TAG, "valid surface")
                    } else {
                        log(TAG, "invalid surface")
                    }
                }

                override fun onSurfaceTextureSizeChanged(
                    surface: SurfaceTexture,
                    width: Int,
                    height: Int
                ) {
                }

                override fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean {
                    log(TAG, "startPlay:onSurfaceTextureDestroyed,textureView:$textureView")
                    return true
                }

                override fun onSurfaceTextureUpdated(surface: SurfaceTexture) {

                }
            }
        }

        setPlayerListener()
    }

    fun resumePlay(videoPath: String){
        player?.switchContentUrl(videoPath)
    }

    private fun setPlayerListener() {
        // 设置相关回调
        preparedListener = NELivePlayer.OnPreparedListener { mp ->
            log(TAG, "onPrepared:$mp")
            for (playerNotify in notifyArrayList) {
                playerNotify.onPlaying()
            }
        }
        player?.setOnPreparedListener(preparedListener)
        errorListener = NELivePlayer.OnErrorListener { mp, what, extra ->
            log(TAG, "onError:$mp,what:$what,extra:$extra，notifyArrayList.size:"+notifyArrayList.size)
            for (playerNotify in notifyArrayList) {
                ALog.d(TAG,"playerNotify:$playerNotify")
                playerNotify.onError()
            }
            false
        }
        player?.setOnErrorListener(errorListener)
        videoSizeChangedListener =
            NELivePlayer.OnVideoSizeChangedListener { mp, width, height, sar_num, sar_den ->
                log(TAG, "onVideoSizeChanged:$mp,width:$width,height:$height")
                for (playerNotify in notifyArrayList) {
                    playerNotify.onVideoSizeChanged(width, height)
                }
            }
        player?.setOnVideoSizeChangedListener(videoSizeChangedListener)
    }


    fun release() {
        hashMap.clear()
        player?.setSurface(null)
        player?.release()
        player = null
        instance = null
        log(TAG, "release()")
    }

    /**
     * 自定义封装播放器回调
     */
    interface PlayerNotify {
        /**
         * 播放器开始准备阶段调用
         */
        fun onPreparing()

        /**
         * 播放器完成准备刚进入播放时回调
         */
        fun onPlaying()

        /**
         * 拉流过程中出现错误或设置拉流地址有误回调
         */
        fun onError()

        /**
         * 拉流资源尺寸发生变化时回调
         *
         * @param width  当前视频流宽度
         * @param height 当前视频流高度
         */
        fun onVideoSizeChanged(width: Int, height: Int)

        /**
         * surfaceTure重建
         *
         * @param surface  surfaceView
         * @param width  当前视频流宽度
         * @param height 当前视频流高度
         */
        fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int)
    }

    companion object {
        const val TAG = "LiveVideoPlayerManager"

        @Volatile
        private var instance: LiveVideoPlayerManager? = null
        fun getInstance(): LiveVideoPlayerManager {
            if (instance == null) {
                synchronized(LiveVideoPlayerManager::class.java) {
                    if (instance == null) {
                        instance = LiveVideoPlayerManager()
                    }
                }
            }
            return instance!!
        }
    }

    init {
        log("$this,NELivePlayer.create()")
        notifyArrayList = ArrayList()
        player = NELivePlayer.create()
        val retryConfig = NEAutoRetryConfig()
        retryConfig.count = 1
        retryConfig.delayArray = LongArray(5)
        player?.setAutoRetryConfig(retryConfig)
        // 直播缓存策略，速度优先
        player?.setBufferStrategy(NEBufferStrategy.NELPTOPSPEED)
        player?.setShouldAutoplay(true)
    }
}