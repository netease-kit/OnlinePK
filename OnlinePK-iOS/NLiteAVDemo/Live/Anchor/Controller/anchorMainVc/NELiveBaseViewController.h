//
//  NELiveBaseViewController.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/12.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NETSLiveChatView.h"

NS_ASSUME_NONNULL_BEGIN

@class NECreateRoomResponseModel;
@interface NELiveBaseViewController : UIViewController

//创建房间模型
@property(nonatomic, strong,readonly) NECreateRoomResponseModel *createRoomModel;

/// 绘制摄像头采集
@property (nonatomic, strong,readonly)   UIView *localRender;
/// 远端视频面板
@property (nonatomic, strong,readonly)   UIView *remoteRender;

/// 聊天视图
@property (nonatomic,strong)   NETSLiveChatView  *chatView;
/// 构造方法
/// @param roomType 房间类型
- (instancetype)initWithRoomType:(NERoomType)roomType;


//切换到单人直播模式UI
- (void)layoutSingleLive;

/// 切换到pk直播模式UI
- (void)layoutPkLive;

//创建房间成功刷新UI
- (void)createRoomRefreshUI;

//更新文本消息
- (void)chatViewAddMessge:(NSArray<NIMMessage *> *)messages;

/// 连麦管理按钮点击事件
- (void)connectMicManagerClick;

/// 建立本地canvas模型
- (NERtcVideoCanvas *)setupLocalCanvas;
/// 建立单人直播canvas模型
- (NERtcVideoCanvas *)setupSingleCanvas;
//主播关闭房间
- (void)closeLiveRoom;
@end

NS_ASSUME_NONNULL_END
