//
//  NETSAudienceChatRoomCell.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2021/1/7.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NELiveRoomListDetailModel;

@interface NETSAudienceChatRoomCell : UICollectionViewCell

/// 直播间模型
@property(nonatomic, strong) NELiveRoomListDetailModel *roomModel;

/**
 重置页面UI效果
 */
- (void)resetPageUserinterface;

/**
 关闭播放器,销毁资源
 */
- (void)shutdownPlayer;
//上下滑动时候，关闭上麦动作
- (void)closeConnectMicRoomAction;
@end

NS_ASSUME_NONNULL_END
