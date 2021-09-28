//
//  NETSLiveSegmentedSettingModel.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/16.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSLiveSegmentedSettingModel.h"

@implementation NETSLiveSegmentedSettingModel

- (instancetype)initWithDisplay:(NSString *)display value:(NSInteger)value
{
    self = [super init];
    if (self) {
        _display = display;
        _value = value;
    }
    return self;
}

@end
