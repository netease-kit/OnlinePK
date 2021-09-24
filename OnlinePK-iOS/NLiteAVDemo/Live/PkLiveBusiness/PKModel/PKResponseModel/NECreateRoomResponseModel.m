//
//  NECreateRoomResponseModel.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/16.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NECreateRoomResponseModel.h"


@implementation NECreateRoomResponseModel
+ (NSDictionary *)modelContainerPropertyGenericClass
{
  return @{@"anchor" : [NECreateRoomAnchorModel class],
           @"live":[NECreateRoomLiveModel class]};
}
@end

@implementation NECreateRoomAnchorModel


@end

@implementation NECreateRoomLiveModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
  return @{@"liveConfig":[NELiveConfigModel class]};
}
@end

@implementation NELiveConfigModel


@end
