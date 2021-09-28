//
//  NETSMultiConnectCollectionCell.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NETSConnectMicMemberModel;
@protocol NETSMultiConnectCollectionDelegate <NSObject>

/// 退出连麦
- (void)didCloseConnectRoom:(NSString *)userId;

@end

@interface NETSMultiConnectCollectionCell : UICollectionViewCell
/**
 注册Cell
 
 @param collectionView 注册的表格视图对象
 */
+(void)registerForCollectionView:(UICollectionView *)collectionView;

/**
 获取注册的Cell
 
 @param collectionView 表格视图对象
 @param indexPath indexPath
 @return 注册的Cell
 */
+(instancetype)settingCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@property(nonatomic, weak) id<NETSMultiConnectCollectionDelegate> delegate;


@property(nonatomic, strong) NESeatInfo *memberModel;
//角色类型
@property(nonatomic, assign) NETSUserMode roleType;
@end

NS_ASSUME_NONNULL_END
