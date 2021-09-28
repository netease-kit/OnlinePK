//
//  NETSBaseModelProtocol.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/30.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

@protocol NETSBaseModelProtocol <NSObject>

@optional

/**
 初始化配置方法
 */
- (void)fb_initialize;

/**
 数据解析

 @param data 源数据
 */
- (void)dataParsing:(id)data;

@end
