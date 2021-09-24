//
//  NESeatInfoFilterModel.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/30.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NESeatInfoFilterModel : NSObject

//麦位操作请求编号
@property(nonatomic, strong) NSString *requestId;
//房间编号
@property(nonatomic, strong) NSString *roomId;
// 账号编号
@property(nonatomic, strong) NSString *accountId;
//麦序
@property(nonatomic, assign) NSInteger seatIndex;
/*
 0 麦位初始化（无人，可以上麦）
 1 观众正在申请麦位（占位）
 2 正在邀请观众上麦（占位)
 3 等待上麦（同意上麦，等待用户加入音视频房间）
 4 正在麦上（有人）
 5 麦位关闭（无人）
 */
@property(nonatomic, assign) NSInteger state;

@property(nonatomic, strong) NSString *attachment;
//音频状态 1 打开 0：关闭 -1 ：禁用麦克风
@property(nonatomic, assign) NSInteger audioState;
//视频状态 1 打开 0：关闭 -1 ：禁用视频
@property(nonatomic, assign) NSInteger videoState;
//昵称
@property(nonatomic, strong) NSString *nickName;
//头像
@property(nonatomic, strong) NSString *avatar;

@end

NS_ASSUME_NONNULL_END
