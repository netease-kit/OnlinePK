//
//  NETSPkService.m
//  NLiteAVDemo
//
//  Created by Think on 2021/1/6.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSPkService.h"
#import "NETSLiveApi.h"
#import "NETSPushStreamService.h"
#import "SKVObject.h"
#import "NETSChatroomService.h"
#import <NERtcSDK/NERtcSDK.h>
#import "NETSToast.h"
#import "NETSPkService+Inviter.h"
#import "NETSPkService+Invitee.h"
#import "NETSPkService+im.h"
#import "NETSConnectMicModel.h"
#import "NETSLiveConfig.h"

#define kPkServiceTimerQueue            "com.netease.pk.service.timer.queue"
#define NETSPkServiceErrorParamDomain   @"NETSPkServiceErrorParamDomain"

@interface NETSPkService () <NIMSignalManagerDelegate>

@end

@implementation NETSPkService

- (instancetype)initWithDelegate:(id<NETSPkServiceDelegate, NETSPkInviterDelegate, NETSPkInviteeDelegate, NETSPassThroughHandleDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _timerQueue = dispatch_queue_create(kPkServiceTimerQueue, DISPATCH_QUEUE_SERIAL);
        
        [[NIMSDK sharedSDK].signalManager addDelegate:self];
        [[NIMSDK sharedSDK].passThroughManager addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].signalManager removeDelegate:self];
    [[NIMSDK sharedSDK].passThroughManager removeDelegate:self];
    
    ApiLogInfo(@"dealloc NETSPkService: %p", self);
}

#pragma mark - NIMSignalManagerDelegate

- (void)nimSignalingOnlineNotifyEventType:(NIMSignalingEventType)eventType
                                 response:(NIMSignalingNotifyInfo *)notifyResponse
{
    switch (eventType) {
        case NIMSignalingEventTypeContrl:
            ApiLogInfo(@"邀请方 收到 被邀请方 发出的pk同步 信息");
            [self _inviterReceivedPkSyncWithInviteeResponse:notifyResponse];
            break;
        case NIMSignalingEventTypeReject:
        {
            ApiLogInfo(@"邀请方 收到 被邀请方 发出的拒绝pk邀请 信息");
            if ([notifyResponse isKindOfClass:[NIMSignalingRejectNotifyInfo class]]) {
                NIMSignalingRejectNotifyInfo *response = (NIMSignalingRejectNotifyInfo *)notifyResponse;
                [self _inviterReceivedPkRejectWithInviteeResponse:response];
            }
        }
            break;
        case NIMSignalingEventTypeAccept:
        {
            ApiLogInfo(@"邀请方 收到 被邀请方 发出的接受pk邀请 信息");
            if ([notifyResponse isKindOfClass:[NIMSignalingAcceptNotifyInfo class]]) {
                NIMSignalingAcceptNotifyInfo *response = (NIMSignalingAcceptNotifyInfo *)notifyResponse;
                [self _inviterReceivedPkAcceptWithInviteeResponse:response];
            }
        }
            break;
        case NIMSignalingEventTypeInvite:
        {
            ApiLogInfo(@"被邀请方 收到 邀请方 发送pk的邀请 信息");
            if (![notifyResponse isKindOfClass:[NIMSignalingInviteNotifyInfo class]]) {
                return;
            }
            
            NIMSignalingInviteNotifyInfo *response = (NIMSignalingInviteNotifyInfo *)notifyResponse;
            [self _inviteeReceivedInviterResponse:response];
        }
            break;
            
        case NIMSignalingEventTypeCancelInvite:
        {
            ApiLogInfo(@"被邀请方 收到 邀请方 取消pk的邀请 信息");
            if (![notifyResponse isKindOfClass:[NIMSignalingCancelInviteNotifyInfo class]]) {
                return;
            }
            NIMSignalingCancelInviteNotifyInfo *response = (NIMSignalingCancelInviteNotifyInfo *)notifyResponse;
            [self _inviteeReceivedCancelPkInviteResponse:response];
        }
            break;
            
        default:
            break;
    }
}

