//
//  NETSAudienceVM.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NETSLiveChatroomInfo.h"
#import "NETSLiveConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface NETSAudienceVM : NSObject

/// 聊天室信息
@property (nonatomic, strong) NETSLiveChatroomInfo  *chatroom;

@end

NS_ASSUME_NONNULL_END
