//
//  NETSConnectManageCell.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/26.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSConnectManageCell.h"
#import "NESeatInfoFilterModel.h"

@interface NETSConnectManageCell ()
@property(nonatomic, strong) UILabel *rakeLabel;
@property(nonatomic, strong) UIImageView *headImageView;
@property(nonatomic, strong) UILabel *nickNameLabel;
@property(nonatomic, strong) UIButton *shutdownButton;
@property(nonatomic, strong) UIButton *micButton;
@property(nonatomic, strong) UIButton *videoButton;

@end

@implementation NETSConnectManageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)loadConnectManageCellWithTableView:(UITableView *)tableView {
    static NSString *cellId = @"NETSConnectManageCell";
    NETSConnectManageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
       if (!cell) {
           cell = [[NETSConnectManageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
       }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)nets_setupViews {
    [super nets_setupViews];
    [self.contentView addSubview:self.rakeLabel];
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.nickNameLabel];
    [self.contentView addSubview:self.shutdownButton];
    [self.contentView addSubview:self.videoButton];
    [self.contentView addSubview:self.micButton];

    [self.rakeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.rakeLabel.mas_right).offset(15);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
    
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageView.mas_right).offset(12);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.shutdownButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-20);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(53, 28));
    }];
    
    [self.micButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.shutdownButton.mas_left).offset(-17);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.micButton.mas_left).offset(-17);
        make.centerY.equalTo(self.contentView);
    }];
    

}


#pragma mark - setter

- (void)setUserModel:(NESeatInfoFilterModel *)userModel {
    _userModel = userModel;
    self.nickNameLabel.text = userModel.nickName;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:userModel.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
    //设置麦克风
    _micButton.selected = userModel.audioState ? NO : YES;
    _videoButton.selected = userModel.videoState ? NO : YES;
}


#pragma mark - priviteMethod
- (void)setCellIndexPath:(NSIndexPath *)cellIndexPath {
    _cellIndexPath = cellIndexPath;
    if (cellIndexPath.row == 0) {
        self.rakeLabel.textColor = HEXCOLOR(0xF24957);
    }else if (cellIndexPath.row == 1){
        self.rakeLabel.textColor = HEXCOLOR(0xFF791A);
    }else if (cellIndexPath.row == 2){
        self.rakeLabel.textColor = HEXCOLOR(0xFFAA00);
    }else {
        self.rakeLabel.textColor = HEXCOLOR(0xBFBFBF);
    }
    self.rakeLabel.text = [NSString stringWithFormat:@"%ld",cellIndexPath.row +1];
}

- (void)buttonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([sender isEqual:self.shutdownButton] && [self.delegate respondsToSelector:@selector(didHangUpConnectAccountId:)]) {
        [self.delegate didHangUpConnectAccountId:self.userModel];
    }else if ([sender isEqual:self.videoButton] && [self.delegate respondsToSelector:@selector(didCloseVideo:accountId:)]) {
        [self.delegate didCloseVideo:sender.selected accountId:self.userModel.accountId];
    }else if ([sender isEqual:self.micButton] && [self.delegate respondsToSelector:@selector(didCloseMicrophone:accountId:)]) {
        [self.delegate didCloseMicrophone:sender.selected accountId:self.userModel.accountId];
    }
}

#pragma mark - lazyMethod
- (UILabel *)rakeLabel {
    if (!_rakeLabel) {
        _rakeLabel = [[UILabel alloc]init];
        _rakeLabel.font = TextFont_14;
        _rakeLabel.textColor = HEXCOLOR(0xF24957);
        _rakeLabel.text = @"1";
    }
    return _rakeLabel;;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"avator"]];
        [_headImageView cornerAllCornersWithCornerRadius:36];
    }
    return _headImageView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc]init];
        _nickNameLabel.font = TextFont_14;
        _nickNameLabel.textColor = HEXCOLOR(0x0F0C0A);
        _nickNameLabel.text = @"";
    }
    return _nickNameLabel;;
}

- (UIButton *)shutdownButton {
    if (!_shutdownButton) {
        _shutdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shutdownButton setTitle:NSLocalizedString(@"挂断", nil) forState:UIControlStateNormal];
        [_shutdownButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _shutdownButton.titleLabel.font = TextFont_14;
        _shutdownButton.layer.cornerRadius = 4;
        [_shutdownButton setGradientBackgroundWithColors:@[HEXCOLOR(0xF359E2),HEXCOLOR(0xFF7272)] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
        [_shutdownButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shutdownButton;
}

- (UIButton *)videoButton {
    if (!_videoButton) {
        _videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoButton setImage:[UIImage imageNamed:@"anchor_video_open"] forState:UIControlStateNormal];
        [_videoButton setImage:[UIImage imageNamed:@"anchor_video_close"] forState:UIControlStateSelected];
        [_videoButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _videoButton;
}

- (UIButton *)micButton {
    if (!_micButton) {
        _micButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_micButton setImage:[UIImage imageNamed:@"anchor_mic_open"] forState:UIControlStateNormal];
        [_micButton setImage:[UIImage imageNamed:@"anchor_mic_close"] forState:UIControlStateSelected];
        [_micButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _micButton;
}
@end
