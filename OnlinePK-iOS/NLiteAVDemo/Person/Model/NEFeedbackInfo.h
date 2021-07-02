//
//  NEFeedbackInfo.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/22.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEFeedbackInfo : NSObject
@property(assign,nonatomic)NSInteger code;
@property(strong,nonatomic)NSString *title;
@property(assign,nonatomic)BOOL isSelected;
@property(strong,nonatomic)NSMutableArray <NEFeedbackInfo *>*items;

@end

NS_ASSUME_NONNULL_END
