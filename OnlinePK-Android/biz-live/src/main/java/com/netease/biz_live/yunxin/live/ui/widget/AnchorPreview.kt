/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.ui.widget

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.View.OnClickListener
import android.widget.*
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.network.LiveInteraction
import com.netease.biz_live.yunxin.live.utils.SpUtils
import com.netease.yunxin.android.lib.network.common.BaseResponse
import com.netease.yunxin.android.lib.picture.ImageLoader
import io.reactivex.observers.ResourceSingleObserver

class AnchorPreview : FrameLayout {
    //摄像头翻转按钮
    var ivSwitchCamera: ImageView? = null

    //美颜
    var llyBeauty: LinearLayout? = null


    //滤镜
    var llyFilter: LinearLayout? = null
    private var edtTopic: EditText? = null
    var btnLiveCreate //开始直播
            : Button? = null

    //关闭
    var ivClose: ImageView? = null

    //封面
    private var ivCover: ImageView? = null

    //随机topic
    var ivRandom: ImageView? = null
    var ivRefreshPic: ImageView? = null
    private var liveCoverPic: String? = null

    constructor(context: Context) : super(context) {
        initView()
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        initView()
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        initView()
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.anchor_preview_layout, this)
        ivSwitchCamera = findViewById(R.id.iv_camera_switch)
        llyBeauty = findViewById(R.id.lly_beauty)
        llyFilter = findViewById(R.id.lly_filter)
        edtTopic = findViewById(R.id.edt_live_title)
        btnLiveCreate = findViewById(R.id.btn_start_live)
        ivClose = findViewById(R.id.iv_back)
        ivCover = findViewById(R.id.iv_cover)
        ivRandom = findViewById(R.id.iv_dice)
        ivRefreshPic = findViewById(R.id.iv_refresh_pic)
        getRandomCover()
        getRandomTopic()
        ivRandom?.setOnClickListener(OnClickListener { v: View? -> getRandomTopic() })
        ivRefreshPic?.setOnClickListener(OnClickListener { v: View? -> getRandomCover() })
    }

    /**
     * 获取随机封面
     */
    private fun getRandomCover() {
        LiveInteraction.getCover()
            ?.subscribe(object : ResourceSingleObserver<BaseResponse<String?>?>() {
                override fun onSuccess(stringBaseResponse: BaseResponse<String?>) {
                    if (stringBaseResponse.code == 200) {
                        liveCoverPic = stringBaseResponse.data
                        ImageLoader.with(context).roundedCorner(
                            stringBaseResponse.data, SpUtils.dp2pix(
                                context, 4f
                            ), ivCover
                        )
                    }
                }

                override fun onError(e: Throwable) {}
            })
    }

    private fun getRandomTopic() {
        LiveInteraction.getTopic()
            ?.subscribe(object : ResourceSingleObserver<BaseResponse<String?>?>() {
                override fun onSuccess(stringBaseResponse: BaseResponse<String?>) {
                    if (stringBaseResponse.code == 200) {
                        edtTopic?.setText(stringBaseResponse.data)
                    }
                }

                override fun onError(e: Throwable) {}
            })
    }

    fun getTopic(): String {
        return edtTopic?.text.toString().trim { it <= ' ' }
    }

    fun getLiveCoverPic(): String? {
        return liveCoverPic
    }

    fun setCreateEnable(enable: Boolean) {
        btnLiveCreate?.isEnabled = enable
    }
}