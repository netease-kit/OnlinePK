//
//  NETSPullStreamErrorView.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/18.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSLiveBaseErrorView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 拉流失败窗体
 */

@protocol NETSPullStreamErrorViewDelegate <NSObject>

/**
 点击返回按钮
 */
- (void)clickBackAction;

/**
 点击重新连接按钮
 */
- (void)clickRetryAction;

@end

@interface NETSPullStreamErrorView : NETSLiveBaseErrorView

@property (nonatomic, weak) id<NETSPullStreamErrorViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
