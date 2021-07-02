//
//  NETSLiveUtils.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/9.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSLiveUtils.h"
#import "NETSLiveConfig.h"
#import <NERtcSDK/NERtcSDK.h>

@implementation NETSLiveUtils

+ (nullable NETSGiftModel *)getRewardWithGiftId:(NSInteger)giftId
{
    NETSGiftModel *gift = nil;
    for (NETSGiftModel *tmp in [NETSLiveConfig shared].gifts) {
        if (tmp.giftId == giftId) {
            gift = tmp;
            break;
        }
    }
    return gift;
}

+ (nullable NSDictionary *)gitInfo
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *gitSHA = [infoDict objectForKey:@"GitCommitSHA"];
    NSString *gitBranch = [infoDict objectForKey:@"GitCommitBranch"];
    NSString *gitCommitUser = [infoDict objectForKey:@"GitCommitUser"];
    NSString *gitCommitDate = [infoDict objectForKey:@"GitCommitDate"];
    
    NSDictionary *gitDict = @{
        @"gitSHA" : gitSHA ?: @"nil",
        @"gitBranch" : gitBranch ?: @"nil",
        @"gitCommitUser" : gitCommitUser ?: @"nil",
        @"gitCommitDate" : gitCommitDate ?: @"nil"
    };
    return gitDict;
}

@end
