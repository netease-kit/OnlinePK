/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.constant;

/**
 * Created by luc on 2020/11/27.
 * <p>
 * 直播类型
 */
public @interface LiveType {
    /**
     * 正常直播
     */
    int NORMAL_LIVING = 2;
    /**
     * pk 直播
     */
    int PK_LIVING = 3;

    /**
     * 忽略类型，如观众端使用
     */
    int TYPE_IGNORE = 0;
}
