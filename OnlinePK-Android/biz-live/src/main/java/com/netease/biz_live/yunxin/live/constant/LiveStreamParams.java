/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.constant;

/**
 * 直播参数
 */
public interface LiveStreamParams {
    //****************直播推流layout参数start*******************
    int SIGNAL_HOST_LIVE_WIDTH = 720;

    int SIGNAL_HOST_LIVE_HEIGHT = 1280;

    int PK_LIVE_WIDTH = 360;

    int PK_LIVE_HEIGHT = 640;

    //麦位宽度
    int AUDIENCE_LINKED_WIDTH = 132;

    //麦位高度
    int AUDIENCE_LINKED_HEIGHT = 170;

    //观众麦位距离左侧
    int AUDIENCE_LINKED_LEFT_MARGIN = 575;

    //观众麦位距离顶部
    int AUDIENCE_LINKED_FIRST_TOP_MARGIN = 200;

    //观众麦位之间距离
    int AUDIENCE_LINKED_BETWEEN_MARGIN = 12;

    //****************直播推流layout参数end*********************
    /**
     * pk 状态下视频 宽高比
     */
    float WH_RATIO_PK = PK_LIVE_WIDTH * 2f / PK_LIVE_HEIGHT;
}
