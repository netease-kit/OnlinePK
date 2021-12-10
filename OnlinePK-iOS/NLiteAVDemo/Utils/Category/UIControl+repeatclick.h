//
//  UIControl+repeatclick.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/10.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file



#import <UIKit/UIKit.h>

@interface UIControl (repeatclick)
@property (nonatomic, assign) NSTimeInterval ne_acceptEventInterval;//添加点击事件的间隔时间

@property (nonatomic, assign) BOOL ne_ignoreEvent;//是否忽略点击事件,不响应点击事件

@end
