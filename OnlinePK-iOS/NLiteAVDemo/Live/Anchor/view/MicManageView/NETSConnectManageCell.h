//
//  NETSConnectManageCell.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/26.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSBaseTabViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSConnectMicMemberModel;
@protocol NETSMicManageViewDelegate <NSObject>

/// 关闭视屏
/// @param isClose 是否关闭
- (void)didCloseVideo:(BOOL)isClose accountId:(NSString *)accountId;
/// 关闭麦克风
/// @param isClose 是否关闭
/// @param accountId 被操作的用户id
- (void)didCloseMicrophone:(BOOL)isClose accountId:(NSString *)accountId;

/// 挂断连麦
/// @param userModel 被操作的用户模型
- (void)didHangUpConnectAccountId:(NETSConnectMicMemberModel *)userModel;

@end



@interface NETSConnectManageCell : NETSBaseTabViewCell

/// 加载cell
/// @param tableView tableview
+ (instancetype)loadConnectManageCellWithTableView:(UITableView *)tableView;

@property(nonatomic, weak) id<NETSMicManageViewDelegate>delegate;

@property(nonatomic, strong) NSIndexPath *cellIndexPath;

@property(nonatomic, strong) NETSConnectMicMemberModel *userModel;

@end

NS_ASSUME_NONNULL_END
