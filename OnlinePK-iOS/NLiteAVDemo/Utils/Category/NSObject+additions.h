
//
//  NSObject+additions.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/1.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.
#import <Foundation/Foundation.h>

@interface NSObject (additions)

/**
 *  判断对象是否为空
 *  PS：nil、NSNil、@""、@0 以上4种返回YES
 *
 *  @return YES 为空  NO 为实例对象
 */
+ (BOOL)isNullOrNilWithObject:(id)object;

@end
