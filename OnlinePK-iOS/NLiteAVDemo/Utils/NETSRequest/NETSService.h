//
//  NETSService.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NETSRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface NETSService : NSObject

+ (instancetype)shared;

- (void)runRequest:(NSURLRequest *)request completion:(void(^)(NSData * _Nullable data, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
