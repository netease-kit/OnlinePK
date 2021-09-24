/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.ui

import android.content.Context
import androidx.fragment.app.FragmentActivity
import com.netease.biz_live.yunxin.live.dialog.AudioControlDialog
import com.netease.biz_live.yunxin.live.dialog.AudioControlDialog.DialogActionsCallback
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioEffectOption
import com.netease.lava.nertc.sdk.audio.NERtcCreateAudioMixingOption
import com.netease.yunxin.lib_live_room_service.impl.AudioOption
import java.io.*

/**
 * 音频控制
 */
class AudioControl(private val activity: FragmentActivity) {
    private val audioOption by lazy { AudioOption }
    private var musicIndex = -1 //默认伴音数组下标
    private var audioMixingVolume = 50
    private var audioEffectVolume = 50
    private var effectIndex //音效数组
            : IntArray? = null
    private var musicPathArray: Array<String>? = null
    private var effectPathArray: Array<String>? = null
    private var audioControlDialog: AudioControlDialog? = null

    /**
     * 初始化伴音和音效
     */
    fun initMusicAndEffect() {
        Thread {
            val root = ensureMusicDirectory()
            effectPathArray =
                arrayOf(extractMusicFile(root, EFFECT1), extractMusicFile(root, EFFECT2))
            musicPathArray = arrayOf(extractMusicFile(root, MUSIC1), extractMusicFile(root, MUSIC2))
        }.start()
    }

    private fun extractMusicFile(path: String, name: String): String {
        copyAssetToFile(activity, "$MUSIC_DIR/$name", path, name)
        return File(path, name).absolutePath
    }

    private fun copyAssetToFile(
        context: Context, assetsName: String,
        savePath: String, saveName: String
    ) {
        val dir = File(savePath)
        if (!dir.exists()) {
            dir.mkdirs()
        }
        val destFile = File(dir, saveName)
        var inputStream: InputStream? = null
        var outputStream: FileOutputStream? = null
        try {
            inputStream = context.resources.assets.open(assetsName)
            if (destFile.exists() && inputStream.available().toLong() == destFile.length()) {
                return
            }
            destFile.deleteOnExit()
            outputStream = FileOutputStream(destFile)
            val buffer = ByteArray(4096)
            var count: Int
            while (inputStream.read(buffer).also { count = it } != -1) {
                outputStream.write(buffer, 0, count)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            closeQuiet(inputStream)
            closeQuiet(outputStream)
        }
    }

    private fun closeQuiet(closeable: Closeable?) {
        if (closeable == null) {
            return
        }
        try {
            closeable.close()
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }

    private fun ensureMusicDirectory(): String {
        var dir = activity.getExternalFilesDir(MUSIC_DIR)
        if (dir == null) {
            dir = activity.getDir(MUSIC_DIR, 0)
        }
        if (dir != null) {
            dir.mkdirs()
            return dir.absolutePath
        }
        return ""
    }

    /**
     * 显示混音dailog
     */
    fun showAudioControlDialog() {
        audioControlDialog = AudioControlDialog()
        audioControlDialog?.setInitData(
            musicIndex,
            effectIndex,
            audioMixingVolume,
            audioEffectVolume
        )
        audioControlDialog?.setCallback(object : DialogActionsCallback {
            override fun setMusicPlay(index: Int): Boolean {
                musicIndex = index
                audioOption.stopAudioMixing()
                val option = NERtcCreateAudioMixingOption()
                option.path = musicPathArray?.get(musicIndex)
                option.playbackVolume = audioMixingVolume
                option.sendVolume = audioMixingVolume
                option.loopCount = 0 //无线循环
                return audioOption.startAudioMixing(option)
            }

            override fun onMusicVolumeChange(progress: Int) {
                audioMixingVolume = progress
                audioOption.setAudioMixingSendVolume(progress)
                audioOption.setAudioMixingPlaybackVolume(progress)
            }

            override fun addEffect(index: Int): Boolean {
                return addAudioEffect(index)
            }

            override fun onEffectVolumeChange(progress: Int, index: IntArray) {
                audioEffectVolume = progress
                //sample 中简单实用一个seekbar 控制所有effect的音量
                for (i in index.indices) {
                    if (index[i] == 1) {
                        audioOption.setEffectSendVolume(index2Id(i), progress)
                        audioOption.setEffectPlaybackVolume(index2Id(i), progress)
                    }
                }
            }

            override fun stopEffect(index: Int): Boolean {
                if (audioOption.stopEffect(index2Id(index))) {
                    effectIndex?.let {
                        it[index] = 0
                    }
                    return true
                }
                return false
            }

            override fun stopMusicPlay() {
                musicIndex = -1
                audioOption.stopAudioMixing()
            }
        })
        audioControlDialog?.show(
            activity.supportFragmentManager,
            AudioControlDialog::class.java.simpleName
        )
    }

    /**
     * 音效添加，音效同时可以有多个
     *
     * @param index
     * @return
     */
    private fun addAudioEffect(index: Int): Boolean {
        if (effectPathArray == null || effectPathArray?.size!! <= index) {
            return false
        }
        val option = NERtcCreateAudioEffectOption()
        option.path = effectPathArray?.get(index)
        option.playbackVolume = audioEffectVolume
        option.sendVolume = audioEffectVolume
        option.loopCount = 1
        audioOption.stopAllEffects()
        if (effectIndex == null) {
            effectIndex = IntArray(2)
        }
        for (i in 0..1) {
            if (i == index) {
                effectIndex?.set(index,1)
            } else {
                effectIndex?.set(i,0)
            }
        }
        return audioOption.playEffect(index2Id(index), option)
    }

    fun onMixingFinished() {
        audioControlDialog?.onMixingFinished()
        musicIndex = -1
    }

    fun onEffectFinish(id: Int) {
        audioControlDialog?.onEffectFinish(id)
        if (effectIndex != null && effectIndex?.size!! > id2Index(id)) {
            effectIndex?.set(id2Index(id),0)
        }
    }

    /**
     * effect index to id,id can't be 0
     *
     * @param index
     * @return
     */
    private fun index2Id(index: Int): Int {
        return index + 1
    }

    private fun id2Index(id: Int): Int {
        return id - 1
    }

    companion object {
        //*************************伴音**********************
        private const val MUSIC_DIR: String = "music"
        private const val MUSIC1: String = "music1.mp3"
        private const val MUSIC2: String = "music2.mp3"
        private const val EFFECT1: String = "effect1.wav"
        private const val EFFECT2: String = "effect2.wav"
    }
}