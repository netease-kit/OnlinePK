//
//  NETSLiveBaseErrorView.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/18.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 直播结束视图
 */

@interface NETSLiveBaseErrorView : UIImageView

@property (nonatomic, strong)   UIImageView *avatarView;
@property (nonatomic, strong)   UILabel     *nameLab;
@property (nonatomic, strong)   UIView      *topDivide;
@property (nonatomic, strong)   UILabel     *statusLab;
@property (nonatomic, strong)   UIView      *botDivide;

/**
 安装视图
 @param avatar      - 头像链接
 @param nickname    - 昵称
 */
- (void)installWithAvatar:(NSString *)avatar
                 nickname:(NSString *)nickname;

- (void)setupSubviews;

@end

NS_ASSUME_NONNULL_END
