//
//  NEPkInfoModel.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/24.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NERewardTopResponseModel.h"
NS_ASSUME_NONNULL_BEGIN


@interface NEPkInfoSubModel : NSObject
@property(nonatomic, strong) NSString *roomId;
@property(nonatomic, assign) int64_t roomUid;
@property(nonatomic, strong) NSString *accountId;
@property(nonatomic, strong) NSString *nickname;
@property(nonatomic, strong) NSString *avatar;
@property(nonatomic, assign) int64_t rewardTotal;
@end






@interface NEPkInfoModel : NSObject
@property(nonatomic, assign) int64_t appId;
@property(nonatomic, strong) NSString *pkId;
//PK 下表示 PK倒计时剩余时间 ,惩罚表示 惩罚倒计时剩余时间
@property(nonatomic, assign) int32_t countDown;

@property(nonatomic, assign) NEPKStatus status;
@property(nonatomic, assign) int64_t pkStartTime;
@property(nonatomic, assign) int64_t pkEndTime;
@property(nonatomic, strong) NEPkInfoSubModel *inviter;
@property(nonatomic, strong) NEPkInfoSubModel *invitee;
@property(nonatomic, strong) NERewardTopResponseModel *inviterReward;
@property(nonatomic, strong) NERewardTopResponseModel *inviteeReward;

@end


NS_ASSUME_NONNULL_END
