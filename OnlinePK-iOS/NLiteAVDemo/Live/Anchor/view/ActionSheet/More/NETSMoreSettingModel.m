//
//  NETSMoreSettingModel.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSMoreSettingModel.h"

@implementation NETSMoreSettingModel

- (instancetype)initWithDisplay:(NSString *)display
                           icon:(NSString *)icon
                           type:(NETSMoreSettingType)type
{
    self = [super init];
    if (self) {
        _display = display;
        _icon = icon;
        _type = type;
    }
    return self;
}

- (NSString *)displayIcon
{
    return _icon;
}

@end

///

@implementation NETSMoreSettingStatusModel

- (instancetype)initWithDisplay:(NSString *)display
                           icon:(NSString *)icon
                           type:(NETSMoreSettingType)type
                    disableIcon:(NSString *)disableIcon
                        disable:(BOOL)disable
{
    self = [super initWithDisplay:display icon:icon type:type];
    if (self) {
        self.disableIcon = disableIcon;
        self.disable = disable;
    }
    return self;
}

/// 展示图标名称
- (NSString *)displayIcon
{
    return _disable ? self.disableIcon : self.icon;
}

@end
