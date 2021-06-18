/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live;

import android.content.Context;
import android.content.Intent;

import com.netease.biz_live.yunxin.live.ui.LiveListActivity;

/**
 * Created by luc on 2020/11/10.
 */
public class LiveServiceImpl implements LiveService {

    @Override
    public void onInit(Context context) {

    }

    @Override
    public void launchPkLive(Context context, String title) {
        LiveListActivity.launchLiveList(context,title);
    }
}
