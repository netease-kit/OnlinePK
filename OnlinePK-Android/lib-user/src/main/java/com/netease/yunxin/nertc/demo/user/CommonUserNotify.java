/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.yunxin.nertc.demo.user;

/**
 * Created by luc on 2020/11/16.
 */
public abstract class CommonUserNotify implements UserCenterServiceNotify {

    @Override
    public void onUserLogin(boolean success, int code) {

    }

    @Override
    public void onUserLogout(boolean success, int code) {

    }

    @Override
    public void onError(Throwable exception) {

    }

    @Override
    public void onUserInfoUpdate(UserModel model) {

    }
}
