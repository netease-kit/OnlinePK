/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.constant;

public @interface  ErrorCode {
    /**
     * 断开连接
     */
    int ERROR_CODE_DISCONNECT = 3001;

    /**
     * nertc 被回收
     */
    int ERROR_CODE_ENGINE_NULL = 3002;

    /**
     * 已经接受等待时进入超时
     */
    int ERROR_CODE_TIME_OUT_ACCEPTED = 4001;

    /**
     * 呼叫超时
     */
    int ERROR_CODE_TIME_OUT_CALL_OUT = 4002;

    /**
     * 接收超时
     */
    int ERROR_CODE_TIME_OUT_ACCEPT = 4003;

    /**
     * 状态错误
     */
    int ERROR_CODE_STATE_ERROR = 4004;

    /**
     * 直播频道不存在
     */
    int CREATE_LIVE_NOT_EXIST = 655;
}
