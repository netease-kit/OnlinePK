/*
 * // Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * // Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

package com.netease.biz_live.yunxin.live.chatroom.custom;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import com.netease.biz_live.yunxin.live.chatroom.model.AudienceInfo;
import com.netease.biz_live.yunxin.live.chatroom.model.RewardGiftInfo;

import java.util.List;

/**
 * Created by luc on 2020/11/18.
 * <p>
 * 主播云币变化通知
 */
public class AnchorCoinChangedAttachment extends BaseCustomAttachment {
    /**
     * 打赏礼物id
     */
    @SerializedName("giftId")
    public long giftId;
    /**
     * 打赏主播id
     */
    @SerializedName("fromUserAvRoomUid")
    public String toAnchorId;
    /**
     * 打赏用户昵称
     */
    @SerializedName("nickname")
    public String nickname;
    /**
     * 当前主播云币总数
     */
    @SerializedName("totalCoinCount")
    public long totalCoinCount;
    /**
     * 当前主播 pk 值
     */
    @SerializedName("PKCoinCount")
    public long pkCoinCount;
    /**
     * 对方主播 pk 值
     */
    @SerializedName("otherPKCoinCount")
    public long otherPkCoinCount;
    /**
     * 当前主播贡献观众榜单
     */
    @SerializedName("rewardList")
    public List<AudienceInfo> rewardList;

    /**
     * 对方主播贡献观众榜单
     */
    @SerializedName("otherRewardList")
    public List<AudienceInfo> otherRewardList;


    public AnchorCoinChangedAttachment(String toAnchorId, long totalCoinCount, RewardGiftInfo rewardGiftInfo) {
        this(toAnchorId, totalCoinCount, rewardGiftInfo, 0, 0, null, null);
    }

    public AnchorCoinChangedAttachment(String toAnchorId,
                                       long totalCoinCount,
                                       RewardGiftInfo info,
                                       long pkCoinCount,
                                       long otherPkCoinCount,
                                       List<AudienceInfo> rewardList,
                                       List<AudienceInfo> otherRewardList) {
        this.type = CustomAttachmentType.CHAT_ROOM_ANCHOR_COIN_CHANGED;
        this.toAnchorId = toAnchorId;
        this.totalCoinCount = totalCoinCount;
        this.pkCoinCount = pkCoinCount;
        this.otherPkCoinCount = otherPkCoinCount;
        this.rewardList = rewardList;
        this.otherRewardList = otherRewardList;
        this.giftId = info.giftId;
        this.nickname = info.rewardNickname;
    }

    @Override
    public String toJson(boolean send) {
        return new Gson().toJson(this);
    }
}
