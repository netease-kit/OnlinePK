//
//  NETSLiveAttachment.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveAttachment.h"
#import "NETSConnectMicModel.h"

@implementation NETSLivePKAttachment

- (NSString *)encodeAttachment
{
    NSDictionary *dict = @{
                            @"type"     : @(self.type),
                            @"state"    : @(self.state),
                            @"startedTimestamp" : @(self.startedTimestamp),
                            @"currentTimestamp" : @(self.currentTimestamp),
                            @"otherAnchorNickname"  : self.otherAnchorNickname ?: @"",
                            @"otherAnchorAvatar"    : self.otherAnchorAvatar ?: @"",
                            @"currentAnchorWin"    : @(self.currentAnchorWin)
                          };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict  options:0  error:nil];
    NSString *content = nil;
    if (jsonData) {
        content = [[NSString alloc] initWithData:jsonData
                                        encoding:NSUTF8StringEncoding];
    }

    return content;
}

+ (nullable NETSLivePKAttachment *)getAttachmentWithMessage:(NIMMessage *)message;
{
    if (message.messageType != NIMMessageTypeCustom) {
        return nil;
    }
    NIMCustomObject *object = message.messageObject;
    if (![object.attachment isKindOfClass:[NETSLivePKAttachment class]]) {
        return nil;
    }
    return (NETSLivePKAttachment *)object.attachment;
}

@end

///

@interface NETSLiveWealthChangeAttachment ()

@property (nonatomic, assign, readwrite)   NETSLiveAttachmentType  type;

@end

@implementation NETSLiveWealthChangeAttachment

- (instancetype)init
{
    if (self = [super init]) {
        self.type = NETSLiveAttachmentWealthType;
    }
    return self;
}

- (NSString *)encodeAttachment
{
    NSDictionary *dict = @{
                            @"type"             : @(self.type),
                            @"giftId"          : @(self.giftId),
                            @"nickname"         : _nickname ?: @"",
                            @"totalCoinCount"   : @(self.totalCoinCount),
                            @"PKCoinCount"      : @(self.PKCoinCount),
                            @"otherPKCoinCount" : @(self.otherPKCoinCount),
                            @"rewardList"       : _rewardList,
                            @"otherRewardList"  : _otherRewardList,
                            @"fromUserAvRoomUid": _fromUserAvRoomUid ?: @""
                          };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict  options:0  error:nil];
    NSString *content = nil;
    if (jsonData) {
        content = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    return content;
}

- (void)setOriginRewardList:(NSArray<NETSPassThroughHandleRewardUser *> *)originRewardList
{
    _originRewardList = originRewardList;
    NSInteger count = [originRewardList count];
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:count];
    for (NETSPassThroughHandleRewardUser *user in originRewardList) {
        NSDictionary *userDic = [user rewardUserDictionary];
        if (userDic) {
            [temp addObject:userDic];
        }
    }
    _rewardList = temp;
}

- (void)setOriginOtherRewardList:(NSArray<NETSPassThroughHandleRewardUser *> *)originOtherRewardList
{
    _originOtherRewardList = originOtherRewardList;
    NSInteger count = [originOtherRewardList count];
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:count];
    for (NETSPassThroughHandleRewardUser *user in originOtherRewardList) {
        NSDictionary *userDic = [user rewardUserDictionary];
        if (userDic) {
            [temp addObject:userDic];
        }
    }
    _otherRewardList = temp;
}

+ (nullable NETSLiveWealthChangeAttachment *)getAttachmentWithMessage:(NIMMessage *)message
{
    if (message.messageType != NIMMessageTypeCustom) {
        return nil;
    }
    NIMCustomObject *object = message.messageObject;
    if (![object.attachment isKindOfClass:[NETSLiveWealthChangeAttachment class]]) {
        return nil;
    }
    return (NETSLiveWealthChangeAttachment *)object.attachment;
}

- (nullable NSArray<NSString *> *)originRewardAvatars
{
    return [self _avatarFromArray:_originRewardList];
}

- (nullable NSArray<NSString *> *)originOtherRewardAvatars
{
    return [self _avatarFromArray:_originOtherRewardList];
}

- (nullable NSArray<NSString *> *)_avatarFromArray:(nullable NSArray<NETSPassThroughHandleRewardUser *> *)array
{
    if (!array) {
        return nil;
    }
    NSMutableArray *res = [NSMutableArray arrayWithCapacity:[array count]];
    for (NETSPassThroughHandleRewardUser *user in array) {
        NSString *avatar = user.avatar;
        [res addObject:avatar];
    }
    return [res copy];
}

@end

///

@interface NETSLiveTextAttachment ()

@property (nonatomic, assign, readwrite)   NETSLiveAttachmentType  type;

@end

@implementation NETSLiveTextAttachment

