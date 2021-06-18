//
//  NETSConnectMicModel.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/5/14.
//  Copyright © 2021 Netease. All rights reserved.
//pk多人连麦，透传数据模型

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

//麦位消息协议结构体 member模型
@interface NETSConnectMicMemberModel : NSObject
//用户账号
@property (nonatomic, copy) NSString *accountId;
//房间id
@property(nonatomic, copy) NSString *avRoomUid;

@property(nonatomic, copy) NSString *avRoomCid;

@property(nonatomic, copy) NSString *avRoomCName;
//相当于joinchannel的token
@property(nonatomic, copy) NSString *avRoomCheckSum;
//用户昵称
@property (nonatomic, copy) NSString *nickName;
//用户头像
@property (nonatomic, copy) NSString *avatar;
//音频开关：1打开 0 关闭
@property (nonatomic, assign) NSInteger audio;
//视频开关：1打开 0 关闭
@property (nonatomic, assign) NSInteger video;

- (nullable NSDictionary *)getConnectMicMemberDictionary;
@end


@interface NETSConnectMicModel : NSObject
//当前麦位状态 0-3
@property(nonatomic, assign) NETSSeatsStatus status;
//麦位状态通知type
@property(nonatomic, assign) NETSSeatsOperation type;
@property(nonatomic, strong) NETSConnectMicMemberModel *member;
//用来判断是否是自己
@property(nonatomic, strong) NSString *fromUser;
@end





NS_ASSUME_NONNULL_END
