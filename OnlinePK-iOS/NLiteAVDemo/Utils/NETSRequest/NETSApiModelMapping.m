//
//  NETSApiModelMapping.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSApiModelMapping.h"

@implementation NETSApiModelMapping

+ (instancetype)mappingWith:(NSString *)keyPath mappingClass:(Class)mappingClass isArray:(BOOL)isArray
{
    NSAssert([keyPath length] > 0, @"keyPath 为空");
    NSAssert(mappingClass, @"mappingClass 为空");
    NETSApiModelMapping *mapping = [[NETSApiModelMapping alloc] init];
    mapping.keyPath = keyPath;
    mapping.mappingClass = mappingClass;
    mapping.isArray = isArray;
    
    return mapping;
}

@end
