//
//  NETSMultiConnectCollectionCell.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSMultiConnectCollectionCell.h"


@interface NETSMultiConnectCollectionCell ()
@property(nonatomic, strong)UIButton *closeButton;
//静音icon
@property(nonatomic, strong)UIImageView *muteMicImageView;
//昵称
@property(nonatomic, strong)UILabel *nickNameLabel;

@property(nonatomic, strong) UIView *videoView;
//头像
@property(nonatomic, strong) UIImageView *avatarImageView;
@end

@implementation NETSMultiConnectCollectionCell

+(void)registerForCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:NSStringFromClass([self class])];
}

+(instancetype)settingCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath{
    NETSMultiConnectCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}


- (void)initialize {

    [self.contentView addSubview:self.videoView];
    [self.contentView addSubview:self.closeButton];
    [self.contentView addSubview:self.muteMicImageView];
    [self.contentView addSubview:self.nickNameLabel];
    [self.videoView addSubview:self.avatarImageView];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.muteMicImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self.contentView).offset(-5);
        make.size.mas_equalTo(CGSizeMake(12, 15));
    }];
    
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView).offset(-5);
        make.right.equalTo(self.muteMicImageView.mas_left).offset(11);
    }];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.videoView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
}


- (void)setMemberModel:(NESeatInfo *)memberModel {
    _memberModel = memberModel;
    NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
    canvas.renderMode = kNERtcVideoRenderScaleCropFill;
    canvas.container = self.videoView;
    if ([memberModel.userInfo.accountId isEqualToString:[NEAccount shared].userModel.accountId]) {
        //自己
        int res = [[NERtcEngine sharedEngine] setupLocalVideoCanvas:canvas];
        if (res != 0) {
            YXAlogError(@"setupLocalVideoCanvas failed,errorCode = %d",res);
        }
        self.closeButton.hidden = NO;
    }else {
        self.closeButton.hidden = self.roleType == NETSUserModeAnchor ? NO : YES;
        
        int res = [[NERtcEngine sharedEngine] setupRemoteVideoCanvas:canvas forUserID:memberModel.avRoomUid];
        if (res != 0) {
            YXAlogError(@"setupRemoteVideoCanvas failed,errorCode = %d",res);
        }
    }
    self.nickNameLabel.text = memberModel.userInfo.userName;
    self.muteMicImageView.image = memberModel.audioState ? [UIImage imageNamed:@"mic_normal_icon"] :[UIImage imageNamed:@"muteMic_icon"];
    [self.avatarImageView sd_setImageWithURL:memberModel.userInfo.avatarURL];
    self.avatarImageView.hidden = memberModel.videoState == 1 ?YES:NO;
}


-(void)layoutSubviews {
    [super layoutSubviews];
    [self.avatarImageView cornerAllCornersWithCornerRadius:20];
}

#pragma mark - privateMethod

- (void)closeRoomAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didCloseConnectRoom:)]) {
        [self.delegate didCloseConnectRoom:self.memberModel.userInfo.accountId];
    }
}

#pragma mark - lazyMethod

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"close_micPosition"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeRoomAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}


- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc]init];
        _nickNameLabel.textColor = UIColor.whiteColor;
        _nickNameLabel.font = Font_Default(10);
    }
    return _nickNameLabel;
}

- (UIImageView *)muteMicImageView {
    if (!_muteMicImageView) {
        _muteMicImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mic_normal_icon"]];
    }
    return _muteMicImageView;
}

-(UIView *)videoView {
    if (!_videoView) {
        _videoView = [[UIView alloc]initWithFrame:self.contentView.bounds];
        _videoView.backgroundColor = UIColor.blackColor;
    }
    return _videoView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc]init];
        _avatarImageView.hidden = YES;
    }
    return _avatarImageView;
}
@end
