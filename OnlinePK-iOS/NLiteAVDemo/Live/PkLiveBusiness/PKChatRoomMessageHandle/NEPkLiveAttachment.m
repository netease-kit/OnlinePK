//
//  NEPkLiveAttachment.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEPkLiveAttachment.h"


@implementation NEAnchorRewardModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
  return @{
      @"pkRewardTop":[NEPkRewardTopModel class]
  };
}


- (nullable NSArray<NSString *> *)rewardAvatars {
    return [self _avatarFromArray:_pkRewardTop];
}


- (nullable NSArray<NSString *> *)_avatarFromArray:(nullable NSArray<NEPkRewardTopModel *> *)array {
    if (!array) {
        return nil;
    }
    NSMutableArray *res = [NSMutableArray arrayWithCapacity:[array count]];
    for (NEPkRewardTopModel *user in array) {
        NSString *avatar = user.avatar;
        [res addObject:avatar];
    }
    return [res copy];
}

@end


@implementation NEPkLiveStartAttachment

- (nonnull NSString *)encodeAttachment {
    return @"";
}

@end


@implementation NEStartPunishAttachment

- (nonnull NSString *)encodeAttachment {
    return @"";
}

@end


@implementation NEPkEndAttachment

- (nonnull NSString *)encodeAttachment {
    return @"";
}

@end



@implementation NEPkRewardAttachment
- (nonnull NSString *)encodeAttachment {
    return @"";
}
@end

@implementation NEPkLiveStartSubModel

@end

@implementation NEPkRewardTopModel

@end

@interface NELiveTextAttachment ()
@property (nonatomic, assign, readwrite)   NELiveAttachmentType  type;
@end

@implementation NELiveTextAttachment
- (instancetype)init
{
    if (self = [super init]) {
        self.type = NELiveAttachmentTextType;
    }
    return self;
}

- (NSString *)encodeAttachment
{
    NSDictionary *dict = @{
                            @"type"     : @(self.type),
                            @"isAnchor" : @(self.isAnchor),
                            @"message"  : self.message ?: @""
                          };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict  options:0  error:nil];
    NSString *content = nil;
    if (jsonData) {
        content = [[NSString alloc] initWithData:jsonData
                                        encoding:NSUTF8StringEncoding];
    }

    return content;
}

@end

#pragma mark - NETSLiveAttachmentDecoder
@implementation NEPKLiveAttachmentDecoder

// 所有的自定义消息都会走这个解码方法，如有多种自定义消息请在该方法中扩展，并自行做好类型判断和版本兼容。
- (id<NIMCustomAttachment>)decodeAttachment:(NSString *)content
{
    id<NIMCustomAttachment> attachment;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return attachment;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return attachment;
    }
    NSInteger type = [dict[@"type"] integerValue];
    //判断是连麦还是其他的类型使用member字段来区分

    switch (type) {
        case NEPKChatRoomMessageBodyPkStart:{
            attachment = [self _decodePkStartWithDict:dict];
        }
            break;
            
        case NEPKChatRoomMessageBodyPkPunish:{
            attachment = [self _decodeStartPunishWithDict:dict];
        }
            break;
            
        case NEPKChatRoomMessageBodyPkEnd:{
            attachment = [self _decodePkEndWithDict:dict];
        }
            break;
            
        case NEPKChatRoomMessageBodyPkReward:{
            attachment = [self _decodePkRewardWithDict:dict];
        }
            break;
        case NELiveAttachmentTextType: {
            attachment = [self _decodeTextWithDict:dict];
        }
        default:
            break;
    }

    return attachment;
}

