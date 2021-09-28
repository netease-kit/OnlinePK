//
//  NETSAudienceCollectionView.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2021/1/7.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSBaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

@class NELiveRoomListDetailModel;
@interface NETSAudienceCollectionViewVC : NETSBaseViewController

/// 构造函数
/// @param liveData 直播数据源
/// @param selectRoomIndex 选中的房间
- (instancetype)initWithScrollData:(NSArray<NELiveRoomListDetailModel *> *)liveData currentRoom:(NSInteger)selectRoomIndex;

@end

NS_ASSUME_NONNULL_END
