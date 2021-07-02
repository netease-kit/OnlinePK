//
//  NEModifyNicknameTask.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEModifyNicknameTask.h"

@implementation NEModifyNicknameTask
+ (instancetype)task {
    return [self taskWithSubURL:@"/auth/updateNickname"];
}
@end
