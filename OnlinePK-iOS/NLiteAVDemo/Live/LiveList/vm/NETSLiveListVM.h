//
//  NETSLiveListVM.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/9.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NELiveRoomListDetailModel;

///
/// 直播列表页 VM
///

@interface NETSLiveListVM : NSObject

/// 数据源集合
@property (nonatomic, strong, readonly) NSArray <NELiveRoomListDetailModel *> *datas;
/// 是否结束
@property (nonatomic, assign, readonly) BOOL    isEnd;
/// 是否正在加载
@property (nonatomic, assign, readonly) BOOL    isLoading;
/// 加载error
@property (nonatomic, assign, readonly) NSError *error;

/// 加载数据
- (void)load;

/// 加载更多
- (void)loadMore;

//请求列表所需房间类型
@property(nonatomic, assign) NERoomType roomType;
@end

NS_ASSUME_NONNULL_END
