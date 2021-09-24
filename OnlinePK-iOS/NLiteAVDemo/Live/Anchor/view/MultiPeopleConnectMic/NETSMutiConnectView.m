//
//  NETSMutiConnectView.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSMutiConnectView.h"
#import "NETSMultiConnectCollectionCell.h"
#import "NETSLiveApi.h"

@interface NETSMutiConnectView ()<UICollectionViewDelegate,UICollectionViewDataSource,NETSMultiConnectCollectionDelegate>
@property(nonatomic, strong) UICollectionView *mutiConnectCollectionView;
@property(nonatomic, strong) NSArray <NESeatInfo *>*dataArray;
@end

@implementation NETSMutiConnectView
static int buttonWH = 20;


- (instancetype)initWithDataSource:(NSArray *)dataArray frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _dataArray = dataArray;
        [self loadSubviews];
    }
    return self;
}


//加载子控件
- (void)loadSubviews {
    [self addSubview:self.mutiConnectCollectionView];
    [self.mutiConnectCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

-(void)reloadDataSource:(NSArray<NESeatInfo *> *)updateDataArray {
    self.dataArray = updateDataArray;
    [self.mutiConnectCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource,Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NESeatInfo *memberModel = self.dataArray[indexPath.row];
    NETSMultiConnectCollectionCell *multiVideoCell = [NETSMultiConnectCollectionCell settingCellWithCollectionView:collectionView indexPath:indexPath];
    multiVideoCell.roleType = self.roleType;
    multiVideoCell.memberModel = memberModel;
    multiVideoCell.delegate = self;
    return multiVideoCell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.width, (self.height - 30)/4);

}


#pragma mark - lazyMethod

- (UICollectionView *)mutiConnectCollectionView {
    if (!_mutiConnectCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 15;
        _mutiConnectCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, buttonWH, self.width, self.height) collectionViewLayout:flowLayout];
        _mutiConnectCollectionView.backgroundColor = [UIColor clearColor];
        _mutiConnectCollectionView.delegate = self;
        _mutiConnectCollectionView.dataSource = self;
        _mutiConnectCollectionView.showsVerticalScrollIndicator = NO;
        _mutiConnectCollectionView.scrollEnabled = NO;
        _mutiConnectCollectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [NETSMultiConnectCollectionCell registerForCollectionView:_mutiConnectCollectionView];
    }
    return _mutiConnectCollectionView;
}

#pragma mark - NETSMultiConnectCollectionDelegate

-(void)didCloseConnectRoom:(NSString *)userId {
    if ([self.delegate respondsToSelector:@selector(disconnectRoomWithUserId:)]) {
        [self.delegate disconnectRoomWithUserId:userId];
    }
}

@end
