//
//  NEPkCreateRoomParams.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/13.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEPkCreateRoomParams : NSObject

//房间主题
@property(nonatomic, strong) NSString *roomTopic;
//封面地址
@property(nonatomic, strong) NSString *cover;
//房间类型 (这里只支持 2 3)
@property(nonatomic, assign) NERoomType roomType;
//1 rtc 推流 0 cdn推流
@property(nonatomic, assign) NELiveRoomPushType pushType;

@end

NS_ASSUME_NONNULL_END
