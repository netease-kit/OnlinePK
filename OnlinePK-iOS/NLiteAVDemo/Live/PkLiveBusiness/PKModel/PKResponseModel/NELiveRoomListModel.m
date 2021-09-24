//
//  NELiveRoomListModel.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NELiveRoomListModel.h"


@implementation NELiveRoomListDetailLiveConfigModel

@end


@implementation NELiveRoomListDetailAnchorModel

@end


@implementation NELiveRoomListDetailLiveModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
  return @{@"liveConfig" : [NELiveRoomListDetailLiveConfigModel class]};
}
@end


@implementation NELiveRoomListDetailModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
  return @{@"anchor" : [NELiveRoomListDetailAnchorModel class],
           @"live":[NELiveRoomListDetailLiveModel class]};
}
@end


@implementation NELiveRoomListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
  return @{@"list" : [NELiveRoomListDetailModel class]};
}
@end
