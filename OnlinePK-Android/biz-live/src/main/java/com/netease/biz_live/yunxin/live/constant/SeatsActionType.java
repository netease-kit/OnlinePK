/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.constant;

/**
 * @author sunkeding
 * 麦位操作type
 */
public @interface SeatsActionType {
    /**
     * 管理员同意上麦
     */
    int ADMIN_ACCEPT_JOIN_SEATS = 1;
    /**
     * 管理员主动邀请上麦
     */
    int ADMIN_INVITE_JOIN_SEATS = 2;
    /**
     * 管理员踢下麦
     */
    int ADMIN_KICK_SEATS = 3;
    /**
     * 上麦者下麦
     */
    int LINKED_AUDIENCE_LEAVE_SEATS = 4;
    /**
     * 观众申请上麦
     */
    int UNLINKED_AUDIENCE_APPLY_JOIN_SEATS = 5;
    /**
     * 观众取消上麦申请
     */
    int UNLINKED_AUDIENCE_CANCEL_APPLY_JOIN_SEATS = 6;
    /**
     * 管理员拒绝观众上麦申请
     */
    int ADMIN_REJECT_UNLINKED_AUDIENCE_JOIN_SEATS = 7;
    /**
     * 观众拒绝同意上麦
     */
    int UNLINKED_AUDIENCE_REJECT_JOIN_SEATS = 8;
    /**
     * 观众同意上麦
     */
    int UNLINKED_AUDIENCE_ACCEPT_JOIN_SEATS = 9;

    /**
     * 管理员取消屏蔽麦位
     */
    int ADMIN_REOPEN_SEATS = 10;

    /**
     * 管理员屏蔽麦位
     */
    int ADMIN_CLOSE_SEATS = 11;
    /**
     * 麦位音视频变化
     */
    int AV_CHANGE = 12;
}
