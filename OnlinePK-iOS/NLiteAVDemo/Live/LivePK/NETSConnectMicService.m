//
//  NETSConnectMicService.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/5/18.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSConnectMicService.h"
#import "SKVObject.h"
#import "TopmostView.h"
#import "NETSLiveApi.h"
#import "NETSConnectMicModel.h"
#import "AppKey.h"
#import "NETSFUManger.h"
#import "NETSAudienceCollectionViewVC.h"
#import "NENavigator.h"
@interface NETSConnectMicService ()<NERtcEngineDelegateEx>
//是否已存在弹窗
@property(nonatomic, assign) BOOL isHaveAlert;
@end

@implementation NETSConnectMicService

#pragma mark - NIMPassThroughManagerDelegate

//收到的透传代理
-(void)didReceivedPassThroughMsg:(NIMPassThroughMsgData *)recvData {
    
    NSString *body = recvData.body;
    if (isEmptyString(body)) { return; }
    
    SKVObject *obj = [SKVObject ofJSON:body];
    if (!obj) { return; }
    
    NSDictionary *dict = [obj dictionaryValue];
    if (!dict) { return; }
    
    NSInteger type = [dict[@"type"] integerValue];
    
    NETSConnectMicModel *data = [NETSConnectMicModel yy_modelWithDictionary:dict];

    switch (type) {
        case NETSSeatsNotificationAdminAcceptJoinSeats: {
            YXAlogInfo(@"收到主播同意上麦信令");
            
            //解决主播观众同时操作问题，在观众上麦后，清除页面上的弹窗
            if (NENavigator.shared.navigationController.presentedViewController &&
                [NENavigator.shared.navigationController.presentedViewController isKindOfClass:UIAlertController.class]) {
                self.isHaveAlert = NO;
                [[NENavigator shared].navigationController dismissViewControllerAnimated:YES completion:nil];
            }

            //判断fromUser和当前主播是不是同一人,解决多端登录进入不同房间问题
            if ([data.fromUser isEqualToString:self.roomModel.accountId]) {
                if ([self.delegate respondsToSelector:@selector(adminAcceptJoinSeats)]) {
                    [self.delegate adminAcceptJoinSeats];
                }
                [self initialRtc];
                [self joinChannelWithData:data];//加入频道
            }
        }
            break;
        case NETSSeatsNotificationAdminInviteJoinSeats: {
            YXAlogInfo(@"收到主播邀请上麦信令");
            if (!self.isHaveAlert) {
                YXAlogDebug(@"所在控制器为%@",[NETSUniversalTool getCurrentActivityViewController]);
                Class currentVcClass = [NETSUniversalTool getCurrentActivityViewController].class;
                if (currentVcClass  == [NETSAudienceCollectionViewVC class] &&
                    [data.fromUser isEqualToString:self.roomModel.accountId]) {//防止观众快速点击关闭房间
                    [NETSAlertPrompt showAlert:UIAlertControllerStyleAlert title:@"邀请上麦" message:@"主播邀请你上麦" actionArr:@[@"拒绝",@"上麦"] actionColors:@[HEXCOLOR(0x666666),HEXCOLOR(0x007AFF)] cancel:nil index:^(NSInteger index) {
                        self.isHaveAlert = NO;
                        if (index == 1) {
                            YXAlogDebug(@"观众拒绝上麦");
                            [self audienceRejectInvite];
                        }else {
                            YXAlogDebug(@"观众同意主播的上麦邀请");
                            [self audienceAcceptInvite:data];
                        }
                    } presentVc:[NETSUniversalTool getCurrentActivityViewController]];
                    self.isHaveAlert = YES;
                }
                
            }

        }
            break;
        case NETSSeatsNotificationAdminRejectAudienceApply:{
            YXAlogInfo(@"收到主播拒绝观众申请连麦信令");
            [self anchorRejectAudienceRequest];
        }
            break;
      
        case NETSSeatsNotificationAudienceApplyJoinSeats: {
            ApiLogInfo(@"收到观众申请上麦信令");
        }
            break;
            
            
        case NETSSeatsNotificationAdminKickSeats :{
            ApiLogInfo(@"收到主播踢麦信令");
            [NETSToast showToast:@"您已被主播踢下麦位"];
        }
            break;
        default:
            break;
    }
}

