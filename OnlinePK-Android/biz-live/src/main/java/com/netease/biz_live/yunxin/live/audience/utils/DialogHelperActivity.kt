/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.biz_live.yunxin.live.audience.utils

import android.os.Bundle
import android.view.View
import com.netease.biz_live.R
import com.netease.biz_live.yunxin.live.dialog.NotificationDialog
import com.netease.yunxin.nertc.demo.basic.BaseActivity
import com.netease.yunxin.nertc.demo.basic.StatusBarConfig

class DialogHelperActivity : BaseActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_transparen_helper)
        NotificationDialog(this)
            .setTitle(getString(R.string.biz_live_has_been_logout_by_other_devices))
            .setContent(getString(R.string.biz_live_multiple_login_tips))
            .setPositive(getString(R.string.biz_live_sure)) { v: View? -> finish() }
            .show()
    }

    override fun provideStatusBarConfig(): StatusBarConfig? {
        return StatusBarConfig.Builder()
            .statusBarDarkFont(false)
            .build()
    }
}