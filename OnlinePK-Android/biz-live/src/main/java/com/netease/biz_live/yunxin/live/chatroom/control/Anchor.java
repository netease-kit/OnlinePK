/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.chatroom.control;

import com.netease.biz_live.yunxin.live.chatroom.custom.AnchorCoinChangedAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PkStatusAttachment;
import com.netease.biz_live.yunxin.live.chatroom.custom.PunishmentStatusAttachment;

/**
 * Created by luc on 2020/11/18.
 * <p>
 * 主播聊天室控制
 */
public interface Anchor extends Member {
    /**
     * 通知 pk 状态
     *
     * @param pkStatus pk 数据
     */
    void notifyPkStatus(PkStatusAttachment pkStatus);

    /**
     * 开始惩罚
     *
     * @param punishmentStatus 惩罚数据
     */
    void notifyPunishmentStatus(PunishmentStatusAttachment punishmentStatus);

    /**
     * 主播云币变化
     *
     * @param attachment 变化数据
     */
    void notifyCoinChanged(AnchorCoinChangedAttachment attachment);

    /**
     * 获取主播端控制
     */
    static Anchor getInstance() {
        return new AnchorImpl();
    }
}
