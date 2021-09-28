//
//  NETSCanvasModel.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/15.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NERtcVideoCanvas;

@interface NETSCanvasModel : NSObject

//用户ID
@property (nonatomic, assign) uint64_t uid;

//渲染视图
@property (nonatomic, weak) UIView *renderContainer;

//已订阅了视频流
@property (nonatomic, assign) BOOL subscribedVideo;

//建立SDK Canvas
- (NERtcVideoCanvas *)setupCanvas;

//重置Canvas
- (void)resetCanvas;

@end

NS_ASSUME_NONNULL_END
