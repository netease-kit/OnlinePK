//
//  NETSAudienceSendGiftCell.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NETSGiftModel;

@interface NETSAudienceSendGiftCell : UICollectionViewCell

/// 实例化直播列表页cell
+ (NETSAudienceSendGiftCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                           indexPath:(NSIndexPath *)indexPath
                                               datas:(NSArray <NETSGiftModel *> *)datas;

/// 计算直播列表页cell size
+ (CGSize)size;

@end

NS_ASSUME_NONNULL_END
