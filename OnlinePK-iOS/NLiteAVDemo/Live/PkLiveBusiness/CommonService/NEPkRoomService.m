//
//  NEPkRoomService.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/13.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEPkRoomService.h"

#import "NEAudioOption.h"
#import "NEVideoOption.h"
#import "NETSPushStreamService.h"
#import "NECreateRoomResponseModel.h"
#import "NEPkRoomApiService.h"
#import "NEPkCreateRoomParams.h"
#import "NETSChatroomService.h"
#import "NEPkDestroyRoomParams.h"
#import "NETSLiveConfig.h"

@interface NEPkRoomService ()
@property(nonatomic, strong) NEAudioOption *audioOption;
@property(nonatomic, strong) NEVideoOption *videoOption;

@property(nonatomic, strong) NEPkRoomApiService *roomApiService;

@property(nonatomic, strong) NECreateRoomResponseModel *createRoomModel;
@end
@implementation NEPkRoomService

+ (instancetype)sharedRoomService {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)createLiveRoomWithTopic:(NSString *)roomTopic
                        coverUrl:(NSString *)coverUrl
                        roomType:(NERoomType)roomType
                    successBlock:(NECreateRoomSuccess)successBlock
                    failedBlock:(void(^)(NSError *))failedBlock {
    
    __weak typeof(self) weakSelf = self;

    // 加入直播间并推流闭包
    void (^joinChannelAndPushStreamBlock)(NECreateRoomResponseModel *_Nonnull) = ^(NECreateRoomResponseModel *responseModel) {
        [NETSPushStreamService joinChannelWithToken:responseModel.anchor.roomCheckSum channelName:responseModel.live.roomCname uid:responseModel.anchor.roomUid streamUrl:responseModel.live.liveConfig.pushUrl successBlcok:^(NERtcLiveStreamTaskInfo * _Nonnull task) {
            YXAlogInfo(@"Join rtc success");
            self.createRoomModel = responseModel;

            if (successBlock) {
                successBlock(responseModel, task);
            }
        } failedBlock:^(NSError * _Nonnull error, NSString *taskID) {
            YXAlogInfo(@"Join rtc failed, error: %@", error);
            if (failedBlock) {
                failedBlock(error);
            }
        }];
    };
    
    NEPkCreateRoomParams *params = [[NEPkCreateRoomParams alloc]init];
    params.roomTopic = roomTopic;
    params.cover = coverUrl;
    params.roomType = roomType;
    params.pushType = NELiveRoomPushTypeCDN;
    [self.roomApiService createRoomWithParams:params successBlock:^(NSDictionary * _Nonnull response) {
        NECreateRoomResponseModel *result = response[@"/data"];
        [NETSChatroomService enterWithRoomId:result.live.chatRoomId userMode:NETSUserModeAnchor success:^(NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me) {
            
            [weakSelf setUpEngineParams];
            joinChannelAndPushStreamBlock(result);
        } failed:^(NSError * _Nullable error) {
            if (failedBlock) { failedBlock(error); }
        }];
                
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogError(@"create room failed,Error:%@",error);
        if (failedBlock) {
            failedBlock(error);
        }
    }];

}


- (void)closeLiveCompletionBlock:(void(^)(NSError * _Nullable))completionBlock {
    
    void(^popBlock)(NSError * _Nullable) = ^(NSError * _Nullable error) {
        int res = [[NERtcEngine sharedEngine] leaveChannel];
        YXAlogInfo(@"leaveChannel, res: %d", res);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ntes_main_async_safe(^{
                if (completionBlock) { completionBlock(error); }
            });
        });
    };
    
    ntes_main_async_safe(^{ [NETSToast showLoading]; });
    
    NEPkDestroyRoomParams *params = [[NEPkDestroyRoomParams alloc]init];
    params.roomId = self.createRoomModel.live.roomId;
    [self.roomApiService destroyRoomWithParams:params successBlock:^(NSDictionary * _Nonnull response) {
        ntes_main_async_safe(^{ [NETSToast hideLoading]; });
        popBlock(nil);
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        ntes_main_async_safe(^{ [NETSToast hideLoading]; });
        YXAlogInfo(@"destroyRoom failed,error: %@", error);
        popBlock(error);
    }];

}

- (void)leaveLiveRoomCompletionBlock:(void(^)(NSError *_Nullable))completionBlock {
    
    if (isEmptyString(self.createRoomModel.live.chatRoomId)) {
        YXAlogInfo(@"The chat room has not been created,do not need to exit");
        return;
    }
    [[NIMSDK sharedSDK].chatroomManager exitChatroom:self.createRoomModel.live.chatRoomId completion:^(NSError * _Nullable error) {
        if (error) {
            YXAlogInfo(@"Failed to exit the chat room, error: %@", error);
            completionBlock(error);
        } else {
            completionBlock(nil);
            YXAlogInfo(@"Exit the chat room successfully");
        }
    }];
}


- (void)sendTextMessage:(NSString *)text {
    NSString *nickname = self.createRoomModel.anchor.nickname;
    NSError *error = nil;
    [NETSChatroomService sendMessage:text inRoomId:self.createRoomModel.live.chatRoomId userMode:NETSUserModeAnchor nickname:nickname errorPtr:&error];
    if (error) {
        YXAlogInfo(@"anchor send text failed, error: %@", error);
    }
}

- (void)setUpEngineParams {
    
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    // 打开推流,回调摄像头采集数据
    NSDictionary *params = @{
        kNERtcKeyPublishSelfStreamEnabled: @YES,    // 打开推流
        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户
    };
    [coreEngine setParameters:params];
    [coreEngine setClientRole:kNERtcClientRoleBroadcaster];
    
    // 设置视频发送配置(帧率/分辨率)
    NERtcVideoEncodeConfiguration *config = [NETSLiveConfig shared].videoConfig;
    [coreEngine setLocalVideoConfig:config];
    
    // 设置音频质量
    NSUInteger quality = [NETSLiveConfig shared].audioQuality;
    [coreEngine setAudioProfile:kNERtcAudioProfileHighQuality scenario:quality];
    [coreEngine setChannelProfile:kNERtcChannelProfileLiveBroadcasting];
    
    // 启用本地音/视频
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
}

- (NEAudioOption *)getAudioOption {
    return self.audioOption;
}

- (NEVideoOption *)getVideoOption {
    return self.videoOption;
}

- (NEAudioOption *)audioOption {
    if (!_audioOption) {
        _audioOption = [[NEAudioOption alloc]init];
    }
    return _audioOption;
}

- (NEVideoOption *)videoOption {
    if (!_videoOption) {
        _videoOption = [[NEVideoOption alloc]init];
    }
    return _videoOption;
}


-(NEPkRoomApiService *)roomApiService {
    if (!_roomApiService) {
        _roomApiService = [[NEPkRoomApiService alloc]init];
    }
    return _roomApiService;
}

@end

