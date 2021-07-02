//
//  NEMenuHeader.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/18.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEMenuHeader : UITableViewHeaderFooterView

@property (nonatomic, assign) NSInteger    section;

/**
 获取组头高度
 */
+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
