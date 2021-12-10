//
//  NETSChatroomService.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/7.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSChatroomService.h"
#import "NEAccount.h"
#import "NEPkLiveAttachment.h"

@implementation NETSChatroomService

+ (void)enterWithRoomId:(NSString *)roomId
               userMode:(NETSUserMode)userMode
                success:(void(^ _Nullable )(NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me))success
                 failed:(void(^ _Nullable )(NSError * _Nullable error))failed {
    
    NIMChatroomEnterRequest *request = [[NIMChatroomEnterRequest alloc] init];
    request.roomId = roomId;
    request.roomNickname = [NEAccount shared].userModel.nickname;
    request.roomAvatar = [NEAccount shared].userModel.avatar;

    [[NIMSDK sharedSDK].chatroomManager enterChatroom:request completion:^(NSError * _Nullable error, NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me) {
        if (error) {
            YXAlogError(@"enter chatroom failed,error: %@", error);
            if (failed) { failed(error); }
        } else {
            YXAlogInfo(@"进入聊天室成功");
            if (success) { success(chatroom, me); }
        }
    }];
}

+ (void)exitWithRoomId:(NSString *)roomId
{
    if (isEmptyString(roomId)) {
        YXAlogInfo(@"尚未创建聊天室, 无需退出");
        return;
    }
    [[NIMSDK sharedSDK].chatroomManager exitChatroom:roomId completion:^(NSError * _Nullable error) {
        if (error) {
            YXAlogInfo(@"退出聊天室失败 error: %@", error);
        } else {
            YXAlogInfo(@"退出聊天室成功");
        }
    }];
}

+ (void)isOnlineWithRoomId:(NSString *)roomId completion:(void(^)(BOOL isOnline))completion
{
    if (isEmptyString(roomId)) {
        YXAlogInfo(@"非法聊天室ID");
        if (completion) { completion(NO); }
        return;
    }
    
    // 搜索聊天室信息
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomInfo:roomId completion:^(NSError * _Nullable error, NIMChatroom * _Nullable chatroom) {
        if (error) {
            YXAlogInfo(@"获取聊天室信息失败, error: %@", error);
            if (completion) { completion(NO); }
            return;
        }

        // 搜索聊天室主播成员是否在线
        __block BOOL isOnline = NO;
        [self _fetchMembersRoomId:roomId limit:100 type:NIMChatroomFetchMemberTypeRegular successBlock:^(NSArray<NIMChatroomMember *> * _Nullable members) {
            for (NIMChatroomMember *member in members) {
                if ([member.userId isEqual:chatroom.creator]) {
                    isOnline = YES;
                    break;
                }
            }
            if (completion) { completion(isOnline); }
        } failedBlock:^(NSError *error) {
            YXAlogInfo(@"获取聊天室成员信息失败, error: %@", error);
            if (completion) { completion(NO); }
        }];
    }];
}

+ (void)sendMessage:(NSString *)message
           inRoomId:(NSString *)inRoomId
           userMode:(NETSUserMode)userMode
           nickname:(NSString *)nickname
           errorPtr:(NSError * __nullable *)errorPtr;
{
    if (isEmptyString(inRoomId)) {
        *errorPtr = [NSError errorWithDomain:@"NIMParamError" code:-1000 userInfo:@{@"msg": @"roomId为空"}];
        return;
    }
    
    NELiveTextAttachment *attachment = [[NELiveTextAttachment alloc] init];
    attachment.message = message;
    attachment.isAnchor = (userMode == NETSUserModeAnchor);
    
    NIMCustomObject *object = [[NIMCustomObject alloc] init];
    object.attachment = attachment;

    NIMMessage *textMessage = [[NIMMessage alloc] init];
    textMessage.messageObject = object;
    
    NIMSession *session = [NIMSession session:inRoomId type:NIMSessionTypeChatroom];
    [[NIMSDK sharedSDK].chatManager sendMessage:textMessage toSession:session error:errorPtr];
}

+ (void)fetchMembersRoomId:(NSString *)roomId
                     limit:(int32_t)limit
              successBlock:(void(^)(NSArray<NIMChatroomMember *> * _Nullable))successBlock
               failedBlock:(void(^)(NSError *))failedBlock
{
    [self _fetchMembersRoomId:roomId limit:limit type:NIMChatroomFetchMemberTypeTemp successBlock:successBlock failedBlock:failedBlock];
}

+ (void)_fetchMembersRoomId:(NSString *)roomId
                      limit:(int32_t)limit
                       type:(NIMChatroomFetchMemberType)type
               successBlock:(void(^)(NSArray<NIMChatroomMember *> * _Nullable))successBlock
                failedBlock:(void(^)(NSError *))failedBlock
{
    NIMChatroomMemberRequest *request = [[NIMChatroomMemberRequest alloc] init];
    request.roomId = roomId;
    request.type  = type;
    request.limit = limit;
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembers:request completion:^(NSError * _Nullable error, NSArray<NIMChatroomMember *> * _Nullable members) {
        if (error) {
            if (failedBlock) { failedBlock(error); }
        } else {
            if (successBlock) { successBlock(members); }
        }
    }];
}



+ (void)sendMessage:(NIMMessage *)message
             roomId:(NSString *)roomId
           errorPtr:(NSError * __nullable *)errorPtr {
    NIMSession *session = [NIMSession session:roomId type:NIMSessionTypeChatroom];
    [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:errorPtr];
}

@end
