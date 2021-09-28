//
//  NEUser.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEUser : NSObject<NSCoding>

/// 用户系统手机号
@property(strong,nonatomic)NSString *mobile;
/// 用户头像
@property(strong,nonatomic)NSString *avatar;
/// 云信IM 账号ID
@property(strong,nonatomic,nonnull)NSString *imAccid;
/// 云信IM token
@property(strong,nonatomic,nonnull)NSString *imToken;
/// 用户系统登录token
@property(strong,nonatomic)NSString *accessToken;
/// 音视频房间ID
@property(assign,nonatomic)NSString *avRoomUid;

@property(strong,nonatomic)NSString *accountId;
@property(strong,nonatomic)NSString *nickname;


- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