- (void)startSingleLiveWithTopic:(NSString *)topic
                        coverUrl:(NSString *)coverUrl
                    successBlock:(StartSingleLiveSuccess)successBlock
                     failedBlock:(void(^)(NSError *))failedBlock
{
    // 加入直播间并推流闭包
    void (^joinChannelAndPushStreamBlock)(NETSCreateLiveRoomModel *_Nonnull) = ^(NETSCreateLiveRoomModel *room) {
        [NETSPushStreamService joinChannelWithToken:room.avRoomCheckSum channelName:room.avRoomCName uid:[room.avRoomUid longLongValue] streamUrl:room.liveConfig.pushUrl successBlcok:^(NERtcLiveStreamTaskInfo * _Nonnull task) {
            ApiLogInfo(@"加入直播间成功,推流成功");
            self.singleRoom = room;
            self.streamTask = task;
            self.liveStatus = NETSPkServiceSingleLive;
            self.liveRole = NETSPkServiceDefault;
            if (successBlock) {
                successBlock(room, task);
            }
        } failedBlock:^(NSError * _Nonnull error, NSString *taskID) {
            ApiLogInfo(@"操作失败, error: %@", error);
            if (failedBlock) {
                failedBlock(error);
            }
        }];
    };
    
    // 请求接口,创建直播间
    [NETSLiveApi createLiveRoomWithTopic:topic coverUrl:coverUrl type:NETSLiveTypeNormal parentLiveCid:nil completionHandle:^(NSDictionary * _Nonnull response) {
        NETSCreateLiveRoomModel *result = response[@"/data"];
        // 判断直播间数据
        if (!result) {
            if (failedBlock) {
                NSError *error = [NSError errorWithDomain:NETSRequestErrorParseDomain code:NETSRequestErrorMapping userInfo:@{NSLocalizedDescriptionKey: @"创建直播间失败,返回直播间数据为空"}];
                failedBlock(error);
            }
            return;
        }
        [NETSChatroomService enterWithRoomId:result.chatRoomId userMode:NETSUserModeAnchor success:^(NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me) {
            ApiLogInfo(@"开启直播间成功,加入聊天室成功...");
            joinChannelAndPushStreamBlock(result);
        } failed:^(NSError * _Nullable error) {
            ApiLogInfo(@"开启直播间成功,加入聊天室失败, error: %@", error);
            if (failedBlock) { failedBlock(error); }
        }];
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        if (failedBlock) {
            failedBlock(error);
        }
    }];
}

- (void)endLiveWithCompletionBlock:(void(^)(NSError * _Nullable))completionBlock
{
    void(^popBlock)(NSError * _Nullable) = ^(NSError * _Nullable error) {
        int res = [[NERtcEngine sharedEngine] leaveChannel];
        ApiLogInfo(@"离开直播间, res: %d", res);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int res = [NERtcEngine destroyEngine];
            ApiLogInfo(@"结束直播,销毁音视频引擎, res: %d", res);

            ntes_main_async_safe(^{
                if (completionBlock) { completionBlock(error); }
            });
        });
    };
    
    if (isEmptyString(self.singleRoom.liveCid)) {
        popBlock(nil);
        return;
    }
    
    ntes_main_async_safe(^{ [NETSToast showLoading]; });
    [NETSLiveApi closeLiveRoomWithCid:self.singleRoom.liveCid completionHandle:^(NSDictionary * _Nonnull response) {
        ntes_main_async_safe(^{ [NETSToast hideLoading]; });
        popBlock(nil);
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        ntes_main_async_safe(^{ [NETSToast hideLoading]; });
        ApiLogInfo(@"退出直播间失败: %@", error);
        popBlock(error);
    }];
}

