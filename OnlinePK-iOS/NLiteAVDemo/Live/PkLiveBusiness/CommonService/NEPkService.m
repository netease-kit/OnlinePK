//
//  NEPkService.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/11.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEPkService.h"
#import "NETSPkEnum.h"
#import "NEPKRewardTopParams.h"
#import "NERewardTopResponseModel.h"
#import "NEPKInviteConfigModel.h"

@implementation NEPkService

+ (instancetype)sharedPkService {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/// 请求pk
- (void)requestPkWithOperation:(NEPkOperation)action
               targetAccountId:(NSString *)accountId
                  successBlock:(nullable NETSRequestCompletion)successBlock
                   failedBlock:(nullable NETSRequestError)failedBlock {

    [self _pkCommonOperation:action targetAccountId:accountId successBlock:successBlock failedBlock:failedBlock];
}

- (void)cancelPkRequestWithOperation:(NEPkOperation)action
               targetAccountId:(NSString *)accountId
                  successBlock:(nullable NETSRequestCompletion)successBlock
                         failedBlock:(nullable NETSRequestError)failedBlock {
    [self _pkCommonOperation:action targetAccountId:accountId successBlock:successBlock failedBlock:failedBlock];
}



- (void)acceptPkWithOperation:(NEPkOperation)action
               targetAccountId:(NSString *)accountId
                  successBlock:(nullable NETSRequestCompletion)successBlock
                  failedBlock:(nullable NETSRequestError)failedBlock {
    [self _pkCommonOperation:action targetAccountId:accountId successBlock:successBlock failedBlock:failedBlock];
}


- (void)rejectPkRequestWithOperation:(NEPkOperation)action
               targetAccountId:(NSString *)accountId
                  successBlock:(nullable NETSRequestCompletion)successBlock
                         failedBlock:(nullable NETSRequestError)failedBlock {
    [self _pkCommonOperation:action targetAccountId:accountId successBlock:successBlock failedBlock:failedBlock];
}

//pk操作公共请求方法
- (void)_pkCommonOperation:(NEPkOperation)action
               targetAccountId:(NSString *)accountId
                  successBlock:(nullable NETSRequestCompletion)successBlock
               failedBlock:(nullable NETSRequestError)failedBlock {
    
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/pk/v1/inviteControl";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"action"  :  @(action),
        @"targetAccountId"  :  accountId
    };
    options.modelMapping = @[
//        [NETSApiModelMapping mappingWith:@"/" mappingClass:[NSDictionary class]  isArray:NO]
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NEPKInviteConfigModel class] isArray:NO],
    ];
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = successBlock;
    resuest.errorBlock = failedBlock;
    [resuest asyncRequest];

}


- (void)closePkLiveSuccessBlock:(nullable NETSRequestCompletion)successBlock
                    failedBlock:(nullable NETSRequestError)failedBlock{
    
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/pk/v1/end";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
       
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/" mappingClass:[NSDictionary class]  isArray:NO]
    ];
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = successBlock;
    resuest.errorBlock = failedBlock;
    [resuest asyncRequest];
}



- (void)requestRewardTopWithParams:(NEPKRewardTopParams *)params
                   successBlock:(nullable NETSRequestCompletion)successBlock
                       failedBlock:(nullable NETSRequestError)failedBlock {
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/pk/v1/rewardTop";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"roomId":params.roomId,
        @"giftId":params.pkId
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NERewardTopResponseModel class]  isArray:NO]
    ];
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = successBlock;
    resuest.errorBlock = failedBlock;
    [resuest asyncRequest];
}

@end
