//
//  NETSMoreSettingActionSheet.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSBaseActionSheet.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSMoreSettingModel;
@class NETSMoreSettingActionSheet;

///
/// 直播过程中 更多设置
///

@protocol NETSMoreSettingActionSheetDelegate <NSObject>

/**
 开启/关闭 摄像头
 */
- (void)didSelectCameraEnable:(BOOL)enable;

///
/// 触发更多设置-结束直播
///
- (void)didSelectCloseLive;

@end

@interface NETSMoreSettingActionSheet : NETSBaseActionSheet

///
/// 直播中 展示更多设置面变
/// @param target   - 代理对象
/// @param items    - 数据源
///
+ (void)showWithTarget:(id<NETSMoreSettingActionSheetDelegate>)target
                 items:(NSArray <NETSMoreSettingModel *> *)items;

@end

NS_ASSUME_NONNULL_END