- (void)transformRoomWithSuccessBlock:(void(^)(NETSPkServiceStatus, int64_t))successBlock
                          failedBlock:(void(^)(NSError *))failedBlock
{
    
    if (self.liveStatus == NETSPkServiceSingleLive) {
        // 单人直播模式下,邀请者/被邀请者返回各自的单人直播间
        [self _backToSingleLiveRoomWithSuccessBlock:successBlock failedBlock:failedBlock];
    }
    else if (self.liveStatus == NETSPkServicePkLive) {
        switch (self.liveRole) {
            case NETSPkServiceInviter:
            {
                // pk直播模式下,邀请者 进入pk直播间
                __weak typeof(self) wSelf = self;
                [self _inviterJoinPkWithSuccessBlock:^(int64_t uid, uint64_t channelId, uint64_t elapesd) {
                    __strong __typeof(wSelf) sSelf = wSelf;
                    if (successBlock) {
                        successBlock(sSelf.liveStatus, uid);
                    }
                } failedBlock:^(NSError * _Nonnull error) {
                    if (failedBlock) { failedBlock(error); }
                }];
            }
                break;
            case NETSPkServiceInvitee:
            {
                // pk直播模式下,被邀请者 进入pk直播间
                __weak typeof(self) wSelf = self;
                [self _inviteeJoinPkWithSuccessBlock:^(int64_t uid, uint64_t channelId, uint64_t elapesd) {
                    __strong __typeof(wSelf) sSelf = wSelf;
                    if (successBlock) {
                        successBlock(sSelf.liveStatus, uid);
                    }
                } failedBlock:^(NSError * _Nonnull error) {
                    if (failedBlock) { failedBlock(error); }
                }];
            }
                break;
                
            default:
                break;
        }
    }
}

/// 返回原单人直播间
- (void)_backToSingleLiveRoomWithSuccessBlock:(void(^)(NETSPkServiceStatus, int64_t))successBlock
                                  failedBlock:(void(^)(NSError *))failedBlock
{
    NSString *singleRoomCid = self.singleRoom.liveCid;
    
    if (isEmptyString(singleRoomCid)) {
        ApiLogInfo(@"直播间转换失败: 单人直播间cid为空");
        if (failedBlock) {
            NSError *error = [NSError errorWithDomain:NETSPkServiceErrorParamDomain code:1000 userInfo:@{NSLocalizedDescriptionKey: @"直播间转换失败: 单人直播间cid为空"}];
            failedBlock(error);
        }
        return;
    }
    //joinchannel之前需要设置美颜开关
    NSDictionary *params = @{
        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户
    };
    [NERtcEngine.sharedEngine setParameters:params];
    void(^joinSingleChannelAndPushStreamBlock)(NETSCreateLiveRoomModel * _Nonnull) = ^(NETSCreateLiveRoomModel * _Nonnull result) {
        [NETSPushStreamService joinChannelWithToken:result.avRoomCheckSum
                                        channelName:result.avRoomCName
                                                uid:[result.avRoomUid longLongValue]
                                          streamUrl:self.singleRoom.liveConfig.pushUrl
                                       successBlcok:^(NERtcLiveStreamTaskInfo * _Nonnull task) {
            ApiLogInfo(@"离开pk直播加入原单人直播间成功,推流成功");
            self.streamTask = task;
            if (successBlock) {
                int64_t uid = [self.pkRoom.accountId longLongValue];
                successBlock(self.liveStatus, uid);
            }
        } failedBlock:^(NSError * _Nonnull error, NSString *taskID) {
            ApiLogInfo(@"离开pk直播加入原单人直播间,推流失败, error: %@, taskID: %@", error, taskID);
            if (failedBlock) {
                failedBlock(error);
            }
        }];
    };

    [NETSLiveApi joinLiveRoomWithLiveId:singleRoomCid parentLiveCid:nil liveType:NETSLiveTypeNormal completionHandle:^(NSDictionary * _Nonnull response) {
        NETSCreateLiveRoomModel *result = response[@"/data"];
        if (result) {
            joinSingleChannelAndPushStreamBlock(result);
        } else {
            if (failedBlock) {
                NSError *error = [NSError errorWithDomain:NETSPkServiceErrorParamDomain code:1000 userInfo:@{NSLocalizedDescriptionKey: @"返回单人直播间失败: 校验数据为空"}];
                failedBlock(error);
            }
        }
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        ApiLogInfo(@"加入原直播房间失败, error: %@", error);
        if (failedBlock) {
            failedBlock(error);
        }
    }];
}

