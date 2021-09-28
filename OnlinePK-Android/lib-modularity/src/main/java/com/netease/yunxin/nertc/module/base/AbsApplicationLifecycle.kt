/*
 *  Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 *  Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */

package com.netease.yunxin.nertc.module.base

import android.app.Application

abstract class AbsApplicationLifecycle(val moduleName: String) {
    abstract fun onModuleCreate(application: Application)
}