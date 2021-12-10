//
//  NEChatroomMsgHandle.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/7/17.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEPkChatroomMsgHandle.h"
#import "NSDictionary+NTESJson.h"
#import "NSString+NTES.h"
#import "NEPkLiveAttachment.h"


@implementation NEPkChatroomMsgHandle

#pragma mark - NIMChatManagerDelegate
- (void)willSendMessage:(NIMMessage *)message {
    switch (message.messageType) {
        case NIMMessageTypeCustom: {
            NIMCustomObject *object = message.messageObject;
            //自定义文本消息 还使用原来的attachment
            if ([object.attachment isKindOfClass:[NELiveTextAttachment class]]) {
                if (_delegate && [_delegate respondsToSelector:@selector(onRecvRoomTextMsg:)]) {
                    [_delegate onRecvRoomTextMsg:@[message]];
                }
            }
        }
            break;
            
        default:
            break;
    }

}

-(void)onRecvMessages:(NSArray<NIMMessage *> *)messages {
    for (NIMMessage *message in messages) {
        if (![message.session.sessionId isEqualToString:self.chatroomId]
            && message.session.sessionType == NIMSessionTypeChatroom) {
            //不属于这个聊天室的消息
            return;
        }
        switch (message.messageType) {
            case NIMMessageTypeText://文本类型消息
                
                break;
            case NIMMessageTypeCustom: {
                
                NIMCustomObject *object = message.messageObject;
                
                if ([object.attachment isKindOfClass:[NEPkLiveStartAttachment class]]) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(receivePkStartAttachment:)]) {
                        NEPkLiveStartAttachment *data = (NEPkLiveStartAttachment *)object.attachment;
                        [self.delegate receivePkStartAttachment:data];
                    }
                }else if ([object.attachment isKindOfClass:[NEStartPunishAttachment class]]) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(receivePunishStartAttachment:)]) {
                        NEStartPunishAttachment *data = (NEStartPunishAttachment *)object.attachment;
                        [self.delegate receivePunishStartAttachment:data];
                    }
                }else if ([object.attachment isKindOfClass:[NEPkEndAttachment class]]) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(receivePkEndAttachment:)]) {
                        NEPkEndAttachment *data = (NEPkEndAttachment *)object.attachment;
                        [self.delegate receivePkEndAttachment:data];
                    }
                }else if ([object.attachment isKindOfClass:[NEPkRewardAttachment class]]){
                    if (self.delegate && [self.delegate respondsToSelector:@selector(receivePkRewardAttachment:)]) {
                        NEPkRewardAttachment *data = (NEPkRewardAttachment *)object.attachment;
                        [self.delegate receivePkRewardAttachment:data];
                    }
                }else if ([object.attachment isKindOfClass:[NELiveTextAttachment class]]){
                    if (_delegate && [_delegate respondsToSelector:@selector(onRecvRoomTextMsg:)]) {
                        [_delegate onRecvRoomTextMsg:@[message]];
                    }
                }
            }
                 
                break;
            case NIMMessageTypeNotification:{
                [self dealWithNotificationMessage:message];
            }
                break;
            default:
                break;
        }
    }
}

- (void)dealWithNotificationMessage:(NIMMessage *)message {
    NIMNotificationObject *object = (NIMNotificationObject *)message.messageObject;
    switch (object.notificationType) {
        case NIMNotificationTypeChatroom:{
            NIMChatroomNotificationContent *content = (NIMChatroomNotificationContent *)object.content;
            if (content.eventType == NIMChatroomEventTypeEnter) { //进入聊天室
                NIMChatroomNotificationMember *member = content.source;
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomMember:enter:sessionId:)]) {
                    [_delegate didChatroomMember:member enter:YES sessionId:message.session.sessionId];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatroomUserEnter object:member];
            }
            else if (content.eventType == NIMChatroomEventTypeExit) { //离开聊天室
                NIMChatroomNotificationMember *member = content.source;
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomMember:enter:sessionId:)]) {
                    [_delegate didChatroomMember:member enter:NO sessionId:message.session.sessionId];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatroomUserLeave object:member];
            }
            else if (content.eventType == NIMChatroomEventTypeClosed) { //聊天室被关闭
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomClosedWithRoomId:)]) {
                    [_delegate didChatroomClosedWithRoomId:message.session.sessionId];
                }
            }
        }
            break;
        default:
            break;
    }
}


- (void)chatroomBeKicked:(NIMChatroomBeKickedResult *)result {
    if (result.reason == NIMChatroomKickReasonInvalidRoom) {
        if (_delegate && [_delegate respondsToSelector:@selector(didChatroomClosedWithRoomId:)]) {
            [_delegate didChatroomClosedWithRoomId:result.roomId];
        }
    }else if (result.reason == NIMChatroomKickReasonByConflictLogin) {
        if (_delegate && [_delegate respondsToSelector:@selector(didChatroomKickWithRoomId:)]) {
            [_delegate didChatroomKickWithRoomId:result.roomId];
        }
    }
}

@end
