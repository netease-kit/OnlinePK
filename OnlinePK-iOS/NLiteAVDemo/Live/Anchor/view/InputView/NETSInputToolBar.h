//
//  NETSInputToolBar.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 直播过程 底部工具条
/// 固定高度 36
///

typedef enum : NSUInteger {
    NETSInputToolBarUnknown = 0,
    NETSInputToolBarInput,
    NETSInputToolBarBeauty,
    NETSInputToolBarFilter,
    NETSInputToolBarMusic,
    NETSInputToolBarMore,
    NETSInputToolBarConnectRequest
} NETSInputToolBarAction;

@protocol NETSInputToolBarDelegate <NSObject>

///
/// 触发工具条动作
/// @param action   - 动作事件
///
- (void)clickInputToolBarAction:(NETSInputToolBarAction)action;

@end

@interface NETSInputToolBar : UIView

@property (nonatomic, strong, readonly)   UITextField     *textField;
@property (nonatomic, weak) id<NETSInputToolBarDelegate>    delegate;

/// 取消第一响应
- (void)resignFirstResponder;

//pk直播和非pk直播按钮icon的切换
- (void)scenarioChanged:(NSString *)changeIconName;
@end

NS_ASSUME_NONNULL_END
