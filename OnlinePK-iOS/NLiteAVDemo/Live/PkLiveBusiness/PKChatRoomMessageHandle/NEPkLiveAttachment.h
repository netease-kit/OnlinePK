//
//  NEPkLiveAttachment.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// PK直播自定义消息类型
typedef NS_ENUM(NSUInteger, NELiveAttachmentType) {
    NELiveAttachmentPkType        = 11,   // PK消息
    NELiveAttachmentPunishType    = 12,   // 惩罚消息
    NELiveAttachmentWealthType    = 14,   // 主播云币变化消息
    NELiveAttachmentTextType      = 15    // 文本消息
};


@interface NEPkLiveStartSubModel : NSObject
@property(nonatomic, strong) NSString *roomId;
@property(nonatomic, assign) int64_t roomUid;
@property(nonatomic, strong) NSString *accountId;
@property(nonatomic, strong) NSString *nickname;
@property(nonatomic, strong) NSString *avatar;
@property(nonatomic, assign) int64_t rewardTotal;
@end

//pk开始消息体
@interface NEPkLiveStartAttachment : NSObject<NIMCustomAttachment>
@property(nonatomic, assign) NEPKChatRoomMessageBody messageType;
@property(nonatomic, strong) NSString *senderAccountId;
//发送消息时间
@property(nonatomic, assign) int64_t sendTime;
//pk开始时间
@property(nonatomic, assign) int64_t pkStartTime;
//pk结束时间
@property(nonatomic, assign) int64_t pkCountDown;
@property(nonatomic, strong) NEPkLiveStartSubModel *inviter;
@property(nonatomic, strong) NEPkLiveStartSubModel *invitee;
@end



//pk惩罚消息体
@interface NEStartPunishAttachment : NSObject<NIMCustomAttachment>
@property(nonatomic, assign) NEPKChatRoomMessageBody messageType;
@property(nonatomic, strong) NSString *senderAccountId;
@property(nonatomic, assign) int64_t sendTime;
@property(nonatomic, assign) int64_t pkStartTime;
//PK 惩罚时间倒计时，单位：秒（s）
@property(nonatomic, assign) int32_t pkPenaltyCountDown;
@property(nonatomic, assign) int64_t inviterRewards;
@property(nonatomic, assign) int64_t inviteeRewards;
@end


//pk结束消息
@interface NEPkEndAttachment : NSObject<NIMCustomAttachment>
@property(nonatomic, assign) NEPKChatRoomMessageBody messageType;
//消息发送者用户编号
@property(nonatomic, strong) NSString *senderAccountId;
//发送消息时间
@property(nonatomic, assign) int64_t sendTime;
//PK开始时间
@property(nonatomic, assign) int64_t pkStartTime;
//PK结束时间
@property(nonatomic, assign) int64_t pkEndTime;
//邀请者打赏总额
@property(nonatomic, assign) int64_t inviterRewards;
//被邀请者打赏总额
@property(nonatomic, assign) int64_t inviteeRewards;
//结束pk主播的昵称
@property(nonatomic, strong) NSString *nickname;
//是否计时结束
@property(nonatomic, assign) BOOL countDownEnd;
@end



@interface NEPkRewardTopModel : NSObject
//用户编号
@property(nonatomic, strong) NSString *accountId;
//IM 用户编号
@property(nonatomic, strong) NSString *imAccid;
//昵称
@property(nonatomic, strong) NSString *nickname;
//头像地址
@property(nonatomic, strong) NSString *avatar;
//本 PK 直播时段打赏主播总额
@property(nonatomic, assign) int64_t rewardCoin;
@end


@interface NEAnchorRewardModel : NSObject
//用户编号
@property(nonatomic, strong) NSString *accountId;
//PK 时段打赏总额
@property(nonatomic, assign) int64_t pkRewardTotal;
//直播打赏总额
@property(nonatomic, assign) int32_t rewardTotal;
//PK 直播时段打赏排行（前三)
@property(nonatomic, strong) NSArray<NEPkRewardTopModel *>*pkRewardTop;

/// 打赏者头像
- (nullable NSArray<NSString *> *)rewardAvatars;
@end

//pk打赏消息体
@interface NEPkRewardAttachment : NSObject<NIMCustomAttachment>
@property(nonatomic, assign) NEPKChatRoomMessageBody messageType;
//消息发送者用户编号
@property(nonatomic, strong) NSString *senderAccountId;
//发送消息时间
@property(nonatomic, assign) int64_t sendTime;
//PK 开始时间
@property(nonatomic, assign) int64_t pkStartTime;
//打赏者用户编号
@property(nonatomic, strong) NSString *rewarderAccountId;
//打赏者昵称
@property(nonatomic, strong) NSString *rewarderNickname;
//礼物编号
@property(nonatomic, assign) int64_t giftId;
//房间人数
@property(nonatomic, assign) int64_t memberTotal;
//被打赏主播打赏信息
@property(nonatomic, strong) NEAnchorRewardModel *anchorReward;
//其他主播打赏信息
@property(nonatomic, strong) NEAnchorRewardModel *otherAnchorReward;
@end


/**
 文本消息序列化
 */
@interface NELiveTextAttachment : NSObject<NIMCustomAttachment>
@property (nonatomic, assign, readonly)   NELiveAttachmentType  type;
@property (nonatomic, assign)   BOOL                    isAnchor;
@property (nonatomic, copy)     NSString                *message;

@end


/**
 PK直播消息反序列化
 */
@interface NEPKLiveAttachmentDecoder : NSObject<NIMCustomAttachmentCoding>

@end
NS_ASSUME_NONNULL_END
