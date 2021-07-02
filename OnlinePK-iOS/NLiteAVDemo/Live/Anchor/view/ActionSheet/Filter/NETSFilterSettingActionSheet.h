//
//  NETSFilterSettingActionSheet.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/12.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSBaseActionSheet.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSBeautyParam;

@interface NETSFilterSettingActionSheet : NETSBaseActionSheet

///
/// 展示滤镜设置ActionSheet
///
+ (void)show;

/**
 展示滤镜设置ActionSheet
 @param mask    - 是否显示背景遮罩
 */
+ (void)showWithMask:(BOOL)mask;

@end

NS_ASSUME_NONNULL_END
