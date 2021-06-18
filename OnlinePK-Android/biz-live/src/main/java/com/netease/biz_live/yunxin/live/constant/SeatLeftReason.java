/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.constant;

/**
 * 麦位离开理由
 */
public @interface SeatLeftReason {
    /**
     * 正常
     */
    int NORMAL=0;
    /**
     * 被踢
     */
    int KICKED=1;
    /**
     * 断线
     */
    int OFFLINE=2;
}
