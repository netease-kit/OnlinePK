//
//  NTESMoreCell.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/27.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESCollectStatusCell : UICollectionViewCell

/// 标志icon
@property (nonatomic, strong) UIImageView *imageView;

/// 标题label
@property (nonatomic, strong) UILabel *textLabel;

@end

NS_ASSUME_NONNULL_END
