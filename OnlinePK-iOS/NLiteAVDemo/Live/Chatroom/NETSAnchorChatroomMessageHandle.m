//
//  NETSAnchorChatroomMessageHandle.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/5/20.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSAnchorChatroomMessageHandle.h"
#import "NETSLiveAttachment.h"

@implementation NETSAnchorChatroomMessageHandle

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
                    if (attach.type == NETSSeatsNotificationAudienceJoinSeatsSuccess ) {
                        YXAlogInfo(@"主播收到连麦者上麦成功聊天室消息");
                        if (self.delegate && [self.delegate respondsToSelector:@selector(receivedAudienceConnectMicSuccess:)]) {
                            [self.delegate receivedAudienceConnectMicSuccess:attach];
                        }
                        
                    }else if (attach.type == NETSSeatsNotificationWheatherLeaveSeats){//下麦
                        YXAlogInfo(@"主播收到连麦者下麦的聊天室消息");
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            if (self.delegate && [self.delegate respondsToSelector:@selector(receivedAudienceLeaveMicSuccess:)]) {
                                [self.delegate receivedAudienceLeaveMicSuccess:attach];
                            }
                        });

                    }else if (attach.type == NETSSeatsNotificationAVChange){//麦位音视频变化
                        YXAlogInfo(@"主播收到连麦者麦位音视频变化聊天室消息");
                        //刷新连麦视图
                        if (self.delegate && [self.delegate respondsToSelector:@selector(receivedAudioAndVideoChange:)]) {
                            [self.delegate receivedAudioAndVideoChange:attach];
                        }
                    }
                    
                }//如果有其他的attachment类型，在接着判断
                
                break;
            }

            default:
                break;
        }
    }
}
@end
