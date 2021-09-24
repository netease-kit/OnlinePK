//
//  NETSInvitingBar.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, NETSInviteBarType) {
    NETSInviteBarTypeInvite = 0,
    NETSInviteBarTypeConnectMic,
};
///
/// 正在邀请 提示框
///

@protocol NETSInvitingBarDelegate <NSObject>

/// 取消邀请（点击查看）
- (void)clickCancelInviting:(NETSInviteBarType)barType;
//忽略事件
- (void)didClickDiscardButton:(NETSInviteBarType)barType;
@end

@interface NETSInvitingBar : UIView

+ (NETSInvitingBar *)showInvitingWithTarget:(id)target title:(NSString *)title;


/// 初始化方法
/// @param target target
/// @param title 标题
/// @param type 类型
+ (NETSInvitingBar *)showInvitingWithTarget:(id)target title:(NSString *)title barType:(NETSInviteBarType)type;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
