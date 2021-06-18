/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.constant;

/**
 * 回应报麦请求 action
 */
public @interface RespondSeatPickAction {
    /**
     * 同意
     */
    int AGREE = 0;
    /**
     * 拒绝
     */
    int REJECT = 1;
    /**
     * 忽略
     */
    int IGNORE = 2;
}
