/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.constant;

/**
 * 摄像头操作，开启，关闭，强制关闭
 */
public @interface VideoActionType {
    int DEFAULT=-1;
    int CLOSE=0;
    int OPEN=1;
    int FORCE_CLOSE=2;
}
