//
//  NESendSmsCodeTask.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/27.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NETask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NESendSmsCodeTask : NETask
@property (nonatomic, copy) NSString    *req_mobile;
@end

NS_ASSUME_NONNULL_END
