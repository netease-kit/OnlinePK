/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.dialog

import android.view.View
import android.widget.ImageView
import android.widget.SeekBar
import android.widget.SeekBar.OnSeekBarChangeListener
import android.widget.TextView
import com.netease.biz_live.R

/**
 * 美颜Dialog
 */
class BeautyDialog : BaseBottomDialog(), OnSeekBarChangeListener {
    private var sbBeautyWhite: SeekBar? = null
    private var sbBeautySkin: SeekBar? = null
    private var sbThinFace: SeekBar? = null
    private var sbBigEye: SeekBar? = null
    private var tvBeautyWhiteValue: TextView? = null
    private var tvBeautySkinValue: TextView? = null
    private var tvThinFaceValue: TextView? = null
    private var tvBigEyeValue: TextView? = null
    private var ivReset: ImageView? = null
    private var valueChangeListener: BeautyValueChangeListener? = null

    //*******************美颜参数*******************
    private var mColorLevel = 0.3f //美白
    private var mBlurLevel = 0.7f //磨皮程度
    private var mCheekThinning = 0f //瘦脸
    private var mEyeEnlarging = 0.4f //大眼
    override fun getResourceLayout(): Int {
        return R.layout.beauty_dialog_layout
    }

    override fun initView(rootView: View) {
        super.initView(rootView)
        ivReset = rootView.findViewById(R.id.iv_reset)
        ivReset?.setOnClickListener(View.OnClickListener { resetBeauty() })
        tvBeautyWhiteValue = rootView.findViewById(R.id.tv_beauty_white_value)
        sbBeautyWhite = rootView.findViewById(R.id.sb_beauty_white)
        sbBeautyWhite?.setOnSeekBarChangeListener(this)
        tvBeautySkinValue = rootView.findViewById(R.id.tv_beauty_skin_value)
        sbBeautySkin = rootView.findViewById(R.id.sb_beauty_skin)
        sbBeautySkin?.setOnSeekBarChangeListener(this)
        tvThinFaceValue = rootView.findViewById(R.id.tv_thin_face_value)
        sbThinFace = rootView.findViewById(R.id.sb_thin_face)
        sbThinFace?.setOnSeekBarChangeListener(this)
        tvBigEyeValue = rootView.findViewById(R.id.tv_big_eye_value)
        sbBigEye = rootView.findViewById(R.id.sb_big_eye)
        sbBigEye?.setOnSeekBarChangeListener(this)
    }

    fun setValueChangeListener(beautyValueChangeListener: BeautyValueChangeListener?) {
        valueChangeListener = beautyValueChangeListener
    }

    /**
     * 恢复默认
     */
    private fun resetBeauty() {
        mColorLevel = mColorLevelDefault
        mBlurLevel = mBlurLevelDefault
        mCheekThinning = mCheekThinningDefault
        mEyeEnlarging = mEyeEnlargingDefault
        setSbProcess()
    }

    /**
     * 设置美颜参数
     *
     * @param mColorLevel
     * @param mBlurLevel
     * @param mCheekThinning
     * @param mEyeEnlarging
     */
    fun setBeautyParams(
        mColorLevel: Float,
        mBlurLevel: Float, mCheekThinning: Float, mEyeEnlarging: Float
    ) {
        this.mColorLevel = mColorLevel
        this.mBlurLevel = mBlurLevel
        this.mCheekThinning = mCheekThinning
        this.mEyeEnlarging = mEyeEnlarging
    }

    override fun initData() {
        setSbProcess()
    }

    private fun setSbProcess() {
        sbBeautyWhite?.progress = (mColorLevel * 100).toInt()
        sbBeautySkin?.progress = (mBlurLevel * 100).toInt()
        sbThinFace?.progress = (mCheekThinning * 100).toInt()
        sbBigEye?.progress = (mEyeEnlarging * 100).toInt()
    }

    override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
        valueChangeListener?.beautyValueChange(setValueGetType(seekBar, progress), progress)
    }

    override fun onStartTrackingTouch(seekBar: SeekBar?) {}
    override fun onStopTrackingTouch(seekBar: SeekBar?) {}

    /**
     * 设置变量数值，并返回type，在value变化时调用
     *
     * @param seekBar
     * @return
     */
    private fun setValueGetType(seekBar: SeekBar?, value: Int): Int {
        val text = (value / 100f).toString()
        if (seekBar === sbBeautyWhite) {
            tvBeautyWhiteValue?.text = text
            return BeautyValueChangeListener.BEAUTY_WHITE
        } else if (seekBar === sbBeautySkin) {
            tvBeautySkinValue?.text = text
            return BeautyValueChangeListener.BEAUTY_SKIN
        } else if (seekBar === sbThinFace) {
            tvThinFaceValue?.text = text
            return BeautyValueChangeListener.THIN_FACE
        } else if (seekBar === sbBigEye) {
            tvBigEyeValue?.text = text
            return BeautyValueChangeListener.BIG_EYE
        }
        return 0
    }

    interface BeautyValueChangeListener {
        open fun beautyValueChange(type: Int, newValue: Int)

        companion object {
            const val BEAUTY_WHITE = 1
            const val BEAUTY_SKIN = 2
            const val THIN_FACE = 3
            const val BIG_EYE = 4
        }
    }

    companion object {
        //*****************美颜默认参数******************
        private const val mColorLevelDefault = 0.3f //美白
        private const val mBlurLevelDefault = 0.7f //磨皮程度
        private const val mCheekThinningDefault = 0f //瘦脸
        private const val mEyeEnlargingDefault = 0.4f //大眼
    }
}