//
//  NEPkRoomApiService.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/13.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NETSRequest.h"

NS_ASSUME_NONNULL_BEGIN
@class NEPkCreateRoomParams,NEPkEnterRoomParams,NEPkDestroyRoomParams,NEPkRewardParams;

@interface NEPkRoomApiService : NSObject

/// 主播-创建房间
/// @param params 创建房间所需参数
/// @param successBlock 成功回调
/// @param failedBlock 失败回调
- (void)createRoomWithParams:(NEPkCreateRoomParams *)params
               successBlock:(nullable NETSRequestCompletion)successBlock
                 failedBlock:(nullable NETSRequestError)failedBlock;

/// 主播-销毁房间
/// @param params 创建房间所需参数
/// @param successBlock 成功回调
/// @param failedBlock 失败回调
- (void)destroyRoomWithParams:(NEPkDestroyRoomParams *)params
               successBlock:(nullable NETSRequestCompletion)successBlock
                 failedBlock:(nullable NETSRequestError)failedBlock;

/// 观众-进入房间（Pk连麦需要）
/// @param params 创建房间所需参数
/// @param successBlock 成功回调
/// @param failedBlock 失败回调
- (void)enterRoomWithParams:(NEPkEnterRoomParams *)params
               successBlock:(nullable NETSRequestCompletion)successBlock
                 failedBlock:(nullable NETSRequestError)failedBlock;


/// 房间列表
/// @param roomType 房间类型
/// @param pageNum pageNum
/// @param pageSize pagesize
/// @param completionHandle 成功回调
/// @param errorHandle 失败回调
- (void)requestLiveRoomListWithRoomType:(NERoomType)roomType
                              pageNum:(int32_t)pageNum
                             pageSize:(int32_t)pageSize
                      completionHandle:(nullable NETSRequestCompletion)completionHandle
                          errorHandle:(nullable NETSRequestError)errorHandle;


/// 直播详情查询
/// @param roomId 房间编号
/// @param completionHandle 成功回调
/// @param errorHandle 失败回调
- (void)roomInfoWithRoomId:(NSString *)roomId
         completionHandle:(nullable NETSRequestCompletion)completionHandle
              errorHandle:(nullable NETSRequestError)errorHandle;



/// 获取pk信息
/// @param roomId  房间编号
/// @param completionHandle 成功回调
/// @param errorHandle 失败回调
- (void)requestPkInfoWithRoomId:(NSString *)roomId
              completionHandle:(nullable NETSRequestCompletion)completionHandle
                   errorHandle:(nullable NETSRequestError)errorHandle;



/// 退出房间（pk连麦使用）
/// @param roomId 房间编号
/// @param completionHandle completionHandle
/// @param errorHandle errorHandle
- (void)requestExitLiveRoomWith:(NSString *)roomId
               ompletionHandle:(nullable NETSRequestCompletion)completionHandle
                   errorHandle:(nullable NETSRequestError)errorHandle;


/// 直播间打赏
/// @param params 请求参数
/// @param successBlock 成功回调
/// @param failedBlock 失败回调
- (void)requestRewardLiveRoomWithParams:(NEPkRewardParams *)params
                   successBlock:(nullable NETSRequestCompletion)successBlock
                    failedBlock:(nullable NETSRequestError)failedBlock;


/// pk连麦获取不同type下麦位列表
/// @param roomId roomid
/// @param type 筛选类型
/// @param successBlock 成功回调
/// @param failedBlock 失败回调
- (void)requestConnectMicListWithRoomId:(NSString *)roomId
                           filterType:(NESeatFilterType)type
                         successBlock:(nullable NETSRequestCompletion)successBlock
                          failedBlock:(nullable NETSRequestError)failedBlock;
//观众-离开房间
- (void)leaveRoom;


@end

NS_ASSUME_NONNULL_END
