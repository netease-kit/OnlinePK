//
//  NETSAudienceNum.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSAudienceNum.h"
#import <NIMSDK/NIMChatroomMember.h>
#import "UIView+NTES.h"

@interface NETSAudienceNumCell : UICollectionViewCell

@property (nonatomic, strong)   UIImageView     *avatar;

@end

@implementation NETSAudienceNumCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.avatar];
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat len = MIN(self.contentView.height, self.contentView.width);
    self.avatar.frame = CGRectMake(0, 0, len, len);
    self.avatar.center = self.contentView.center;
}

/// 安装视图模型
- (void)installWithModel:(NIMChatroomMember *)model indexPath:(NSIndexPath *)indexPath
{
    NSURL *avatarUrl = [NSURL URLWithString:model.roomAvatar];
    [self.avatar sd_setImageWithURL:avatarUrl];
}

/// 创建cell
+ (NETSAudienceNumCell *)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath datas:(NSArray <NIMChatroomMember *> *)datas
{
    NETSAudienceNumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NETSAudienceNumCell description] forIndexPath:indexPath];
    if ([datas count] > indexPath.row) {
        id model = datas[indexPath.row];
        [cell installWithModel:model indexPath:indexPath];
    }
    return cell;
}

/// 设定cell尺寸
+ (CGSize)size
{
    return CGSizeMake(31, 28);
}

#pragma mark - lazy load

- (UIImageView *)avatar
{
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
        _avatar.layer.cornerRadius = 14;
        _avatar.layer.masksToBounds = YES;
    }
    return _avatar;
}

@end

///

@interface NETSAudienceNum () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong)   UICollectionView    *collectionView;
@property (nonatomic, strong)   UILabel             *numLab;
@property (nonatomic, strong)   NSArray <NIMChatroomMember *>             *datas;

@end

@implementation NETSAudienceNum

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self addSubview:self.numLab];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, 202, 28);
    [super setFrame:rect];
}

- (void)layoutSubviews
{
    self.collectionView.frame = CGRectMake(0, 0, 155, 28);
    self.numLab.frame = CGRectMake(self.width - 45, 0, 45, 28);
}

- (void)reloadWithDatas:(NSArray <NIMChatroomMember *> *)datas
{
    NSInteger diff = 5 - [datas count];
    NSMutableArray *arr = [NSMutableArray array];
    if (diff > 0) {
        for (NSInteger i = diff; i > 0; i--) {
            NIMChatroomMember *member = [[NIMChatroomMember alloc] init];
            [arr addObject:member];
        }
        [arr addObjectsFromArray:datas];
        _datas = [arr copy];
    } else {
        _datas = datas;
    }
    
    _numLab.text = [NSString stringWithFormat:@"%ld", (long)[datas count]];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_datas count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [NETSAudienceNumCell cellWithCollectionView:collectionView indexPath:indexPath datas:_datas];
}

#pragma mark - lazy load

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = [NETSAudienceNumCell size];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[NETSAudienceNumCell class] forCellWithReuseIdentifier:[NETSAudienceNumCell description]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}

- (UILabel *)numLab
{
    if (!_numLab) {
        _numLab = [[UILabel alloc] init];
        _numLab.textAlignment = NSTextAlignmentCenter;
        _numLab.textColor = [UIColor whiteColor];
        _numLab.font = [UIFont systemFontOfSize:12];
        _numLab.layer.cornerRadius = 14;
        _numLab.layer.masksToBounds = YES;
        _numLab.text = @"0";
        _numLab.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
    return _numLab;
}

@end
