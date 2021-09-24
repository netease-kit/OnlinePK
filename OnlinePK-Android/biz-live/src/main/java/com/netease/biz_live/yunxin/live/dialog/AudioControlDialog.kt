/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.dialog

import android.view.View
import android.widget.SeekBar
import android.widget.SeekBar.OnSeekBarChangeListener
import android.widget.TextView
import com.netease.biz_live.R

/**
 * 音量控制dialog
 */
class AudioControlDialog : BaseBottomDialog() {
    private var tvMusic1: TextView? = null
    private var tvMusic2: TextView? = null
    private var tvEffect1: TextView? = null
    private var tvEffect2: TextView? = null
    private var sbrMusicVolume: SeekBar? = null
    private var sbrEffectVolume: SeekBar? = null
    private var musicVolume //背景音乐音量
            = 0
    private var effectVolume //音效音量
            = 0
    private var callback: DialogActionsCallback? = null
    private var musicIndex = -1
    private var effectIndex: IntArray? = null
    override fun getResourceLayout(): Int {
        return R.layout.audio_contril_dialog_layout
    }

    override fun initView(rootView: View) {
        tvMusic1 = rootView.findViewById(R.id.tv_music_1)
        tvMusic2 = rootView.findViewById(R.id.tv_music_2)
        tvEffect1 = rootView.findViewById(R.id.tv_audio_effect_1)
        tvEffect2 = rootView.findViewById(R.id.tv_audio_effect_2)
        sbrMusicVolume = rootView.findViewById(R.id.music_song_volume_control)
        sbrEffectVolume = rootView.findViewById(R.id.audio_effect_volume_control)
        super.initView(rootView)
    }

    override fun initData() {
        //初始化数据设置view
        if (musicIndex == 0) {
            tvMusic1?.isSelected = true
        } else if (musicIndex == 1) {
            tvMusic2?.isSelected = true
        }
        sbrMusicVolume?.progress = musicVolume
        sbrEffectVolume?.progress = effectVolume
        effectIndex?.let{
            for (i in it.indices) {
                if (i == 0 && it[i] == 1) {
                    tvEffect1?.isSelected = true
                }
                if (i == 1 && it[i] == 1) {
                    tvEffect2?.isSelected = true
                }
            }
        }
        //======================伴音(背景音乐)控制=======================
        tvMusic1?.setOnClickListener {
            callback?.let {
                if (tvMusic1?.isSelected == false) {
                    tvMusic1?.isSelected = it.setMusicPlay(0)
                } else {
                    it.stopMusicPlay()
                    tvMusic1?.isSelected = tvMusic1?.isSelected == false
                }
            }
            tvMusic2?.isSelected = false
        }
        tvMusic2?.setOnClickListener {
            callback?.let {
                if (tvMusic2?.isSelected == false) {
                    tvMusic2?.setSelected(it.setMusicPlay(1))
                } else {
                    it.stopMusicPlay()
                    tvMusic2?.setSelected(tvMusic2?.isSelected == false)
                }
            }
            tvMusic1?.isSelected = false
        }
        sbrMusicVolume?.setOnSeekBarChangeListener(object : OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                callback?.onMusicVolumeChange(progress)
            }

            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })

        //====================音效控制======================
        tvEffect1?.setOnClickListener {
            if (tvEffect1?.isSelected == false) {
                if (callback != null) {
                    tvEffect1?.isSelected = callback?.addEffect(0) == true
                }
            } else {
                callback?.let {
                    tvEffect1?.isSelected = !it.stopEffect(0)
                }
            }
            tvEffect2?.isSelected = false
        }
        tvEffect2?.setOnClickListener {
            if (tvEffect2?.isSelected == false) {
                callback?.let {
                    tvEffect2?.setSelected(it.addEffect(1))
                }
            } else {
                callback?.let {
                    tvEffect2?.setSelected(!it.stopEffect(1))
                }
            }
            tvEffect1?.isSelected = false
        }
        sbrEffectVolume?.setOnSeekBarChangeListener(object : OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                callback?.let {
                    val index = IntArray(2)
                    index[0] = if (tvEffect1?.isSelected == true) 1 else 0
                    index[1] = if (tvEffect2?.isSelected == true) 1 else 0
                    it.onEffectVolumeChange(progress, index)
                }
            }

            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })
        super.initData()
    }

    fun setCallback(callback: DialogActionsCallback?) {
        this.callback = callback
    }

    fun setInitData(musicIndex: Int, effectIndex: IntArray?, musicVolume: Int, effectVolume: Int) {
        this.musicIndex = musicIndex
        this.effectIndex = effectIndex
        this.musicVolume = musicVolume
        this.effectVolume = effectVolume
    }

    fun onMixingFinished() {
        tvMusic1?.isSelected = false
        tvMusic1?.isSelected = false
    }

    fun onEffectFinish(id: Int) {
        when (id) {
            1 -> {
                tvEffect1?.isSelected = false
                tvEffect2?.isSelected = false
            }
            2 -> tvEffect2?.isSelected = false
        }
    }

    interface DialogActionsCallback {
        fun setMusicPlay(index: Int): Boolean
        fun onMusicVolumeChange(progress: Int)
        fun addEffect(index: Int): Boolean
        fun onEffectVolumeChange(progress: Int, index: IntArray)
        fun stopEffect(index: Int): Boolean
        fun stopMusicPlay()
    }
}