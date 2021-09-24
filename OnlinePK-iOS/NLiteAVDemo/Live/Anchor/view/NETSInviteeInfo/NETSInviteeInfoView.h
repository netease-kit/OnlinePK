//
//  NETSInviteeInfoView.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/10.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NETSInviteeInfoView : UIView

/**
 加载被邀请者信息
 @param avatar      - 被邀请者头像
 @param nickname    - 被邀请者昵称
 */
- (void)reloadAvatar:(NSString *)avatar
            nickname:(NSString *)nickname;

@end

NS_ASSUME_NONNULL_END
