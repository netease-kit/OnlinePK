//
//  NETSLiveChatView.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 直播IM视图
///

@protocol NETSLiveChatViewDelegate <NSObject>

///
/// 点击IM对话视图
/// @param point    - 新增的消息数组
///
- (void)onTapChatView:(CGPoint)point;

@end

@interface NETSLiveChatView : UIView

/// 会话tableview
@property (nonatomic,strong) UITableView *tableView;
/// 代理句柄
@property (nonatomic,weak) id<NETSLiveChatViewDelegate> delegate;

///
/// 增加消息
/// @param messages - 新增的消息数组
///
- (void)addMessages:(NSArray<NIMMessage *> *)messages;
//清空数据
- (void)clearData;

@end

NS_ASSUME_NONNULL_END
