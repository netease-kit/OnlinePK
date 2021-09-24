//
//  NEPkPassthroughService.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/17.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NEPassthroughPkInviteModel,NEPassthroughPkStartModel,NEPassthroughStartPunishModel,NEPassthroughPkEndModel,NEPassthroughPkRewardModel;

@protocol NEPkPassthroughServiceDelegate <NSObject>
/// 收到pk邀请的消息
/// @param data 透传数据
- (void)receivePassThrourhPKInviteData:(NEPassthroughPkInviteModel *)data;

/// 同意pk邀请消息
/// @param data 透传数据
- (void)receivePassThrourhAgreePkData:(NEPassthroughPkInviteModel *)data;

/// 拒绝pk邀请消息
/// @param data 透传数据
- (void)receivePassThrourhRefusePKInviteData:(NEPassthroughPkInviteModel *)data;

/// 取消pk邀请消息
/// @param data 透传数据
- (void)receivePassThrourhCancelPKInviteData:(NEPassthroughPkInviteModel *)data;

/// pk超时操作消息
/// @param data 透传数据
- (void)receivePassThrourhTimeOutData:(NEPassthroughPkInviteModel *)data;


@end

@interface NEPkPassthroughService : NSObject<NIMPassThroughManagerDelegate>

@property(nonatomic, weak) id<NEPkPassthroughServiceDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