- (void)endPkWithCompletionBlock:(nullable void(^)(NSError * _Nullable))completionBlock
{
    NSString *liveCid = self.singleRoom.liveCid;
    if (isEmptyString(liveCid)) {
        NSError *error = [NSError errorWithDomain:NETSPkServiceErrorParamDomain code:1000 userInfo:@{NSLocalizedDescriptionKey: @"结束pk失败,pk的直播间cid为空"}];
        if (completionBlock) {
            completionBlock(error);
        }
        return;
    }
    // 重置pk状态
    self.liveStatus = NETSPkServiceSingleLive;
    self.liveRole = NETSPkServiceDefault;
    
    void(^actionBlock)(NSError * _Nullable) = ^(NSError * _Nullable error){
        // 离开pk channel
        int res = [[NERtcEngine sharedEngine] leaveChannel];
        ApiLogInfo(@"强制结束pk,离开channel结果, res: %d", res);
        
        // 强制结束,发送pk惩罚结束im信息
        NSError *punEndErr = nil;
        [self _sendPunishEndImMsgWithData:nil errorPtr:&punEndErr];
        ApiLogInfo(@"主播端 发送pk惩罚结束信息, err: %@", punEndErr);
        
        if (completionBlock) {
            completionBlock(error);
        }
    };
    
    [NETSLiveApi endPKWithCid:liveCid completionHandle:^(NSDictionary * _Nonnull response) {
        ApiLogInfo(@"强制结束pk 接口请求结束pk成功");
        if (isEmptyString(self.streamTask.taskID)) {
            actionBlock(nil);
            return;
        }
        
        [NETSPushStreamService removeStreamTask:self.streamTask.taskID successBlock:^{
            ApiLogInfo(@"强制结束pk 移除pk推流 taskId: %@ success", self.streamTask.taskID);
            actionBlock(nil);
        } failedBlock:^(NSError * _Nonnull error) {
            ApiLogInfo(@"强制结束pk 移除pk推流 taskId: %@ error：%@", self.streamTask.taskID, error);
            actionBlock(error);
        }];
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        ApiLogInfo(@"接口请求结束pk失败");
        actionBlock(error);
    }];
}

