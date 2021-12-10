//
//  NEPkRewardParams.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEPkRewardParams : NSObject

//房间编号
@property(nonatomic, strong) NSString *roomId;
//礼物编号
@property(nonatomic, assign) NSInteger giftId;

@end

NS_ASSUME_NONNULL_END
