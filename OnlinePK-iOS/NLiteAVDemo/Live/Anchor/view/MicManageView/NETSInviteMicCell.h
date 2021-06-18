//
//  NETSInviteMicCell.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/26.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSBaseTabViewCell.h"

NS_ASSUME_NONNULL_BEGIN


@protocol NETSInviteMicViewDelegate <NSObject>

/// 邀请上麦
/// @param audienceId 员工id
- (void)didInviteAudienceConnectMic:(NSString *)audienceId;

@end

@class NETSConnectMicMemberModel;

@interface NETSInviteMicCell : NETSBaseTabViewCell

/// 加载cell
/// @param tableView tableview
+ (instancetype)loadInviteMicCellWithTableView:(UITableView *)tableView;

@property(nonatomic, weak) id<NETSInviteMicViewDelegate>delegate;

@property(nonatomic, strong) NSIndexPath *cellIndexPath;

@property(nonatomic, strong) NETSConnectMicMemberModel *userModel;
@end

NS_ASSUME_NONNULL_END
