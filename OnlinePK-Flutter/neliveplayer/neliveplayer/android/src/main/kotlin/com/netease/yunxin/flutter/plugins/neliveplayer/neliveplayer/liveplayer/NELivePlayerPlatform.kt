/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.flutter.plugins.neliveplayer.neliveplayer.liveplayer

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Surface
import com.netease.neliveplayer.sdk.NELivePlayer
import com.netease.neliveplayer.sdk.constant.NEPlayStatusType
import com.netease.neliveplayer.sdk.model.NEAutoRetryConfig
import com.netease.neliveplayer.sdk.model.NESDKConfig
import com.netease.yunxin.flutter.plugins.neliveplayer.pigeon.Pigeon
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.view.TextureRegistry

class NELivePlayerPlatform : Pigeon.NeLivePlayerApi, IPlatform {

    private val logTag = "NELivePlayerPlatform"

    private lateinit var applicationContext: Context

    private var liveListener: Pigeon.NeLivePlayerListenerApi? = null

    private val voidReply = Pigeon.NeLivePlayerListenerApi.Reply<Void> {}

    private val handler: Handler = Handler(Looper.getMainLooper())

    private val players = HashMap<String, NELivePlayer>()

    private val surfaceTextures = HashMap<String, TextureRegistry.SurfaceTextureEntry>()

    private var textureRegistry: TextureRegistry? = null

