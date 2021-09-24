/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.demo.basic

import android.view.View
import androidx.fragment.app.Fragment

/**
 * Created by luc on 2020/11/13.
 */
open class BaseFragment : Fragment() {
    protected fun paddingStatusBarHeight(view: View?) {
        StatusBarConfig.paddingStatusBarHeight(activity, view)
    }
}