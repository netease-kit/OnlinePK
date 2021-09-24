//
//  NEPkRoomService.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/13.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

@class NECreateRoomResponseModel,NEPkRoomApiService;
NS_ASSUME_NONNULL_BEGIN
typedef void(^NECreateRoomSuccess) (NECreateRoomResponseModel *,NERtcLiveStreamTaskInfo *_Nonnull);

@class NEAudioOption,NEVideoOption;



@interface NEPkRoomService : NSObject

/// 获取实例
+ (instancetype)sharedRoomService;


/// 创建房间
/// @param roomTopic 房间主题
/// @param coverUrl 封面地址
/// @param roomType 房间类型
/// @param successBlock 成功回调
/// @param failedBlock 失败回调
- (void)createLiveRoomWithTopic:(NSString *)roomTopic
                        coverUrl:(NSString *)coverUrl
                        roomType:(NERoomType)roomType
                    successBlock:(NECreateRoomSuccess)successBlock
                     failedBlock:(void(^)(NSError *))failedBlock;


/// 主播销毁房间
/// @param completionBlock 错误回调
- (void)closeLiveCompletionBlock:(void(^)(NSError * _Nullable))completionBlock;


/// 观众离开房间
/// @param completionBlock  错误回调
- (void)leaveLiveRoomCompletionBlock:(void(^)(NSError *_Nullable))completionBlock;

/// 发送聊天室文本消息
/// @param text 文本
- (void)sendTextMessage:(NSString *)text;

- (NEAudioOption *)getAudioOption;

- (NEVideoOption *)getVideoOption;

@end

NS_ASSUME_NONNULL_END
