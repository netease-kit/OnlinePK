//
//  NETSMutiConnectView.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@protocol NETSMutiConnectViewDelegate <NSObject>

//断开连麦
- (void)disconnectRoomWithUserId:(NSString *)userId;

@end

@interface NETSMutiConnectView : UIView

/// 构造函数
/// @param dataArray collectionview的数据源
- (instancetype)initWithDataSource:(NSArray *)dataArray frame:(CGRect)frame;



@property(nonatomic, weak) id<NETSMutiConnectViewDelegate> delegate;

//角色类型
@property(nonatomic, assign) NETSUserMode roleType;


/// 刷新本地数据状态
/// @param updateDataArray 更新的数据
- (void)reloadDataSource:(NSArray <NESeatInfo *>*)updateDataArray;
@end

NS_ASSUME_NONNULL_END
