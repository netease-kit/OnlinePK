//
//  NEFeedbackListCell.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/22.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEFeedbackListCell : UITableViewCell
@property(strong,nonatomic)UILabel *titleLabel;
@property(strong,nonatomic)UIButton *arrowButton;

@end

NS_ASSUME_NONNULL_END
