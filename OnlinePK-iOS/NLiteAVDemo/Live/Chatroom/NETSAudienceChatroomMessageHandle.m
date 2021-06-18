//
//  NETSAudienceChatroomMessageHandle.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/5/20.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSAudienceChatroomMessageHandle.h"
#import "NETSLiveAttachment.h"
#import "NETSConnectMicModel.h"

@implementation NETSAudienceChatroomMessageHandle

- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages {
    for (NIMMessage *message in messages) {
        if (![message.session.sessionId isEqualToString:_roomId]
            && message.session.sessionType == NIMSessionTypeChatroom) {
            //不属于这个聊天室的消息
            return;
        }
        switch (message.messageType) {
            case NIMMessageTypeCustom:{
                NIMCustomObject *object = message.messageObject;
                if ([object.attachment isKindOfClass:[NETSConnectMicAttachment class]]) {
                    NETSConnectMicAttachment *attach = (NETSConnectMicAttachment *)object.attachment;
                    if (attach.type == NETSSeatsNotificationAudienceJoinSeatsSuccess) {
                        YXAlogDebug(@"观众上麦成功");
                        [self dealAudienceConnectSeats:attach];
                        
                    }else if (attach.type == NETSSeatsNotificationWheatherLeaveSeats){//下麦
                        YXAlogInfo(@"收到下麦聊天室消息");
                        [self dealAudienceLeaveSeats:attach];
                        
                    }else if (attach.type == NETSSeatsNotificationAVChange){//麦位音视频变化
                        YXAlogInfo(@"收到麦位音视频变化聊天室消息");
                        [self dealAudioAndVideo:attach];
                    }
                    
                }//如果有其他的attachment类型，在接着判断
                
                break;
            }

            default:
                break;
        }
    }
}

//上麦操作
- (void)dealAudienceConnectSeats:(NETSConnectMicAttachment *)attach {
    NSDictionary *memberDict = [attach.member getConnectMicMemberDictionary];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName_Audience_AcceptConnectMic object:@{@"isLeave":@NO,@"memberInfo":memberDict}];
    if (self.delegate && [self.delegate respondsToSelector:@selector(receivedAudienceConnectMicSuccess:)]) {
        [self.delegate receivedAudienceConnectMicSuccess:attach];
    }
}

//下麦操作
- (void)dealAudienceLeaveSeats:(NETSConnectMicAttachment *)attach {

    NSDictionary *memberDict = [attach.member getConnectMicMemberDictionary];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName_Audience_AcceptConnectMic object:@{@"isLeave":@YES,@"memberInfo":memberDict}];
    if (self.delegate && [self.delegate respondsToSelector:@selector(receivedAudienceLeaveMicSuccess:)]) {
        [self.delegate receivedAudienceLeaveMicSuccess:attach];
    }

}

//麦位音视频变化聊天室消息
- (void)dealAudioAndVideo:(NETSConnectMicAttachment *)attach {
    BOOL micOn = attach.member.audio == 1 ? YES : NO;
    BOOL cameraOn = attach.member.video == 1 ? YES : NO;
    
    //是主播操作，在设置toast提示
    if (![attach.fromUser isEqualToString:[NEAccount shared].userModel.accountId] &&
        [attach.member.accountId isEqualToString:[NEAccount shared].userModel.accountId]) {
      
        if ([NETSRtcConfig sharedConfig].micOn && micOn != [NETSRtcConfig sharedConfig].micOn) {
            [NETSToast showToast:@"主播关闭了你的麦克风"];

        }else if (![NETSRtcConfig sharedConfig].micOn && micOn != [NETSRtcConfig sharedConfig].micOn){
            [NETSToast showToast:@"主播打开了你的麦克风"];

        }else if ([NETSRtcConfig sharedConfig].cameraOn && cameraOn != [NETSRtcConfig sharedConfig].cameraOn){
            [NETSToast showToast:@"主播关闭了你的摄像头"];

        }else if (![NETSRtcConfig sharedConfig].cameraOn && cameraOn != [NETSRtcConfig sharedConfig].cameraOn){
            [NETSToast showToast:@"主播打开了你的摄像头"];
        }
        [NETSRtcConfig sharedConfig].micOn = micOn;
        [NETSRtcConfig sharedConfig].cameraOn = cameraOn;
    }
    
    //刷新连麦视图
    if (self.delegate && [self.delegate respondsToSelector:@selector(receivedAudioAndVideoChange:)]) {
        [self.delegate receivedAudioAndVideoChange:attach];
    }
}
@end
