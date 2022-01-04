//
//  NETSLiveListCell.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/9.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSLiveListCell.h"
#import "NELiveRoomListModel.h"
@interface NETSLiveListCell ()

/// 封面
@property (nonatomic, strong)   UIImageView *coverView;
/// 渐变阴影
@property (nonatomic, strong)   CAGradientLayer *shadowLayer;
/// pk标志
@property (nonatomic, strong)   UIImageView *pkView;
/// 房间名称
@property (nonatomic, strong)   UILabel     *roomName;
/// 主播名称
@property (nonatomic, strong)   UILabel     *anchorName;
/// 观众人数
@property (nonatomic, strong)   UILabel     *audienceNum;

@end

@implementation NETSLiveListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.pkView];
    [self.contentView addSubview:self.roomName];
    [self.contentView addSubview:self.anchorName];
    [self.contentView addSubview:self.audienceNum];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.coverView.layer insertSublayer:self.shadowLayer atIndex:0];
    [self.pkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.coverView).offset(8);
        make.size.mas_equalTo(CGSizeMake(86, 24));
    }];
    [self.roomName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverView).offset(8);
        make.bottom.equalTo(self.coverView).offset(-22);
        make.size.mas_equalTo(CGSizeMake(104, 20));
    }];
    [self.anchorName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.roomName);
        make.top.equalTo(self.roomName.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(104, 18));
    }];
    [self.audienceNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.coverView).offset(-8);
        make.centerY.equalTo(self.anchorName);
        make.size.mas_equalTo(CGSizeMake(60, 18));
    }];
}

- (void)installWithModel:(NELiveRoomListDetailModel *)model indexPath:(NSIndexPath *)indexPath
{
    self.roomName.text = model.live.roomTopic;
    self.anchorName.text = model.anchor.nickname;
    NSURL *coveUrl = [NSURL URLWithString:model.live.cover];
    [self.coverView sd_setImageWithURL:coveUrl];
    int32_t audienceNo = MAX(model.live.audienceCount, 0);
    self.audienceNum.text = kFormatNum(audienceNo);
    
    if (model.live.liveStatus == NEPkliveStatusPkLiving||
        model.live.liveStatus == NEPkliveStatusPunish||
        model.live.liveStatus == NEPkliveStatusConnectMic) {
        self.pkView.hidden = NO;
        if (model.live.liveStatus == NEPkliveStatusConnectMic ) {
            self.pkView.image = [UIImage imageNamed:NSLocalizedString(@"pklist_connecting_icon", nil)];
        }else {
            self.pkView.image = [UIImage imageNamed:NSLocalizedString(@"pking_ico", nil)];
        }
    }else {
        self.pkView.hidden = YES;
    }
}

+ (NETSLiveListCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                   indexPath:(NSIndexPath *)indexPath
                                       datas:(NSArray <NELiveRoomListDetailModel *> *)datas
{
    if ([datas count] <= indexPath.row) {
        return [NETSLiveListCell new];
    }
    
    NETSLiveListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NETSLiveListCell description]
                                                                       forIndexPath:indexPath];
    NELiveRoomListDetailModel *model = datas[indexPath.row];
    [cell installWithModel:model indexPath:indexPath];
    return cell;
}

+ (CGSize)size
{
    CGFloat length = (kScreenWidth - 8 * 3) / 2.0;
    return CGSizeMake((int)length, (int)length);//这里强行取整，解决xs上计算cell问题
}

#pragma mark - lazy load

- (UIImageView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIImageView alloc] init];
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.clipsToBounds  = YES;
        _coverView.layer.cornerRadius = 4;
        _coverView.layer.masksToBounds = YES;
    }
    return _coverView;
}

- (CAGradientLayer *)shadowLayer
{
    if (!_shadowLayer) {
        _shadowLayer = [CAGradientLayer layer];
        NSArray *colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithWhite:1 alpha:0] CGColor],
                           (id)[[UIColor colorWithWhite:0 alpha:0.4] CGColor],
                           nil
                           ];
        [_shadowLayer setColors:colors];
        [_shadowLayer setStartPoint:CGPointMake(0.0f, 0.4f)];
        [_shadowLayer setEndPoint:CGPointMake(0.0f, 1.0f)];
        CGFloat length = (kScreenWidth - 8 * 3) / 2.0;
        [_shadowLayer setFrame:CGRectMake(0, 0, length, length)];
    }
    return _shadowLayer;
}

- (UIImageView *)pkView
{
    if (!_pkView) {
        _pkView = [[UIImageView alloc] init];
    }
    return _pkView;
}

- (UILabel *)roomName
{
    if (!_roomName) {
        _roomName = [[UILabel alloc] init];
        _roomName.font = [UIFont systemFontOfSize:13];
        _roomName.textColor = [UIColor whiteColor];
        _roomName.text = NSLocalizedString(@"房间名称房间名称", nil);
    }
    return _roomName;
}

- (UILabel *)anchorName
{
    if (!_anchorName) {
        _anchorName = [[UILabel alloc] init];
        _anchorName.font = [UIFont systemFontOfSize:12];
        _anchorName.textColor = [UIColor whiteColor];
        _anchorName.text = NSLocalizedString(@"主播名称", nil);
    }
    return _anchorName;
}

- (UILabel *)audienceNum
{
    if (!_audienceNum) {
        _audienceNum = [[UILabel alloc] init];
        _audienceNum.font = [UIFont systemFontOfSize:12];
        _audienceNum.textColor = [UIColor whiteColor];
        _audienceNum.text = @"";
        _audienceNum.textAlignment = NSTextAlignmentRight;
    }
    return _audienceNum;
}

@end
