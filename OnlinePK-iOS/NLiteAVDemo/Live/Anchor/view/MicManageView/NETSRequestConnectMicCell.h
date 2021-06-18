//
//  NETSRequestConnectMicCell.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/26.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSBaseTabViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@protocol NETSMicRequestViewDelegate <NSObject>


/// 处理连麦申请
/// @param isAccept 是否接受
/// @param accountId 用户id
- (void)dealMicRequestAccept:(BOOL)isAccept accountId:(NSString *)accountId;
@end

@class NETSConnectMicMemberModel;

@interface NETSRequestConnectMicCell : NETSBaseTabViewCell
/// 加载cell
/// @param tableView tableview
+ (instancetype)loadRequestConnectMicCellWithTableView:(UITableView *)tableView;

@property(nonatomic, weak) id<NETSMicRequestViewDelegate> delegate;

@property(nonatomic, strong) NSIndexPath *cellIndexPath;

@property(nonatomic, strong) NETSConnectMicMemberModel *userModel;

@end

NS_ASSUME_NONNULL_END
