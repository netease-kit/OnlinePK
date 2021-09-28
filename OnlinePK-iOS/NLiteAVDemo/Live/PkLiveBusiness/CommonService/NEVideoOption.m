//
//  NEVideoOption.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/16.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEVideoOption.h"

@implementation NEVideoOption


- (void)switchCamera{
    int ret = [[NERtcEngine sharedEngine] switchCamera];
    if (ret != 0) {
        YXAlogInfo(@"switchCamera failed,Error: %@",NERtcErrorDescription(ret));
    }
}

@end