- (NEPkLiveStartAttachment *)_decodePkStartWithDict:(NSDictionary *)dict {
    NEPkLiveStartAttachment *attachment = [[NEPkLiveStartAttachment alloc] init];
    attachment.messageType = [dict[@"type"] integerValue];
    attachment.senderAccountId = dict[@"senderAccountId"] ?: @"";
    attachment.sendTime = [dict[@"sendTime"] longLongValue];
    attachment.pkStartTime = [dict[@"pkStartTime"] longLongValue];
    attachment.pkCountDown = [dict[@"pkCountDown"] longLongValue];
    
    NEPkLiveStartSubModel *inviterModel = [NEPkLiveStartSubModel yy_modelWithDictionary:dict[@"inviter"]];
    NEPkLiveStartSubModel *inviteeModel = [NEPkLiveStartSubModel yy_modelWithDictionary:dict[@"invitee"]];
    attachment.inviter = inviterModel;
    attachment.invitee = inviteeModel;
    return attachment;
}

- (NEStartPunishAttachment *)_decodeStartPunishWithDict:(NSDictionary *)dict {
    NEStartPunishAttachment *attachment = [[NEStartPunishAttachment alloc] init];
    attachment.messageType = [dict[@"type"] integerValue];
    attachment.senderAccountId = dict[@"senderAccountId"] ?: @"";
    attachment.sendTime = [dict[@"sendTime"] longLongValue];
    attachment.pkStartTime = [dict[@"pkStartTime"] longLongValue];
    attachment.pkPenaltyCountDown = [dict[@"pkPenaltyCountDown"] intValue];
    attachment.inviterRewards = [dict[@"inviterRewards"] longLongValue];
    attachment.inviteeRewards = [dict[@"inviteeRewards"] longLongValue];
    return attachment;

}

- (NEPkEndAttachment *)_decodePkEndWithDict:(NSDictionary *)dict {
    NEPkEndAttachment *attachment = [[NEPkEndAttachment alloc] init];
    attachment.messageType = [dict[@"type"] integerValue];
    attachment.senderAccountId = dict[@"senderAccountId"] ?: @"";
    attachment.sendTime = [dict[@"sendTime"] longLongValue];
    attachment.pkStartTime = [dict[@"pkStartTime"] longLongValue];
    attachment.pkEndTime = [dict[@"pkEndTime"] longLongValue];
    attachment.inviterRewards = [dict[@"inviterRewards"] longLongValue];
    attachment.inviteeRewards = [dict[@"inviteeRewards"] longLongValue];
    attachment.nickname = dict[@"nickname"] ?: @"";
    attachment.countDownEnd = [dict[@"countDownEnd"] boolValue];
    return attachment;
}

- (NEPkRewardAttachment *)_decodePkRewardWithDict:(NSDictionary *)dict{
    NEPkRewardAttachment *attachment = [[NEPkRewardAttachment alloc] init];
    attachment.messageType = [dict[@"type"] integerValue];
    attachment.senderAccountId = dict[@"senderAccountId"] ?: @"";
    attachment.sendTime = [dict[@"sendTime"] longLongValue];
//    attachment.pkStartTime = [dict[@"pkStartTime"] longLongValue];
    attachment.rewarderAccountId = dict[@"rewarderAccountId"] ?: @"";
    attachment.rewarderNickname = dict[@"rewarderNickname"] ?: @"";
    attachment.giftId = [dict[@"giftId"] longLongValue];
    attachment.memberTotal = [dict[@"memberTotal"] longLongValue];
    NEAnchorRewardModel *anchorRewardModel = [NEAnchorRewardModel yy_modelWithDictionary:dict[@"anchorReward"]];
    NEAnchorRewardModel *otherAnchorRewardModel = [NEAnchorRewardModel yy_modelWithDictionary:dict[@"otherAnchorReward"]];
    attachment.anchorReward = anchorRewardModel;
    attachment.otherAnchorReward = otherAnchorRewardModel;
    return attachment;
}

- (id<NIMCustomAttachment>)_decodeTextWithDict:(nonnull NSDictionary *)dict {
    NELiveTextAttachment *attachment = [[NELiveTextAttachment alloc] init];
    attachment.type = [dict[@"type"] integerValue];
    attachment.isAnchor = [dict[@"isAnchor"] boolValue];
    attachment.message = dict[@"message"];
    return attachment;
}
@end
