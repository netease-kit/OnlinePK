/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.dialog

import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.netease.biz_live.R
import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.lava.nertc.sdk.video.NERtcEncodeConfig.NERtcVideoFrameRate

/**
 * 开播前设置Dialog
 */
class LiveSettingDialog : BaseBottomDialog() {
    private var tv1080P: TextView? = null
    private var tv720P: TextView? = null
    private var tv360P: TextView? = null
    private var tv30: TextView? = null
    private var tv24: TextView? = null
    private var tv15: TextView? = null
    private var tvNormal: TextView? = null
    private var tvMusic: TextView? = null
    private var ivReset: ImageView? = null
    private var valueChangeListener: LiveSettingChangeListener? = null

    //*******************直播参数*******************
    private var videoProfile = NERtcConstants.VideoProfile.HD720P //视频分辨率
    private var frameRate: NERtcVideoFrameRate =
        NERtcVideoFrameRate.FRAME_RATE_FPS_30 //码率
    private var audioScenario = NERtcConstants.AudioScenario.MUSIC //音频标准
    override fun getResourceLayout(): Int {
        return R.layout.live_setting_dialog_layout
    }

    override fun initView(rootView: View) {
        super.initView(rootView)
        ivReset = rootView.findViewById(R.id.iv_reset)
        ivReset?.setOnClickListener { resetBeauty() }
        tv1080P = rootView.findViewById(R.id.tv_1080p)
        tv1080P?.setOnClickListener {
            tv1080P?.isSelected = true
            tv720P?.isSelected = false
            tv360P?.isSelected = false
            valueChangeListener?.videoProfileChange(NERtcConstants.VideoProfile.HD1080p)
        }
        tv720P = rootView.findViewById(R.id.tv_720p)
        tv720P?.setOnClickListener {
            tv720P?.isSelected = true
            tv1080P?.isSelected = false
            tv360P?.isSelected = false
            valueChangeListener?.videoProfileChange(NERtcConstants.VideoProfile.HD720P)

        }
        tv360P = rootView.findViewById(R.id.tv_360p)
        tv360P?.setOnClickListener {
            tv360P?.isSelected = true
            tv1080P?.isSelected = false
            tv720P?.isSelected = false
            valueChangeListener?.videoProfileChange(NERtcConstants.VideoProfile.STANDARD)
        }
        tv30 = rootView.findViewById(R.id.tv_30)
        tv30?.setOnClickListener {
            tv30?.isSelected = true
            tv24?.isSelected = false
            tv15?.isSelected = false
            valueChangeListener?.frameRateChange(NERtcVideoFrameRate.FRAME_RATE_FPS_30)

        }
        tv24 = rootView.findViewById(R.id.tv_24)
        tv24?.setOnClickListener {
            tv30?.isSelected = false
            tv24?.isSelected = true
            tv15?.isSelected = false
            valueChangeListener?.frameRateChange(NERtcVideoFrameRate.FRAME_RATE_FPS_24)
        }
        tv15 = rootView.findViewById(R.id.tv_15)
        tv15?.setOnClickListener {
            tv30?.isSelected = false
            tv24?.isSelected = false
            tv15?.isSelected = true
            valueChangeListener?.frameRateChange(NERtcVideoFrameRate.FRAME_RATE_FPS_15)
        }
        tvMusic = rootView.findViewById(R.id.tv_music)
        tvMusic?.setOnClickListener {
            tvMusic?.isSelected = true
            tvNormal?.isSelected = false
            valueChangeListener?.audioScenarioChange(NERtcConstants.AudioScenario.MUSIC)
        }
        tvNormal = rootView.findViewById(R.id.tv_normal)
        tvNormal?.setOnClickListener {
            tvMusic?.isSelected = false
            tvNormal?.isSelected = true
            valueChangeListener?.audioScenarioChange(NERtcConstants.AudioScenario.CHATROOM)
        }
    }

    fun setValueChangeListener(liveSettingChangeListener: LiveSettingChangeListener?) {
        valueChangeListener = liveSettingChangeListener
    }

    /**
     * 恢复默认
     */
    private fun resetBeauty() {
        tv360P?.isSelected = false
        tv1080P?.isSelected = false
        tv720P?.isSelected = true
        tv30?.isSelected = true
        tv24?.isSelected = false
        tv15?.isSelected = false
        tvMusic?.isSelected = true
        tvNormal?.isSelected = false
        valueChangeListener?.let {
            it.audioScenarioChange(audioScenarioDefaul)
            it.frameRateChange(frameRateDefaul)
            it.videoProfileChange(videoProfileDefault)
        }
    }

    /**
     * 设置已有的直播参数
     *
     * @param videoProfile
     * @param frameRate
     * @param audioScenario
     */
    fun setLiveSetting(
        videoProfile: Int,
        frameRate: NERtcVideoFrameRate, audioScenario: Int
    ) {
        this.videoProfile = videoProfile
        this.frameRate = frameRate
        this.audioScenario = audioScenario
    }

    override fun initData() {
        when (videoProfile) {
            NERtcConstants.VideoProfile.STANDARD -> tv360P?.isSelected = true
            NERtcConstants.VideoProfile.HD720P -> tv720P?.isSelected = true
            NERtcConstants.VideoProfile.HD1080p -> tv1080P?.isSelected = true
            else -> {
            }
        }
        when (frameRate) {
            NERtcVideoFrameRate.FRAME_RATE_FPS_15 -> tv15?.isSelected = true
            NERtcVideoFrameRate.FRAME_RATE_FPS_24 -> tv24?.isSelected = true
            NERtcVideoFrameRate.FRAME_RATE_FPS_30 -> tv30?.isSelected = true
            else -> tv30?.isSelected = true
        }
        when (audioScenario) {
            NERtcConstants.AudioScenario.MUSIC -> tvMusic?.isSelected = true
            NERtcConstants.AudioScenario.CHATROOM -> tvNormal?.isSelected = true
            else -> tvNormal?.isSelected = true
        }
    }

    /**
     * 直播设置回调
     */
    interface LiveSettingChangeListener {
        fun videoProfileChange(newValue: Int)
        fun frameRateChange(frameRate: NERtcVideoFrameRate)
        fun audioScenarioChange(audioScenario: Int)
    }

    companion object {
        //*****************直播默认参数******************
        private const val videoProfileDefault = NERtcConstants.VideoProfile.HD720P //视频分辨率
        private val frameRateDefaul: NERtcVideoFrameRate =
            NERtcVideoFrameRate.FRAME_RATE_FPS_30 //码率
        private const val audioScenarioDefaul = NERtcConstants.AudioScenario.MUSIC //音频标准
    }
}