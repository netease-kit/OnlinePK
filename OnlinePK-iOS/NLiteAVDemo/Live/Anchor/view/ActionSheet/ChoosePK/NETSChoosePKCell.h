//
//  NETSChoosePKCell.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NELiveRoomListDetailModel;

@protocol NETSChoosePKCellDelegate <NSObject>

- (void)didClickPKModel:(NELiveRoomListDetailModel *)model;

@end

///
/// 选择主播PK cell
///
@interface NETSChoosePKCell : UITableViewCell

@property (nonatomic, weak) id<NETSChoosePKCellDelegate> delegate;

+ (NETSChoosePKCell *)cellWithTableView:(UITableView *)tableView
                              indexPath:(NSIndexPath *)indexPath
                                  datas:(NSArray <NELiveRoomListDetailModel *> *)datas;

+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
