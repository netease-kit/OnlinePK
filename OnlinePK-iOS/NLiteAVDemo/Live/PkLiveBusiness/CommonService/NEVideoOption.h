//
//  NEVideoOption.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/16.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEVideoOption : NSObject


/// 开始预览
- (void)startVideoPreview;
//设置远端视图
- (void)setupRemoteView;
/// 设置本地视图
- (void)setupLocalView;
//切换摄像头
- (void)switchCamera;
/// 设置video回调，美颜的口子
- (void)setVideoCallback;
/// 关闭本地摄像头
- (void)muteLocalVideoStream;
/// 结束预览
- (void)stopVideoPreview;

@end

NS_ASSUME_NONNULL_END