#pragma mark - handle PassthroughMessage
//观众拒绝上麦邀请
- (void)audienceRejectInvite {
    YXAlogDebug(@"accountId = %@",[NEAccount shared].userModel.accountId);
    [NETSLiveApi requestSeatManagerWithRoomId:self.roomModel.liveCid userId:[NEAccount shared].userModel.accountId index:1 action:NETSSeatsOperationAudienceRejectJoinSeats successBlock:^(NSDictionary * _Nonnull response) {
        YXAlogDebug(@"观众拒绝上麦邀请成功，response = %@",response);
        } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
            YXAlogError(@"观众拒绝上麦邀请失败，error = %@",error.description);
    }];
}

//观众同意上麦邀请
- (void)audienceAcceptInvite:(NETSConnectMicModel *)data {
    [NETSLiveApi requestSeatManagerWithRoomId:self.roomModel.liveCid userId:[NEAccount shared].userModel.accountId index:1 action:NETSSeatsOperationAudienceAcceptJoinSeats successBlock:^(NSDictionary * _Nonnull response) {
        YXAlogDebug(@"观众同意上麦邀请成功，response = %@",response);
        [self initialRtc];
        [self joinChannelWithData:data];//加入频道
        } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
            YXAlogError(@"观众同意上麦邀请失败，error = %@",error.description);
            if (error) {
                [NETSToast showToast:response[@"msg"]];
            }
    }];
}

//主播拒绝观众申请连麦信令
- (void)anchorRejectAudienceRequest{

    [NETSAlertPrompt showAlert:UIAlertControllerStyleAlert title:@"主播拒绝了你的连麦申请" message:@"" actionArr:@[@"我知道了"] actionColors:@[HEXCOLOR(0x007AFF)] cancel:nil index:^(NSInteger index) {} presentVc:[NETSUniversalTool getCurrentActivityViewController]];
    if ([self.delegate respondsToSelector:@selector(adminRefuseAudienceApplyJoinSeats)]) {
        [self.delegate adminRefuseAudienceApplyJoinSeats];
    }
}


#pragma mark - privite Method
- (void)joinChannelWithData:(NETSConnectMicModel *)data {
    int result = [NERtcEngine.sharedEngine joinChannelWithToken:data.member.avRoomCheckSum channelName:data.member.avRoomCName myUid:[data.member.avRoomUid longLongValue] completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
        if (error) {
            YXAlogError(@"观众加入直播间失败 error:%@",error);
        }
    }];
    if (result != 0) {
        YXAlogError(@"观众joinChannelWithToken失败");
    }
}

- (void)initialRtc{
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    // 打开推流,回调摄像头采集数据
    NSDictionary *params = @{
        kNERtcKeyPublishSelfStreamEnabled: @YES,    // 打开推流
        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户
    };
    [coreEngine setClientRole:kNERtcClientRoleBroadcaster];
    [coreEngine setParameters:params];
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.engineDelegate = self;
    context.appKey = kNertcAppkey;
    int res = [coreEngine setupEngineWithContext:context];
    YXAlogInfo(@"观众NERtc初始化设置 NERtcEngine, res: %d", res);
    // 启用本地音/视频
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
}

#pragma mark - NERtcEngineDelegate

-(void)onNERtcEngineUserVideoDidStartWithUserID:(uint64_t)userID videoProfile:(NERtcVideoProfileType)profile {
    [NERtcEngine.sharedEngine subscribeRemoteVideo:YES forUserID:userID streamType:kNERtcRemoteVideoStreamTypeHigh];
}

- (void)onNERtcEngineVideoFrameCaptured:(CVPixelBufferRef)bufferRef rotation:(NERtcVideoRotationType)rotation
{
    [[NETSFUManger shared] renderItemsToPixelBuffer:bufferRef];
}
@end
