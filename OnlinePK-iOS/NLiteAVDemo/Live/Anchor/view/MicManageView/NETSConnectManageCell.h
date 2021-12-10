//
//  NETSConnectManageCell.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/26.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSBaseTabViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@class NESeatInfoFilterModel;
@protocol NETSMicManageViewDelegate <NSObject>

/// 关闭视屏
/// @param isClose 是否关闭
- (void)didCloseVideo:(BOOL)isClose accountId:(NSString *)accountId;
/// 关闭麦克风
/// @param isClose 是否关闭
/// @param accountId 被操作的用户id
- (void)didCloseMicrophone:(BOOL)isClose accountId:(NSString *)accountId;

/// 挂断连麦
/// @param hangUpModel 被操作的用户模型
- (void)didHangUpConnectAccountId:(NESeatInfoFilterModel *)hangUpModel;

@end



@interface NETSConnectManageCell : NETSBaseTabViewCell

/// 加载cell
/// @param tableView tableview
+ (instancetype)loadConnectManageCellWithTableView:(UITableView *)tableView;

@property(nonatomic, weak) id<NETSMicManageViewDelegate>delegate;

@property(nonatomic, strong) NSIndexPath *cellIndexPath;

@property(nonatomic, strong) NESeatInfoFilterModel *userModel;

@end

NS_ASSUME_NONNULL_END
