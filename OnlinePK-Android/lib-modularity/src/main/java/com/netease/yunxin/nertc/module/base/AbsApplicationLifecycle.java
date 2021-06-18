/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.yunxin.nertc.module.base;

import android.app.Application;

public abstract class AbsApplicationLifecycle {
    private final String moduleName;

    public AbsApplicationLifecycle(String moduleName) {
        this.moduleName = moduleName;
    }

    public String getModuleName() {
        return moduleName;
    }

    protected abstract void onModuleCreate(Application application);
}
