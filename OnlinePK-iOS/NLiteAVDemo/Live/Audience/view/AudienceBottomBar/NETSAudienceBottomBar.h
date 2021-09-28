//
//  NETSAudienceBottomBar.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 客户端底部工具条
///
@protocol NETSAudienceBottomBarDelegate <NSObject>

- (void)clickTextLabel:(UILabel *)label;
- (void)clickGiftBtn;
- (void)clickCloseBtn;

/// //观众请求连麦按钮的点击事件(请求连麦，查看连麦状态)
/// @param requestType 按钮状态
- (void)clickRequestConnect:(NETSAudienceBottomRequestType)requestType;

@end

@interface NETSAudienceBottomBar : UIView


@property(nonatomic, assign) NERoomType roomType;

@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, weak) id<NETSAudienceBottomBarDelegate> delegate;
//申请连麦按钮的状态
@property(nonatomic, assign) NETSAudienceBottomRequestType buttonType;
/// 取消第一响应
- (void)resignFirstResponder;

@end

NS_ASSUME_NONNULL_END
