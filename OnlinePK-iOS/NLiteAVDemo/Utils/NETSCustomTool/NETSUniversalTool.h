//
//  NETSUniversalTool.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/5/18.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NETSUniversalTool : NSObject
/**
 获取当前活跃的控制器

 @return 活跃控制器Vc
 */
+ (UIViewController  * _Nullable)getCurrentActivityViewController;

@end

NS_ASSUME_NONNULL_END
