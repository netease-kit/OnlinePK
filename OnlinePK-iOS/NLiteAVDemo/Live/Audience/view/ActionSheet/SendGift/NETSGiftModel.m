//
//  NETSGiftModel.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/26.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSGiftModel.h"

@implementation NETSGiftModel

- (instancetype)initWithGiftId:(int32_t)giftId icon:(NSString *)icon display:(NSString *)display price:(int32_t)price
{
    self = [super init];
    if (self) {
        _giftId = giftId;
        _icon = icon;
        _display = display;
        _price = price;
    }
    return self;
}

@end
