//
//  NETSAudienceChatroomMessageHandle.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/5/20.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@class NETSConnectMicAttachment;

@protocol NETSAudienceChatroomMessageHandleDelegate <NSObject>

/// 观众成功上麦
/// @param msgAttachment 上麦观众的附件
- (void)receivedAudienceConnectMicSuccess:(NETSConnectMicAttachment *)msgAttachment;


/// 观众成功下麦
/// @param msgAttachment 上麦观众的附件
- (void)receivedAudienceLeaveMicSuccess:(NETSConnectMicAttachment *)msgAttachment;

/// 音视频变化的聊天室消息
/// @param msgAttachment 上麦观众的附件
- (void)receivedAudioAndVideoChange:(NETSConnectMicAttachment *)msgAttachment;

@end

@interface NETSAudienceChatroomMessageHandle : NSObject<NIMChatManagerDelegate>
/// 聊天室ID
@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, weak) id<NETSAudienceChatroomMessageHandleDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
