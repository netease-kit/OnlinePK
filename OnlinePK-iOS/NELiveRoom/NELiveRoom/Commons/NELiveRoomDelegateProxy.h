//
//  NELiveRoomDelegateProxy.h
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/10.
//  Copyright © 2021 NetEase. All rights reserved.
//

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
