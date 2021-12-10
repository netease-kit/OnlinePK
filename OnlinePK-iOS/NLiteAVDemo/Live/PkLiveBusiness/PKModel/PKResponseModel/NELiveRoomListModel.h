//
//  NELiveRoomListModel.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NELiveRoomListDetailLiveConfigModel : NSObject
@property (nonatomic, strong) NSString    *httpPullUrl;
@property (nonatomic, strong) NSString    *rtmpPullUrl;
@property (nonatomic, strong) NSString    *hlsPullUrl;
@property (nonatomic, strong) NSString    *pushUrl;
@property (nonatomic, strong) NSString    *cid;
@end


@interface NELiveRoomListDetailAnchorModel : NSObject
//用户编号
@property(nonatomic, strong) NSString *accountId;
//IM 用户编号
@property(nonatomic, strong) NSString *imAccid;
//房间用户编号
@property(nonatomic, assign) int64_t roomUid;
//昵称
@property(nonatomic, strong) NSString *nickname;
//头像
@property(nonatomic, strong) NSString *avatar;
//房间校验码
@property(nonatomic, strong) NSString *roomCheckSum;
@end


@interface NELiveRoomListDetailLiveModel : NSObject
//用户编号
@property(nonatomic, assign) int64_t appId;
//房间编号
@property(nonatomic, strong) NSString *roomId;
//创建人账号
@property(nonatomic, strong) NSString *creatorAccountId;
//房间类型
@property(nonatomic, assign) NSInteger type;
//房间状态
@property(nonatomic, assign) NSInteger status;
//直播状态
@property(nonatomic, assign) NEPkliveStatus liveStatus;
//房间主题
@property(nonatomic, strong) NSString *roomTopic;
//背景图地址
@property(nonatomic, strong) NSString *cover;
//音视频房间编号
@property(nonatomic, strong) NSString *roomCid;
//音视频房间名
@property(nonatomic, strong) NSString *roomCname;
//聊天室编号
@property(nonatomic, strong) NSString *chatRoomId;
//聊天室创建人编号
@property(nonatomic, strong) NSString *chatRoomCreator;
//打赏总额
@property(nonatomic, assign) int64_t rewardTotal;
//观众人数
@property(nonatomic, assign) int32_t audienceCount;
//直播配置
@property(nonatomic, strong) NELiveRoomListDetailLiveConfigModel *liveConfig;
@end


@interface NELiveRoomListDetailModel : NSObject
@property(nonatomic, strong) NELiveRoomListDetailAnchorModel *anchor;
@property(nonatomic, strong) NELiveRoomListDetailLiveModel *live;
@end

@interface NELiveRoomListModel : NSObject

//总数据量
@property(nonatomic, assign) int64_t total;
//当前页
@property(nonatomic, assign) NSInteger pageNum;
//页大小
@property(nonatomic, assign) NSInteger pageSize;
//当前页数据量
@property(nonatomic, assign) NSInteger size;
//数据列表
@property(nonatomic, assign) NSArray<NELiveRoomListDetailModel *> *list;

@end





NS_ASSUME_NONNULL_END
