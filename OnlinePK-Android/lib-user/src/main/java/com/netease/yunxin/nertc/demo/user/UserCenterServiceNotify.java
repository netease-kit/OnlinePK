/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.yunxin.nertc.demo.user;

/**
 * Created by luc on 2020/11/12.
 */
public interface UserCenterServiceNotify {
    /**
     * 当用户登录时调用
     *
     * @param success 登录是否成功
     */
    void onUserLogin(boolean success, int code);

    /**
     * 当用户退出时调用
     *
     * @param success 登出是否成功
     */
    void onUserLogout(boolean success, int code);

    /**
     * 出错回调
     *
     * @param exception 错误
     */
    void onError(Throwable exception);

    /**
     * 用户信息更新
     *
     * @param model 更新后的用户信息
     */
    void onUserInfoUpdate(UserModel model);
}
