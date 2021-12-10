//
//  NTESMoreItem.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/27.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NTESCollectStatusItem.h"

@implementation NTESCollectStatusItem

+ (instancetype)itemWithTitle:(NSString *)title onImage:(UIImage *)onImage offImage:(nullable UIImage *)offImage tag:(NSInteger)tag {
    NTESCollectStatusItem *item = [[NTESCollectStatusItem alloc] init];
    item.title = title;
    item.onImage = onImage;
    item.offImage = offImage;
    item.tag = tag;
    return item;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.on = YES;
    }
    return self;
}

- (UIImage *)currentImage {
    return self.on ? self.onImage : self.offImage;
}

@end
