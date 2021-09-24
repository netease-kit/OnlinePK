/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.ui

import android.hardware.Camera
import android.hardware.Camera.CameraInfo
import androidx.fragment.app.FragmentActivity
import com.beautyFaceunity.FURenderer
import com.netease.biz_live.yunxin.live.dialog.BeautyDialog
import com.netease.biz_live.yunxin.live.dialog.BeautyDialog.BeautyValueChangeListener
import com.netease.biz_live.yunxin.live.dialog.FilterDialog
import com.netease.lava.nertc.sdk.video.NERtcVideoFrame
import com.netease.yunxin.lib_live_room_service.impl.VideoOption

/**
 * 美颜相关控制
 */
class BeautyControl(private val activity: FragmentActivity) {
    private val mFuRender by lazy {
        FURenderer.Builder(activity)
            .maxFaces(1)
            .inputImageOrientation(getCameraOrientation(CameraInfo.CAMERA_FACING_FRONT))
            .inputTextureType(FURenderer.FU_ADM_FLAG_EXTERNAL_OES_TEXTURE)
            .build()
    }

    //*******************美颜参数*******************
    private var mColorLevel = 0.3f //美白
    private var mBlurLevel = 0.7f //磨皮程度
    private var mCheekThinning = 0f //瘦脸
    private var mEyeEnlarging = 0.4f //大眼
    private var beautyDialog: BeautyDialog? = null
    private var filterDialog: FilterDialog? = null
    fun initFaceUI() {
        mFuRender.onSurfaceCreated()
        mFuRender.setBeautificationOn(true)
    }

    fun openBeauty() {
        VideoOption.setVideoCallback({ neRtcVideoFrame: NERtcVideoFrame ->
            //此处可自定义第三方的美颜实现
            neRtcVideoFrame.textureId = mFuRender.onDrawFrame(
                neRtcVideoFrame.data, neRtcVideoFrame.textureId,
                neRtcVideoFrame.width, neRtcVideoFrame.height
            )
            neRtcVideoFrame.format = NERtcVideoFrame.Format.TEXTURE_RGB
            true
        }, true)
    }

    fun switchCamera(cameraFacing: Int) {
        mFuRender.onCameraChange(cameraFacing, getCameraOrientation(cameraFacing))
    }

    private fun getCameraOrientation(cameraFacing: Int): Int {
        val info = CameraInfo()
        var cameraId = -1
        val numCameras = Camera.getNumberOfCameras()
        for (i in 0 until numCameras) {
            Camera.getCameraInfo(i, info)
            if (info.facing == cameraFacing) {
                cameraId = i
                break
            }
        }
        return if (cameraId < 0) {
            // no front camera, regard it as back camera
            90
        } else {
            info.orientation
        }
    }

    /**
     * 展示美颜dialog
     */
    fun showBeautyDialog() {
        if (beautyDialog == null) {
            beautyDialog = BeautyDialog()
        }
        beautyDialog?.setBeautyParams(mColorLevel, mBlurLevel, mCheekThinning, mEyeEnlarging)
        beautyDialog?.setValueChangeListener(object :BeautyValueChangeListener {
            override fun beautyValueChange(type: Int, newValue: Int) {
                when (type) {
                    BeautyValueChangeListener.BEAUTY_WHITE -> {
                        mColorLevel = newValue / 100f
                        mFuRender.onColorLevelSelected(mColorLevel)
                    }
                    BeautyValueChangeListener.BEAUTY_SKIN -> {
                        mBlurLevel = newValue / 100f
                        mFuRender.onBlurLevelSelected(mBlurLevel)
                    }
                    BeautyValueChangeListener.THIN_FACE -> {
                        mCheekThinning = newValue / 100f
                        mFuRender.onCheekThinningSelected(mCheekThinning)
                    }
                    BeautyValueChangeListener.BIG_EYE -> {
                        mEyeEnlarging = newValue / 100f
                        mFuRender.onEyeEnlargeSelected(mEyeEnlarging)
                    }
                }
            }
        })
        beautyDialog?.show(activity.supportFragmentManager, "beautyDialog")
    }

    fun showFilterDialog() {
        if (filterDialog == null) {
            filterDialog = FilterDialog()
        }
        filterDialog?.setOnFUControlListener(mFuRender)
        filterDialog?.show(activity.supportFragmentManager, "filterDialog")
    }

    fun onDestroy() {
        VideoOption.setVideoCallback(null, false)
        if (mFuRender != null) {
            mFuRender.onSurfaceDestroyed()
        }
    }

    fun dismissAllDialog() {
        if (beautyDialog != null && beautyDialog?.dialog != null
            && beautyDialog?.dialog?.isShowing == true
        ) {
            beautyDialog?.dismiss()
        }
        if (filterDialog != null && filterDialog?.dialog != null
            && filterDialog?.dialog?.isShowing == true
        ) {
            filterDialog?.dismiss()
        }
    }
}