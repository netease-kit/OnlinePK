//
//  NETSApiOptions.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSApiOptions.h"
#import "AppKey.h"

@implementation NETSApiOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        _host = kApiHost;
        _timeoutInterval = 10;
    }
    return self;
}

@end
