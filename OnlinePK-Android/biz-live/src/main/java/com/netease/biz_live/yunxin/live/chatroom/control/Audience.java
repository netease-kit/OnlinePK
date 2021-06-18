/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.chatroom.control;

/**
 * Created by luc on 2020/11/18.
 * <p>
 * 观众聊天室控制
 */
public interface Audience extends Member {


    /**
     * 获取观众端控制
     */
    static Audience getInstance() {
        return new AudienceImpl();
    }
}
