//
//  NETSToast.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/3.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "UIView+Toast.h"

NS_ASSUME_NONNULL_BEGIN

@interface NETSToast : NSObject

/**
 展示toast信息
 */
+ (void)showToast:(NSString *)toast;

/**
 展示toast信息
 */
+ (void)showToast:(NSString *)toast pos:(id)pos;

/**
 展示loading图
 */
+ (void)showLoading;

/**
 销毁loading图
 */
+ (void)hideLoading;

@end

NS_ASSUME_NONNULL_END
