/*
 * Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom;

import com.netease.biz_live.yunxin.live.liveroom.msg.PkInfo;
import com.netease.biz_live.yunxin.live.model.message.MsgPkStart;
import com.netease.biz_live.yunxin.live.model.message.MsgPunishStart;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.avsignalling.event.InvitedEvent;

/**
 * PK接口回调服务
 */
public interface AnchorPkDelegate {
    /**
     * PK开始，（由IM消息触发）
     */
    void onPkStart(MsgPkStart.StartPkBody startPKBody);

    /**
     * 惩罚开始（由IM消息触发）
     *
     * @param punishBody
     */
    void onPunishStart(MsgPunishStart.PunishBody punishBody);

    /**
     * pk结束（由IM消息触发）
     */
    void onPkEnd(boolean isFromUser, String nickname);


    /**
     * pk 邀请被取消，
     * 可由邀请方调用{@link AnchorPk#cancelPkRequest(RequestCallback, boolean)} 取消
     *
     * @param byUser 是否是由用户主动取消的
     */
    void onPkRequestCancel(boolean byUser);

    /**
     * 收到PK邀请 邀请方调用{@link AnchorPk#requestPk(String, String, String, String, String, LiveRoomCallback)}，
     * 被邀请方收到此方法回调
     *
     * @param invitedEvent
     * @param pkInfo
     */
    void receivePkRequest(InvitedEvent invitedEvent, PkInfo pkInfo);

    /**
     * pk 邀请被拒绝
     *
     * @param userId
     */
    void pkRequestRejected(String userId);

    /**
     * 邀请被接受，正式进入Pk准备阶段
     */
    void onAccept();


    /**
     * 加入rtc 房间之前调用，获取checkSum，并站位
     *
     * @param liveCid
     * @param isPk
     * @param parentLiveCid
     */
    void preJoinRoom(String liveCid, boolean isPk, String parentLiveCid);

    /**
     * 超时
     *
     * @param code 超时code
     */
    void onTimeOut(int code);

    /**
     * 邀请方忙线
     *
     * @param userId 忙线用户
     */
    void onUserBusy(String userId);
}
