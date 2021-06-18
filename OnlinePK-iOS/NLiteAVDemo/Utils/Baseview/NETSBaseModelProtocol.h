//
//  NETSBaseModelProtocol.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/30.
//  Copyright © 2020 Netease. All rights reserved.
//

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
