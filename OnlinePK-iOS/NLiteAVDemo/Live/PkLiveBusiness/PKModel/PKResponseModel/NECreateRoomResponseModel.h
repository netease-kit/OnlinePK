//
//  NECreateRoomResponseModel.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/16.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NECreateRoomAnchorModel,NECreateRoomLiveModel,NELiveConfigModel;

@interface NECreateRoomResponseModel : NSObject
@property (nonatomic, strong)   NECreateRoomAnchorModel *anchor;
@property (nonatomic, strong)   NECreateRoomLiveModel *live;
//seatList members为临时接口 可删除
@property(nonatomic, strong) NSArray *seatList;
@property(nonatomic, strong) NSArray *members;

@end


@interface NECreateRoomAnchorModel : NSObject

@property (nonatomic, copy)     NSString *accountId;
@property (nonatomic, copy)     NSString *imAccid;
@property (nonatomic, assign)   int64_t  roomUid;
@property (nonatomic, copy)     NSString *nickname;
@property (nonatomic, copy)     NSString *avatar;
@property (nonatomic, copy)     NSString *roomCheckSum;

@end

@interface NECreateRoomLiveModel : NSObject

@property (nonatomic, assign)   int64_t     appId;
@property (nonatomic, copy)     NSString    *roomId;
@property (nonatomic, copy)     NSString    *creatorAccountId;
//房间类型 2 pk 3 pk连麦
@property (nonatomic, assign)   int32_t     type;
@property (nonatomic, assign)   int32_t     status;
@property (nonatomic, assign)   int32_t     liveStatus;
@property (nonatomic, copy)     NSString    *roomTopic;
@property (nonatomic, copy)     NSString    *cover;
@property (nonatomic, copy)     NSString    *roomCid;
@property (nonatomic, copy)     NSString    *roomCname;
@property (nonatomic, assign)   NSString    *chatRoomId;
@property (nonatomic, copy)     NSString    *chatRoomCreator;
@property (nonatomic, assign)   int32_t     rewardTotal;
@property (nonatomic, assign)   int64_t     audienceCount;
@property (nonatomic, strong)    NELiveConfigModel *liveConfig;

@end

@interface NELiveConfigModel : NSObject

@property (nonatomic, copy)     NSString    *httpPullUrl;
@property (nonatomic, copy)     NSString    *rtmpPullUrl;
@property (nonatomic, copy)     NSString    *hlsPullUrl;
@property (nonatomic, copy)     NSString    *pushUrl;
@property (nonatomic, copy)     NSString    *cid;

@end

NS_ASSUME_NONNULL_END
