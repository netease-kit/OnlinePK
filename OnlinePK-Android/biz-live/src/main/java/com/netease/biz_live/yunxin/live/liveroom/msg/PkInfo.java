/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom.msg;

public class PkInfo {

    /**
     * 发起者的昵称
     */
    public String inviterNickname;

    /**
     * pk 的cid
     */
    public String pkLiveCid;

    public PkInfo(String pkLiveCid, String inviterNickname) {
        this.inviterNickname = inviterNickname;
        this.pkLiveCid = pkLiveCid;
    }
}
