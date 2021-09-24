//
//  UIViewController+Gesture.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2021/1/12.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Gesture)

/// 关闭侧滑手势
/// @param VC 传入控制器
+ (void)popGestureClose:(UIViewController *)VC;


/// 开启侧滑手势
/// @param VC 传入控制器
+ (void)popGestureOpen:(UIViewController *)VC;

@end

NS_ASSUME_NONNULL_END
