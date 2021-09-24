//
//  NERewardTopResponseModel.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NERewardTopResponseModel.h"


@implementation NERewardTopResponseSubModel

@end

@implementation NERewardTopResponseModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    
  return @{@"rewardTop" : [NERewardTopResponseSubModel class]};
}

- (nullable NSArray<NSString *> *)rewardAvatars {
    return [self _avatarFromArray:_rewardTop];
}

- (nullable NSArray<NSString *> *)_avatarFromArray:(nullable NSArray<NERewardTopResponseSubModel *> *)array {
    if (!array) {
        return nil;
    }
    NSMutableArray *res = [NSMutableArray arrayWithCapacity:[array count]];
    for (NERewardTopResponseSubModel *user in array) {
        NSString *avatar = user.avatar;
        [res addObject:avatar];
    }
    return [res copy];
}

@end








