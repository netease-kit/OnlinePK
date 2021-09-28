/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live

import android.content.Context
import com.netease.biz_live.yunxin.live.ui.LiveListActivity

/**
 * Created by luc on 2020/11/10.
 */
class LiveServiceImpl : LiveService {

    override fun onInit(context: Context) {}
    override fun launchPkLive(context: Context, title: String, type: Int) {
        LiveListActivity.launchLiveList(context, title, type)
    }
}