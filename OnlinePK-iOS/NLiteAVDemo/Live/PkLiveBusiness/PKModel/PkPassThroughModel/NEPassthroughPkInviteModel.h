//
//  NEPkPassthroughInviteModel.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/18.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface NEPkInviteActionAnchorModel : NSObject
//房间编号
@property(nonatomic, strong) NSString *roomId;
//音视频房间名称
@property(nonatomic, strong) NSString *channelName;
//用户编号
@property(nonatomic, strong) NSString *accountId;
//昵称
@property(nonatomic, strong) NSString *nickname;
//头像地址
@property(nonatomic, strong) NSString *avatar;
//PK 直播获取云币数
@property(nonatomic, assign) int64_t rewardTotal;

@end

@interface NEPkInviteTargetAnchorModel : NSObject
//房间用户 UID
@property(nonatomic, strong) NSString *roomUid;
//房间校验码
@property(nonatomic, strong) NSString *checkSum;

@end


@interface NEPassthroughPkInviteModel : NSObject

@property(nonatomic, strong) NSString *senderAccountId;
//发送消息时间
@property(nonatomic, assign) int64_t sendTime;
//pk操作类型
@property(nonatomic, assign) NSInteger action;
//失败原因。1：邀请超时，2：加入房间失败 3 主播退出房间
@property(nonatomic, assign) NSInteger reason;
//进行操作主播
@property(nonatomic, strong) NEPkInviteActionAnchorModel *actionAnchor;
//目标主播
@property(nonatomic, strong) NEPkInviteTargetAnchorModel *targetAnchor;

@end



NS_ASSUME_NONNULL_END