- (void)pushPkStreamWithData:(NETSPassThroughHandlePkStartData *)data
                successBlock:(void(^)(void))successBlock
                 failedBlock:(void(^)(NSError *, NSString * _Nullable))failedBlock
{
    NSArray *uids = @[@(data.inviterRoomUid), @(data.inviteeRoomUid)];
    if (self.liveRole != NETSPkServiceInviter) {
        uids = @[@(data.inviteeRoomUid), @(data.inviterRoomUid)];
    }
    
    if (!self.pkRoom) {
        if (failedBlock) {
            NSError *error = [NSError errorWithDomain:@"NETSInterfaceErrorParamDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: @"直播间不存在"}];
            failedBlock(error, nil);
        }
        return;
    }
    
    NSString *url = self.pkRoom.liveConfig.pushUrl;
    NERtcLiveStreamTaskInfo *task = [NETSPushStreamService streamTaskWithUrl:url uids:uids];
    [NETSPushStreamService addStreamTask:task successBlock:^{
        self.streamTask = task;
        if (successBlock) { successBlock(); }
        
        // 超时计时器: 停止
        [self.timer invalidate];
    } failedBlock:failedBlock];
}

#pragma mark - private method

- (void)setLiveStatus:(NETSPkServiceStatus)liveStatus
{
    if (_liveStatus ==  liveStatus) {
        return;
    }
    _liveStatus = liveStatus;
    if (_delegate && [_delegate respondsToSelector:@selector(didPkServiceChangedStatus:)]) {
        [_delegate didPkServiceChangedStatus:liveStatus];
    }
}

#pragma mark - NIMPassThroughManagerDelegate 透传代理

- (void)didReceivedPassThroughMsg:(NIMPassThroughMsgData* __nullable)recvData
{
    NSString *body = recvData.body;
    if (isEmptyString(body)) { return; }
    
    SKVObject *obj = [SKVObject ofJSON:body];
    if (!obj) { return; }
    
    NSDictionary *dict = [obj dictionaryValue];
    if (!dict) { return; }
    
    NSInteger type = [dict[@"type"] integerValue];
    
    NSDictionary * dataDic = nil;
    if (type < NETSSeatsNotificationAdminAcceptJoinSeats) {
        //只有pk直播相关逻辑才需要取dict中的data,这里为了兼容
        dataDic = dict[@"data"];
        if (!dataDic) { return; }
    }
    switch (type) {
        case NETSLivePassThroughStartPK:
        {
            ApiLogInfo(@"收到服务端透传 PK开始 信令...");
            // 完成pk链接过程,关闭计时器
            [self.timer invalidate];
            
            NETSPassThroughHandlePkStartData *data = [NETSPassThroughHandlePkStartData yy_modelWithDictionary:dataDic];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(receivePassThrourhPkStartData:)]) {
                [self.delegate receivePassThrourhPkStartData:data];
            }
            
            // 发送pk开始im信息
            NSError *err = nil;
            [self _sendPkStartImMsgWithData:data errorPtr:&err];
            ApiLogInfo(@"主播端 发送pk开始信息, err: %@", err);
        }
            break;
        case NETSLivePassThroughStartPunish:
        {
            ApiLogInfo(@"收到服务端透传 PUNISH开始 信令...");
            
            if (self.liveStatus != NETSPkServicePkLive) {
                ApiLogInfo(@"非PK状态, 不响应服务端透传的 PUNISH开始 信令...");
                return;
            }
            
            NETSPassThroughHandlePunishData *data = [NETSPassThroughHandlePunishData yy_modelWithDictionary:dataDic];
            if (self.liveRole == NETSPkServiceInviter && ![data.roomCid isEqualToString:self.pkRoom.avRoomCid]) {
                ApiLogInfo(@"PK邀请者, 收到服务端透传的PK结束信令, roomCid 非法...");
                return;
            }
            
            // 获取pk结果
            NETSPkResult res = NETSPkUnknownResult;
            if (data.inviteeRewards == data.inviterRewards) {
                res = NETSPkTieResult;
            }
            else if ((data.inviteeRewards > data.inviterRewards && self.liveRole == NETSPkServiceInvitee) ||
                     (data.inviteeRewards < data.inviterRewards && self.liveRole == NETSPkServiceInviter)) {
                res = NETSPkCurrentAnchorWin;
            }
            else {
                res = NETSPkOtherAnchorWin;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didPkServiceFetchedPkRestlt:error:)]) {
                [self.delegate didPkServiceFetchedPkRestlt:res error:nil];
            } else {
                ApiLogInfo(@"未实现获取到pk结果后到代理方法: didPkServiceFetchedPkRestlt:error:");
            }
            
            // 发送pk结束im信息
            NSError *pkEndErr = nil;
            [self _sendPkEndImMsgWithData:data pkResult:res errorPtr:&pkEndErr];
            ApiLogInfo(@"主播端 发送pk结束信息, err: %@", pkEndErr);
            
            // 发送pk惩罚开始im信息
            NSError *punStartErr = nil;
            [self _sendPunishStartImMsgWithData:data pkResult:res errorPtr:&punStartErr];
            ApiLogInfo(@"主播端 发送pk惩罚开始信息, res:%zd err: %@", res, pkEndErr);
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(receivePassThrourhPunishStartData:pkResult:)]) {
                [self.delegate receivePassThrourhPunishStartData:data pkResult:res];
            }
        }
            break;
        case NETSLivePassThroughEndPK:
        {
            ApiLogInfo(@"收到服务端透传 PK结束 信令...");
            if (self.liveStatus != NETSPkServicePkLive) {
                ApiLogInfo(@"非PK状态, 不响应服务端透传的 PK结束 信令...");
                return;
            }
            
            NETSPassThroughHandlePkEndData *data = [NETSPassThroughHandlePkEndData yy_modelWithDictionary:dataDic];
            if (self.liveRole == NETSPkServiceInviter && ![data.roomCid isEqualToString:self.pkRoom.avRoomCid]) {
                ApiLogInfo(@"PK邀请者, 收到服务端透传的PK结束信令, roomCid 非法...");
                return;
            }
            
            void(^endPkBlock)(void) = ^(void){
                self.liveStatus = NETSPkServiceSingleLive;
                self.liveRole = NETSPkServiceDefault;
                
                // 收到服务端透传pk结束信令, 离开pk channel
                int res = [[NERtcEngine sharedEngine] leaveChannel];
                ApiLogInfo(@"收到服务端透传pk结束信令, 离开pk channel, res：%d", res);
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(receivePassThrourhPkEndData:)]) {
                    [self.delegate receivePassThrourhPkEndData:data];
                } else {
                    ApiLogInfo(@"未实现获取到pk结果后到代理方法: receivePassThrourhPkEndData:");
                }
                
                // 发送pk惩罚结束im信息
                NSError *punEndErr = nil;
                [self _sendPunishEndImMsgWithData:data errorPtr:&punEndErr];
                ApiLogInfo(@"主播端 发送pk惩罚结束信息, err: %@", punEndErr);
            };
            
            [NETSPushStreamService removeStreamTask:self.streamTask.taskID successBlock:^{
                ApiLogInfo(@"pk结束, 移除推流 taskId: %@ success", self.streamTask.taskID);
                endPkBlock();
            } failedBlock:^(NSError * _Nonnull error) {
                ApiLogInfo(@"pk结束, 移除推流 taskId: %@ error: %@", self.streamTask.taskID, error);
                endPkBlock();
            }];
        }
            break;
        case NETSLivePassThroughStartLive:
        {
            ApiLogInfo(@"收到服务端透传 直播开始 信令: %@...", dataDic);
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(receivePassThrourhLiveStartData:)]) {
                NETSPassThroughHandleStartLiveData *data = [NETSPassThroughHandleStartLiveData yy_modelWithDictionary:dataDic];
                [self.delegate receivePassThrourhLiveStartData:data];
            }
        }
            break;
        case NETSLivePassThroughReward:
        {
            ApiLogInfo(@"收到服务端透传 打赏 信令...");
            
            NETSPassThroughHandleRewardData *data = [NETSPassThroughHandleRewardData yy_modelWithDictionary:dataDic];
            
            // 发送云币同步IM信息
            NSError *syncCoinsErr = nil;
            NIMMessage *rewardMsg = [self _syncCoinMegWithData:data];
            [self _sendSyncCoinsImMsg:rewardMsg errorPtr:&syncCoinsErr];
            ApiLogInfo(@"主播端 发送云币同步IM消息, error: %@", syncCoinsErr);
            if (syncCoinsErr) { return; }
            
            // 执行代理,通知主播端有打赏信息
            if (self.delegate && [self.delegate respondsToSelector:@selector(receivePassThrourhRewardData:rewardMsg:)]) {
                [self.delegate receivePassThrourhRewardData:data rewardMsg:rewardMsg];
            }
        }
            break;
        case NETSSeatsNotificationAudienceApplyJoinSeats: {
            ApiLogInfo(@"收到观众申请上麦信令");
            NETSConnectMicModel *data = [NETSConnectMicModel yy_modelWithDictionary:dict];
            if (self.delegate && [self.delegate respondsToSelector:@selector(receivePassThrourhApplyJoinSeatsData:)]) {
                [self.delegate receivePassThrourhApplyJoinSeatsData:data];
            }
        }
            break;
            
        case NETSSeatsNotificationAudienceRejectJoinSeats:{
            ApiLogInfo(@"收到观众拒绝同意上麦信令");
            [NETSToast showToast:@"对方拒绝了你的邀请"];
        }
            break;
        default:
            break;
    }
    
    ApiLogInfo(@" Recv Msg:\n FromAccId: %@\n Body: %@\n Time: %@", recvData.fromAccid, recvData.body, @(recvData.time));
}

