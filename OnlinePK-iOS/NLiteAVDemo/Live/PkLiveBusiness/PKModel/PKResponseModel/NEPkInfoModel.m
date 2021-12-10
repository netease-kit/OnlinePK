//
//  NEPkInfoModel.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/24.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEPkInfoModel.h"

@implementation NEPkInfoSubModel



@end

@implementation NEPkInfoModel
+ (NSDictionary *)modelContainerPropertyGenericClass
{
  return @{@"inviter" : [NEPkInfoSubModel class],
           @"invitee":[NEPkInfoSubModel class],
           @"inviterReward":[NERewardTopResponseModel class],
           @"inviteeReward":[NERewardTopResponseModel class]
  };
}
@end
