//
//  NERewardTopResponseModel.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NERewardTopResponseSubModel : NSObject
//用户编号
@property(nonatomic, strong) NSString *accountId;
//IM 用户编号
@property(nonatomic, strong) NSString *imAccid;
//昵称
@property(nonatomic, strong) NSString *nickname;
//头像
@property(nonatomic, strong) NSString *avatar;
//打赏金额
@property(nonatomic, assign) int64_t  rewardCoin;

@end

@interface NERewardTopResponseModel : NSObject
@property(nonatomic, strong) NSArray <NERewardTopResponseSubModel *> *rewardTop;
//打赏总金额
@property(nonatomic, assign) int64_t rewardCoinTotal;

/// 打赏者头像
- (nullable NSArray<NSString *> *)rewardAvatars;
@end

NS_ASSUME_NONNULL_END
