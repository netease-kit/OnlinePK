//
//  NETSPkTimeLabel.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// PK时间显示框
///

@interface NETSPkTimeLabel : UILabel

@property (nonatomic, assign, readonly)   BOOL        isCounting;
@property (nonatomic, copy) NSString    *prefix;

///
/// 开始倒计时
/// @param seconds  - 倒计时秒钟(<3600)
/// @return 倒计时状态 YES-成功 NO-失败
///
- (BOOL)countdownWithSeconds:(int32_t)seconds;

///
/// 停止计时
///
- (void)stopCountdown;

@end

NS_ASSUME_NONNULL_END
