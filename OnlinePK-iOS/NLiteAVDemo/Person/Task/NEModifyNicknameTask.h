//
//  NEModifyNicknameTask.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEModifyNicknameTask : NETask
@property(strong,nonatomic)NSString *req_nickname;
@end

NS_ASSUME_NONNULL_END
