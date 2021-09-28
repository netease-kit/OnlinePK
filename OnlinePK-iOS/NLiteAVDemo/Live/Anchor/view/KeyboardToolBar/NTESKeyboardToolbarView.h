//
//  NETSKeyboardToolbar.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/20.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NTESKeyboardToolbarDelegate <NSObject>

/**
 点击工具条发送文字
 @param text    - 文本
 */
- (void)didToolBarSendText:(NSString *)text;

@end

@interface NTESKeyboardToolbarView : UIView


@property (nonatomic, weak) id<NTESKeyboardToolbarDelegate> cusDelegate;

////相应成为第一响应者
- (void)becomeFirstResponse;

- (void)setUpInputContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