- (void)_tryToJoinPkRoomWithLiveCid:(NSString *)liveCid
                      parentLiveCid:(NSString *)parentLiveCid
                       successBlock:(void(^)(int64_t, uint64_t, uint64_t))successBlock
                        failedBlock:(void(^)(NSError *))failedBlock
{
    [NETSLiveApi joinLiveRoomWithLiveId:liveCid parentLiveCid:parentLiveCid liveType:NETSLiveTypePK completionHandle:^(NSDictionary * _Nonnull response) {
        ApiLogInfo(@"response: %@", response);
        NETSCreateLiveRoomModel *data = response[@"/data"];
        if (!isEmptyString(data.avRoomCheckSum) && !isEmptyString(data.avRoomCName) && !isEmptyString(data.avRoomUid)) {
            self.pkRoom = data;
            //joinchannel之前需要设置美颜开关
            NSDictionary *params = @{
                kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户
            };
            [NERtcEngine.sharedEngine setParameters:params];
            [self _joinPkChannerAfterTryJoinWithResult:data successBlock:successBlock failedBlock:failedBlock];
            return;
        }
        
        NSError *error = [NSError errorWithDomain:@"NETSInterfaceErrorParamDomain" code:1000 userInfo:@{NSLocalizedDescriptionKey: @"被邀请者进入PK直播间返回数据结构错误"}];
        if (failedBlock) { failedBlock(error); }
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        if (failedBlock) { failedBlock(error); }
    }];
}

