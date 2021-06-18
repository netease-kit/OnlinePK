/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.liveroom;

import com.netease.biz_live.yunxin.live.liveroom.state.LiveState;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.avsignalling.builder.InviteParamBuilder;

public interface AnchorPk extends LiveStateService{
    /**
     * 邀请直播
     *
     * @param selfAccid         自己的im id
     * @param accountId         accid
     * @param pkLiveCid
     * @param cdnURL            推流地址
     * @param selfNickname      自己的昵称
     * @param pkRequestCallback
     */
    void requestPk(String selfAccid, String accountId, String pkLiveCid, String cdnURL, String selfNickname, LiveRoomCallback pkRequestCallback);

    /**
     * 接受PK
     *
     * @param pkLiveCid  pk直播间cid
     * @param accountId
     * @param requestId
     * @param accId
     * @param pkCallback
     */
    void acceptPk(String pkLiveCid, String accountId, String requestId, String accId, LiveRoomCallback pkCallback);



    /**
     * 拒绝pk邀请
     *
     * @param inviteParam
     * @param callback
     */
    void rejectPkRequest(InviteParamBuilder inviteParam, LiveRoomCallback callback);


    /**
     * 取消邀请
     *
     * @param callback
     */
    void cancelPkRequest(RequestCallback<Void> callback, boolean byUser);
}
