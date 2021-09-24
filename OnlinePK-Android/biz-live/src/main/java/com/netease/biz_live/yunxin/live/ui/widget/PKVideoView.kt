/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.ui.widget

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.LinearLayout
import com.netease.biz_live.R
import com.netease.lava.nertc.sdk.video.NERtcVideoView

class PKVideoView : LinearLayout {
    private var localVideo: NERtcVideoView? = null
    private var remoteVideo: NERtcVideoView? = null

    constructor(context: Context?) : super(context) {
        initView()
    }

    constructor(context: Context?, attrs: AttributeSet?) : super(context, attrs) {
        initView()
    }

    constructor(context: Context?, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        initView()
    }

    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.pk_video_view_layout, this, true)
        localVideo = findViewById(R.id.local_video)
        remoteVideo = findViewById(R.id.remote_video)
    }

    fun getLocalVideo(): NERtcVideoView? {
        return localVideo
    }

    fun getRemoteVideo(): NERtcVideoView? {
        return remoteVideo
    }
}