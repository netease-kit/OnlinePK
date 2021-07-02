//
//  NETSAudienceNum.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMChatroomMember;

@interface NETSAudienceNum : UIView

///
/// 刷新观众视图
/// @param datas    - 观众数据
///
- (void)reloadWithDatas:(NSArray <NIMChatroomMember *> *)datas;

@end

NS_ASSUME_NONNULL_END
