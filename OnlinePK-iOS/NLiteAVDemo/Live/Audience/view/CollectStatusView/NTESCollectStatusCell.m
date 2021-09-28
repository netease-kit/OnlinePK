//
//  NTESMoreCell.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/27.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NTESCollectStatusCell.h"

@interface NTESCollectStatusCell ()

@property (nonatomic, strong) CALayer *selectionLayer;

@end

@implementation NTESCollectStatusCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.imageView];
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.font = [UIFont systemFontOfSize:12];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.textLabel];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.selectionLayer.frame = self.contentView.bounds;
    self.imageView.frame = CGRectMake(0, 0, 48, 48);
    self.textLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + 6, self.contentView.bounds.size.width, 18);
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
}

@end
