//
//  NETabbarController.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/11.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NETabbarController : UITabBarController

@property(nonatomic,strong,readonly) UINavigationController *menuNavController;

@end

NS_ASSUME_NONNULL_END
