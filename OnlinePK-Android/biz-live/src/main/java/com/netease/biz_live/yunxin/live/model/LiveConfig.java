/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.model;

import java.io.Serializable;

/**
 * 直播参数
 */
public class LiveConfig implements Serializable {
    public String httpPullUrl;//String	直播拉流地址
    public String rtmpPullUrl;//String rtmp直播拉流地址
    public String hlsPullUrl;//Stringhls拉流地址
    public String pushUrl;//String	推流地址pushUrl
    public String cid;// String	直播频道Cid
}