- (instancetype)init
{
    if (self = [super init]) {
        self.type = NETSLiveAttachmentTextType;
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




@implementation NETSConnectMicAttachment

+ (nullable NETSConnectMicAttachment *)getAttachmentWithMessage:(NIMMessage *)message {
    if (message.messageType != NIMMessageTypeCustom) {
        return nil;
    }
    NIMCustomObject *object = message.messageObject;
    if (![object.attachment isKindOfClass:[NETSConnectMicAttachment class]]) {
        return nil;
    }
    return (NETSConnectMicAttachment *)object.attachment;
}

- (NSString *)encodeAttachment {
    NSDictionary *dict = @{
                            @"status"   : @(self.status),
                            @"type"     : @(self.type),
                            @"member"   : _member,
                            @"fromUser" : self.fromUser
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
@implementation NETSLiveAttachmentDecoder

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
        case NETSLiveAttachmentPkType:
        case NETSLiveAttachmentPunishType:
            attachment = [self _decodePkWithDict:dict];
            break;
        case NETSLiveAttachmentWealthType:
            attachment = [self _decodeWealthWithDict:dict];
            break;
        case NETSLiveAttachmentTextType:
            attachment = [self _decodeTextWithDict:dict];
            break;
        case NETSSeatsNotificationWheatherLeaveSeats:
        case NETSSeatsNotificationAudienceJoinSeatsSuccess:
        case NETSSeatsNotificationAVChange:
            attachment = [self _decodeCustomAttachment:dict];
            break;
        default:
            break;
    }

    return attachment;
}

#pragma mark - private method

- (id<NIMCustomAttachment>)_decodePkWithDict:(nonnull NSDictionary *)dict
{
    NETSLivePKAttachment *attachment = [[NETSLivePKAttachment alloc] init];
    attachment.type = [dict[@"type"] integerValue];
    attachment.state = [dict[@"state"] integerValue];
    attachment.startedTimestamp = [dict[@"startedTimestamp"] longLongValue];
    attachment.currentTimestamp = [dict[@"currentTimestamp"] longLongValue];
    attachment.otherAnchorNickname = dict[@"otherAnchorNickname"] ?: @"";
    attachment.otherAnchorAvatar = dict[@"otherAnchorAvatar"] ?: @"";
    attachment.currentAnchorWin = [dict[@"currentAnchorWin"] intValue];
    
    return attachment;
}

- (id<NIMCustomAttachment>)_decodeWealthWithDict:(nonnull NSDictionary *)dict
{
    NETSLiveWealthChangeAttachment *attachment = [[NETSLiveWealthChangeAttachment alloc] init];
    attachment.giftId = [dict[@"giftId"] intValue];
    attachment.nickname = dict[@"nickname"];
    attachment.totalCoinCount = [dict[@"totalCoinCount"] intValue];
    attachment.PKCoinCount = [dict[@"PKCoinCount"] intValue];
    attachment.otherPKCoinCount = [dict[@"otherPKCoinCount"] intValue];
    attachment.rewardList = dict[@"rewardList"];
    attachment.otherRewardList = dict[@"otherRewardList"];
    attachment.fromUserAvRoomUid = dict[@"fromUserAvRoomUid"];
    
    NSMutableArray *originRewardList = [NSMutableArray arrayWithCapacity:[attachment.rewardList count]];
    for (NSDictionary *dict in attachment.rewardList) {
        NETSPassThroughHandleRewardUser *user = [NETSPassThroughHandleRewardUser yy_modelWithDictionary:dict];
        [originRewardList addObject:user];
    }
    attachment.originRewardList = [originRewardList copy];
    
    NSMutableArray *originOtherRewardList = [NSMutableArray arrayWithCapacity:[attachment.otherRewardList count]];
    for (NSDictionary *dict in attachment.otherRewardList) {
        NETSPassThroughHandleRewardUser *user = [NETSPassThroughHandleRewardUser yy_modelWithDictionary:dict];
        [originOtherRewardList addObject:user];
    }
    attachment.originOtherRewardList = [originOtherRewardList copy];
    
    return attachment;
}

- (id<NIMCustomAttachment>)_decodeTextWithDict:(nonnull NSDictionary *)dict
{
    NETSLiveTextAttachment *attachment = [[NETSLiveTextAttachment alloc] init];
    attachment.type = [dict[@"type"] integerValue];
    attachment.isAnchor = [dict[@"isAnchor"] boolValue];
    attachment.message = dict[@"message"];
    
    return attachment;
}

- (id<NIMCustomAttachment>)_decodeCustomAttachment:(nonnull NSDictionary *)dict {
    NETSConnectMicAttachment *attachment = [[NETSConnectMicAttachment alloc] init];
    attachment.type = [dict[@"type"] integerValue];
    attachment.status = [dict[@"status"] integerValue];
    attachment.fromUser = dict[@"fromUser"];
    NETSConnectMicMemberModel *memberModel = [NETSConnectMicMemberModel yy_modelWithDictionary:dict[@"member"]];
    attachment.member = memberModel;
    return attachment;
}

@end
