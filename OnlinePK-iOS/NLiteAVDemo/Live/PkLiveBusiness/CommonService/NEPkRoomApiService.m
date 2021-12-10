//
//  NEPkRoomApiService.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/13.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEPkRoomApiService.h"
#import "NEPkCreateRoomParams.h"
#import "NEPkEnterRoomParams.h"
#import "NEPkDestroyRoomParams.h"
#import "NECreateRoomResponseModel.h"
#import "NELiveRoomListModel.h"
#import "NEPkInfoModel.h"
#import "NEPkRewardParams.h"
#import "NESeatInfoFilterModel.h"

@implementation NEPkRoomApiService

- (void)createRoomWithParams:(NEPkCreateRoomParams *)params
               successBlock:(nullable NETSRequestCompletion)successBlock
                failedBlock:(nullable NETSRequestError)failedBlock {
    
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/live/v1/create";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"roomTopic" : params.roomTopic,
        @"cover"     : params.cover,
        @"roomType"  : @(params.roomType),
        @"pushType"  : @(params.pushType)
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NECreateRoomResponseModel class]  isArray:NO]
    ];
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = successBlock;
    resuest.errorBlock = failedBlock;
    [resuest asyncRequest];
}

- (void)destroyRoomWithParams:(NEPkDestroyRoomParams *)params
               successBlock:(nullable NETSRequestCompletion)successBlock
                  failedBlock:(nullable NETSRequestError)failedBlock {
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/live/v1/close";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"roomId" : params.roomId,
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/" mappingClass:[NSDictionary class]  isArray:NO]
    ];
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = successBlock;
    resuest.errorBlock = failedBlock;
    [resuest asyncRequest];
}

- (void)enterRoomWithParams:(NEPkEnterRoomParams *)params
               successBlock:(nullable NETSRequestCompletion)successBlock
               failedBlock:(nullable NETSRequestError)failedBlock {
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/live/v1/join";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"roomId" : params.roomId,
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/" mappingClass:[NSDictionary class]  isArray:NO]
    ];
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = successBlock;
    resuest.errorBlock = failedBlock;
    [resuest asyncRequest];
}

- (void)requestLiveRoomListWithRoomType:(NERoomType)roomType
                  pageNum:(int32_t)pageNum
                 pageSize:(int32_t)pageSize
         completionHandle:(nullable NETSRequestCompletion)completionHandle
              errorHandle:(nullable NETSRequestError)errorHandle {

    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/live/v1/list";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"pageNum": @(pageNum),
        @"pageSize": @(pageSize),
        @"roomType":@(roomType)
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NELiveRoomListModel class] isArray:NO],
        [NETSApiModelMapping mappingWith:@"/data/list" mappingClass:[NELiveRoomListDetailModel class] isArray:YES],
    ];
    
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    [resuest asyncRequest];
}

- (void)roomInfoWithRoomId:(NSString *)roomId
       completionHandle:(nullable NETSRequestCompletion)completionHandle
            errorHandle:(nullable NETSRequestError)errorHandle {
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/live/v1/info";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{@"roomId"  : roomId ?: @""};
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NECreateRoomResponseModel class]  isArray:NO]
    ];
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    
    [resuest asyncRequest];
}

- (void)requestPkInfoWithRoomId:(NSString *)roomId
              completionHandle:(nullable NETSRequestCompletion)completionHandle
                   errorHandle:(nullable NETSRequestError)errorHandle {
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/pk/v1/info";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{@"roomId"  : roomId ?: @""};
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data" mappingClass:[NEPkInfoModel class]  isArray:NO]
    ];
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    
    [resuest asyncRequest];
}

- (void)requestExitLiveRoomWith:(NSString *)roomId
               ompletionHandle:(nullable NETSRequestCompletion)completionHandle
                    errorHandle:(nullable NETSRequestError)errorHandle {
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/pk/v1/exit";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{@"roomId"  : roomId ?: @""};
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/" mappingClass:[NSDictionary class]  isArray:NO]
    ];
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    
    [resuest asyncRequest];
}


- (void)requestRewardLiveRoomWithParams:(NEPkRewardParams *)params
                         successBlock:(nullable NETSRequestCompletion)successBlock
                          failedBlock:(nullable NETSRequestError)failedBlock {
    
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = @"/live/v1/reward";
    options.apiMethod = NETSRequestMethodPOST;
    options.params = @{
        @"roomId":params.roomId,
        @"giftId":@(params.giftId)
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/" mappingClass:[NSDictionary class]  isArray:NO]
    ];
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = successBlock;
    resuest.errorBlock = failedBlock;
    [resuest asyncRequest];
}

- (void)requestConnectMicListWithRoomId:(NSString *)roomId
                           filterType:(NESeatFilterType)type
                         successBlock:(nullable NETSRequestCompletion)successBlock
                          failedBlock:(nullable NETSRequestError)failedBlock {
    
    NETSApiOptions *options = [[NETSApiOptions alloc] init];
    options.baseUrl = [NSString stringWithFormat:@"/seat/v1/%@/%@/list?pageSize=50&pageNumber=1",roomId,@(type)];
    options.apiMethod = NETSRequestMethodGET;
    options.params = @{
       
    };
    options.modelMapping = @[
        [NETSApiModelMapping mappingWith:@"/data/seatList" mappingClass:[NESeatInfoFilterModel class]  isArray:YES]
    ];
    NETSRequest *resuest = [[NETSRequest alloc] initWithOptions:options];
    resuest.completionBlock = successBlock;
    resuest.errorBlock = failedBlock;
    [resuest asyncRequest];
}

@end
