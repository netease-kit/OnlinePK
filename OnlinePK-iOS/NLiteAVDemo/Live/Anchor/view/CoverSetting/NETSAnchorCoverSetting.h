//
//  NETSAnchorCoverSetting.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/10.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 主播直播视图 封面设置面板
///

@interface NETSAnchorCoverSetting : UIView

/// 直播主题
- (NSString *)getTopic;

// 直播封面
- (NSString *)getCover;

@end

NS_ASSUME_NONNULL_END
