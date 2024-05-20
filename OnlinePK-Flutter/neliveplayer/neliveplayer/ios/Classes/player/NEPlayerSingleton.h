// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NELivePlayerFramework/NELivePlayerFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEPlayerSingleton : NSObject

// 单例
+ (instancetype)shared;

// 播放器集合
@property(nonatomic, strong) NSMutableDictionary<NSString *, NELivePlayerController *> *players;

@end

NS_ASSUME_NONNULL_END
