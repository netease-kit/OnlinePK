//
//  NEChatroomMsgHandle.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/7/17.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NEPkLiveStartAttachment,NEStartPunishAttachment,NEPkRewardAttachment,NEPkEndAttachment;

@protocol NEPkChatroomMsgHandleDelegate <NSObject>

/// 收到开始PK的消息,双方开始推流
/// @param liveStartData 开始pk数据
- (void)receivePkStartAttachment:(NEPkLiveStartAttachment *)liveStartData;

/// 收到PassThrough开始惩罚的消息
/// @param punishData 惩罚数据
- (void)receivePunishStartAttachment:(NEStartPunishAttachment *)punishData;


/// 收到pk结束消息
/// @param pkEndData 结束消息
- (void)receivePkEndAttachment:(NEPkEndAttachment *)pkEndData;


/// 收到PassThrough打赏通知
/// @param rewardData 打赏数据
- (void)receivePkRewardAttachment:(NEPkRewardAttachment *)rewardData;

/// 收到文本消息
/// @param messages 文本消息
- (void)onRecvRoomTextMsg:(NSArray<NIMMessage *> *)messages;

///
/// 聊天室进出
/// @param member   - 成员信息
/// @param enter    - 进入/离开
/// @param sessionId    - 会话ID
///
- (void)didChatroomMember:(NIMChatroomNotificationMember *)member
                    enter:(BOOL)enter
                sessionId:(NSString *)sessionId;

/// 聊天室关闭
/// @param roomId 聊天室 Id
- (void)didChatroomClosedWithRoomId:(NSString *)roomId;


/// 聊天室被踢
/// @param roomId 聊天室 Id
- (void)didChatroomKickWithRoomId:(NSString *)roomId;

@end

@interface NEPkChatroomMsgHandle : NSObject<NIMChatroomManagerDelegate,NIMChatManagerDelegate,NIMSystemNotificationManagerDelegate>

@property(nonatomic, weak) id<NEPkChatroomMsgHandleDelegate> delegate;
//聊天室id
@property(nonatomic, strong) NSString *chatroomId;

@end

NS_ASSUME_NONNULL_END
