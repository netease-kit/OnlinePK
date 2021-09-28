//
//  NETSBeautySettingActionSheet.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/12.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSBaseActionSheet.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSBeautyParam;

///
/// 美颜设置ActionSheet
///

@interface NETSBeautySettingActionSheet : NETSBaseActionSheet

///
/// 展示美颜设置ActionSheet
///
+ (void)show;

/**
 取消遮罩展示美颜设置ActionSheet
 @param mask - 是否显示遮罩
 */
+ (void)showWithMask:(BOOL)mask;

@end

NS_ASSUME_NONNULL_END