/// 加入pk直播间channel, 在join接口请求成功后执行该方法
- (void)_joinPkChannerAfterTryJoinWithResult:(NETSCreateLiveRoomModel *)result
                                successBlock:(void(^)(int64_t, uint64_t, uint64_t))successBlock
                                 failedBlock:(void(^)(NSError *))failedBlock
{
    
    NERtcEngine *coreEngine = NERtcEngine.sharedEngine;
    // 设置直播模式
    [coreEngine setChannelProfile:kNERtcChannelProfileLiveBroadcasting];
    
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
    [coreEngine setAudioProfile:kNERtcAudioProfileDefault scenario:quality];
    // 启用本地音/视频
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
    int res = [coreEngine joinChannelWithToken:result.avRoomCheckSum
                                                   channelName:result.avRoomCName
                                                         myUid:[result.avRoomUid longLongValue]
                                                    completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
        if (error) {
            ApiLogInfo(@"主播 加入pk直播间失败, error: %@", error);
            if (failedBlock) { failedBlock(error); }
        } else {
            ApiLogInfo(@"主播 加入pk直播间成功");
            if (successBlock) {
                int64_t uid = [result.accountId longLongValue];
                successBlock(uid, channelId, elapesd);
            }
        }
    }];
    if (res != 0) {
        NSError *error = [NSError errorWithDomain:@"NETSRtcErrorParamDomain" code:res userInfo:@{NSLocalizedDescriptionKey: @"主播 加入PK直播间失败"}];
        if (failedBlock) { failedBlock(error); }
        return;
    }
}

@end