    private fun runOnMainThread(runnable: () -> Unit) {
        if (Looper.getMainLooper() == Looper.myLooper()) {
            runnable()
        } else {
            handler.post(runnable)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(logTag, "onAttachedToEngine")
        applicationContext = binding.applicationContext
        textureRegistry = binding.textureRegistry
        Pigeon.NeLivePlayerApi.setup(binding.binaryMessenger, this)
        liveListener = Pigeon.NeLivePlayerListenerApi(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(logTag, "onDetachedFromEngine")
        Pigeon.NeLivePlayerApi.setup(binding.binaryMessenger, null)
        liveListener = null
    }

    override fun initAndroid(config: Pigeon.NeLiveConfig) {
        Log.d(logTag, "initAndroid")
        val sdkConfig = NESDKConfig()
        config.isCloseTimeOutProtect?.let {
            sdkConfig.isCloseTimeOutProtect = it
        }
        config.refreshPreLoadDuration?.let {
            sdkConfig.refreshPreLoadDuration = it
        }
        config.thirdUserId?.let {
            sdkConfig.thirdUserId = it
        }
        NELivePlayer.init(applicationContext, sdkConfig)
    }

    override fun create(): String {
        val neLivePlayer = NELivePlayer.create()
        val playerId = neLivePlayer.hashCode().toString()
        players[playerId] = neLivePlayer
        setListeners(neLivePlayer)
        Log.d(logTag, "have created player id = $playerId")
        val textureEntry: TextureRegistry.SurfaceTextureEntry =
            textureRegistry!!.createSurfaceTexture()
        val textureId = textureEntry.id().toString()
        neLivePlayer.setSurface(
            Surface(
                textureEntry.surfaceTexture()
            )
        )
        surfaceTextures[playerId] = textureEntry
        Log.d(logTag, "have set surface textId id = $textureId")
        return "$playerId+$textureId"
    }

    private fun setListeners(player: NELivePlayer) {
        player.setOnPreparedListener {
            Log.d(logTag, "onPrepared player = ${it.hashCode()}")
            liveListener?.onPrepared(it.hashCode().toString(), voidReply)
        }
        player.setOnCompletionListener {
            Log.d(logTag, "onCompletion player = ${it.hashCode()}")
            liveListener?.onCompletion(it.hashCode().toString(), voidReply)
        }
        player.setOnErrorListener { livePlayer, what, extra ->
            Log.d(logTag, "onError player = ${livePlayer.hashCode()}")
            liveListener?.onError(
                livePlayer.hashCode().toString(),
                what.toLong(),
                extra.toLong(),
                voidReply
            )
            true
        }

        player.setOnReleasedListener {
            runOnMainThread {
                val playerId = it.hashCode().toString()
                Log.d(
                    logTag,
                    "onReleased thread is ${Thread.currentThread().name} player = $playerId"
                )
                liveListener?.onReleased(playerId, voidReply)
            }
        }
        player.setOnVideoSizeChangedListener { livePlayer, width, height, sarNum, sarDen ->
            Log.d(
                logTag,
                "onVideoSizeChanged $width,$height,$sarNum,$sarDen  player = ${livePlayer.hashCode()}"
            )
            liveListener?.onVideoSizeChanged(
                livePlayer.hashCode().toString(),
                width.toLong(),
                height.toLong(),
                voidReply
            )
        }
        player.setOnInfoListener { livePlayer, what, extra ->
            Log.d(
                logTag,
                "setOnInfoListener what$what, extra$extra  player = ${livePlayer.hashCode()}"
            )
            when (what) {
                NEPlayStatusType.NELP_FIRST_AUDIO_RENDERED -> {
                    liveListener?.onFirstAudioDisplay(livePlayer.hashCode().toString(), voidReply)
                }
                NEPlayStatusType.NELP_FIRST_VIDEO_RENDERED -> {
                    liveListener?.onFirstVideoDisplay(livePlayer.hashCode().toString(), voidReply)
                }
                else -> {
                    liveListener?.onLoadStateChange(
                        livePlayer.hashCode().toString(),
                        what.toLong(),
                        extra.toLong(),
                        voidReply
                    )
                }
            }
            true
        }
    }

    override fun release(playerId: String) {
        Log.d(logTag, "release")
        players[playerId]?.release()
        players.remove(playerId)
        surfaceTextures[playerId]?.release()
        surfaceTextures.remove(playerId)
    }

    override fun setPlayUrl(playerId: String, path: String): Boolean {
        Log.d(logTag, "setPlayUrl path ： $path")
        if (players[playerId] != null) {
            return players[playerId]!!.setDataSource(path)
        }
        return false
    }

    override fun prepareAsync(playerId: String) {
        Thread {
            Log.d(logTag, "prepareAsync thread is ${Thread.currentThread().name}")
            players[playerId]?.prepareAsync()
        }.start()
    }

    override fun start(playerId: String) {
        Log.d(logTag, "start")
        players[playerId]?.start()
    }

    override fun stop(playerId: String) {
        Log.d(logTag, "stop")
        players[playerId]?.stop()
    }

    override fun getCurrentPosition(playerId: String): Long {
        Log.d(logTag, "getCurrentPosition")
        return players[playerId]?.currentPosition ?: 0
    }

    override fun switchContentUrl(playerId: String, url: String) {
        Log.d(logTag, "switchContentUrl url : $url")
        players[playerId]?.switchContentUrl(url)
    }

    override fun getVersion(): String {
        Log.d(logTag, "getVersion")
        return NELivePlayer.getSDKInfo(applicationContext).version
    }

    override fun addPreloadUrls(urls: MutableList<String>) {
        Log.d(logTag, "addPreloadUrls urls :$urls")
        NELivePlayer.addPreloadUrls(ArrayList(urls))
    }

    override fun removePreloadUrls(urls: MutableList<String>) {
        Log.d(logTag, "removePreloadUrls urls :$urls")
        NELivePlayer.removePreloadUrls(ArrayList(urls))
    }

    override fun queryPreloadUrls(): MutableMap<String, Long> {
        Log.d(logTag, "queryPreloadUrls")
        val map = HashMap<String, Long>()
        NELivePlayer.queryPreloadUrls().forEach { (key, value) -> map[key] = value.toLong() }
        return map
    }

    override fun setAutoRetryConfig(playerId: String, config: Pigeon.NEAutoRetryConfig) {
        Log.d(logTag, "setAutoRetryConfig $config")
        val retryConfig = NEAutoRetryConfig()
        config.count?.let {
            retryConfig.count = it.toInt()
        }
        config.delayArray?.let {
            retryConfig.delayArray = it.toLongArray()
        }
        config.delayDefault?.let {
            retryConfig.delayDefault = it
        }
        players[playerId]?.setAutoRetryConfig(retryConfig)
    }

    override fun setPreloadResultValidityIos(validity: Long) {
        // 不需要实现
    }

    override fun setVolume(playerId: String, volume: Double) {
        Log.d(logTag, "setVolume  volume : $volume")
        players[playerId]?.setVolume(volume.toFloat())
    }

    override fun setMute(playerId: String, isMute: Boolean) {
        Log.d(logTag, "setMute  isMute : $isMute")
        players[playerId]?.setMute(isMute)
    }

    override fun setPlaybackTimeout(playerId: String, timeout: Long) {
        Log.d(logTag, "setPlaybackTimeout  timeout : $timeout")
        players[playerId]?.setPlaybackTimeout(timeout)
    }

    override fun setHardwareDecoder(playerId: String, isOpen: Boolean) {
        Log.d(logTag, "setHardwareDecoder  isOpen : $isOpen")
        players[playerId]?.setHardwareDecoder(isOpen)
    }

    override fun setBufferStrategy(playerId: String, bufferStrategy: Long) {
        Log.d(logTag, "setBufferStrategy  bufferStrategy : $bufferStrategy")
        players[playerId]?.setBufferSize(bufferStrategy.toInt())
    }

    override fun setShouldAutoplay(playerId: String, isAutoplay: Boolean) {
        Log.d(logTag, "setShouldAutoplay  isAutoplay : $isAutoplay")
        players[playerId]?.setShouldAutoplay(isAutoplay)
    }
}

interface IPlatform {

    fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding)

    fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding)
}
