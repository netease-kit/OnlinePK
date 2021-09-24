//
//  NEPkService.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/11.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NETSRequest.h"
#import "NEPkServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class NEPkRewardParams,NEPKRewardTopParams;
@interface NEPkService : NSObject<NEPkServiceProtocol>

/// 获取全局实例
+ (instancetype)sharedPkService;


/// 设置代理
- (void)setDelegate;

/// 移除代理
- (void)removeDelegate;

/// PK 邀请
/// @param action PK 邀请
/// @param accountId 账户id
/// @param successBlock 成功回调
/// @param failedBlock 失败回调
- (void)requestPkWithOperation:(NEPkOperation)action
               targetAccountId:(NSString *)accountId
                  successBlock:(nullable NETSRequestCompletion)successBlock
                   failedBlock:(nullable NETSRequestError)failedBlock;

/// 取消PK邀请
/// @param action 取消邀请
/// @param accountId 账户id
/// @param successBlock 成功回调
/// @param failedBlock 失败回调
- (void)cancelPkRequestWithOperation:(NEPkOperation)action
               targetAccountId:(NSString *)accountId
                  successBlock:(nullable NETSRequestCompletion)successBlock
                   failedBlock:(nullable NETSRequestError)failedBlock;


/// 同意邀请PK邀请
/// @param action 同意邀请
/// @param accountId 账户id
/// @param successBlock 成功回调
/// @param failedBlock 失败回调
- (void)acceptPkWithOperation:(NEPkOperation)action
               targetAccountId:(NSString *)accountId
                  successBlock:(nullable NETSRequestCompletion)successBlock
                   failedBlock:(nullable NETSRequestError)failedBlock;


/// 拒绝PK邀请
/// @param action 拒绝邀请
/// @param accountId 账户id
/// @param successBlock 成功回调
/// @param failedBlock 失败回调
- (void)rejectPkRequestWithOperation:(NEPkOperation)action
               targetAccountId:(NSString *)accountId
                  successBlock:(nullable NETSRequestCompletion)successBlock
                   failedBlock:(nullable NETSRequestError)failedBlock;

//主播主动结束pk
- (void)closePkLiveSuccessBlock:(nullable NETSRequestCompletion)successBlock
                    failedBlock:(nullable NETSRequestError)failedBlock;




/// pk 直播打赏榜
/// @param params 请求参数
/// @param successBlock 成功回调
/// @param failedBlock 失败回调
- (void)requestRewardTopWithParams:(NEPKRewardTopParams *)params
                   successBlock:(nullable NETSRequestCompletion)successBlock
                    failedBlock:(nullable NETSRequestError)failedBlock;

@end

NS_ASSUME_NONNULL_END
