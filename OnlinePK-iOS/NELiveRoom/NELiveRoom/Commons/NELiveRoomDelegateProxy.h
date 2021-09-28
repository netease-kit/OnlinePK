//
//  NELiveRoomDelegateProxy.h
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/10.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NELiveRoomDelegateProxy : NSProxy

/// 初始化
- (instancetype)init;

/// 获取全局实例
+ (instancetype)sharedProxy;

/// 添加代理对象
- (void)addDelegate:(id)delegate NS_SWIFT_NAME(add(delegate:));

/// 移除代理对象
- (void)removeDelegate:(id)delegate NS_SWIFT_NAME(remove(delegate:));


@end

NS_ASSUME_NONNULL_END
