//
//  NETSMoreSettingActionSheet.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSMoreSettingActionSheet.h"
#import "TopmostView.h"
#import "NETSMoreSettingCell.h"
#import "NETSMoreSettingModel.h"
#import <NERtcSDK/NERtcSDK.h>
#import "NENavigator.h"
#import "NETSFilterSettingActionSheet.h"
#import "NETSLiveConfig.h"

@interface NETSMoreSettingActionSheet () <UICollectionViewDelegate, UICollectionViewDataSource>

/// 代理对象
@property (nonatomic, weak) id<NETSMoreSettingActionSheetDelegate> delegate;
/// 设置项视图
@property (nonatomic, strong)   UICollectionView    *collectionView;
/// 数据源
@property (nonatomic, strong)   NSArray             *items;

@end

@implementation NETSMoreSettingActionSheet

+ (void)showWithTarget:(id<NETSMoreSettingActionSheetDelegate>)target
                 items:(NSArray <NETSMoreSettingModel *> *)items
{
    CGRect frame = [UIScreen mainScreen].bounds;
    NETSMoreSettingActionSheet *sheet = [[NETSMoreSettingActionSheet alloc] initWithFrame:frame title:NSLocalizedString(@"更多", nil)];
    sheet.delegate = target;
    sheet.items = items;
    sheet.resetBtn.hidden = YES;
    
    [sheet.collectionView reloadData];
    
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    
    /// 暂存顶层视图交互设置
    sheet.topUserInteractionEnabled = topmostView.userInteractionEnabled;
    
    topmostView.userInteractionEnabled = YES;
    [topmostView addSubview:sheet];
}

- (void)setupSubViews
{
    [self.content addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topLine.mas_bottom);
        make.left.right.equalTo(self.content);
        make.height.mas_equalTo(108);
        make.bottom.equalTo(self.content).offset(kIsFullScreen ? -42 : -8);
    }];
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    if ([_items count] > 4) {
        CGFloat height = 108 * ceilf([items count] / 4.0);
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
    }
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [NETSMoreSettingCell cellWithCollectionView:collectionView indexPath:indexPath datas:self.items];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.items count] <= indexPath.row) {
        return;
    }
    
    NETSMoreSettingModel *model = self.items[indexPath.row];
    if ([model isKindOfClass:[NETSMoreSettingStatusModel class]]) {
        NETSMoreSettingStatusModel *newModel = (NETSMoreSettingStatusModel *)model;
        if ([model.display isEqualToString:@"耳返"]) {
            if ([NETSLiveConfig shared].outputRoute != kNERtcAudioOutputRoutingLoudspeaker) {
                newModel.disable = !newModel.disable;
            }
        }else {
            newModel.disable = !newModel.disable;
        }
        [self.collectionView reloadData];
    }
    
    [self _didActionWithModel:model];
}

- (void)_didActionWithModel:(NETSMoreSettingModel *)model
{
    
    [self dismiss];//点击后收起sheet
    NETSMoreSettingStatusModel *statusModel = nil;
    if ([model isKindOfClass:[NETSMoreSettingStatusModel class]]) {
        statusModel = (NETSMoreSettingStatusModel *)model;
    }

    switch (model.type) {
        case NETSMoreSettingCamera: {
            if (!statusModel) { return; }
            int res = [[NERtcEngine sharedEngine] enableLocalVideo:!statusModel.disable];
            YXAlogInfo(@"开关摄像头: res: %d", res);
            if (res == 0 && _delegate && [_delegate respondsToSelector:@selector(didSelectCameraEnable:)]) {
                [_delegate didSelectCameraEnable:!statusModel.disable];
            }
        }
            break;
        case NETSMoreSettingMicro: {
            if (!statusModel) { return; }
            int res = [[NERtcEngine sharedEngine] setRecordDeviceMute:statusModel.disable];
            YXAlogInfo(@"设置麦克风: %d", res);
        }
            break;
        case NETSMoreSettingEarback: {
            if (!statusModel) { return; }
            [self setUpEarBack:statusModel.disable];
        }
            break;
        case NETSMoreSettingReverse: {
            int res = [[NERtcEngine sharedEngine] switchCamera];
            YXAlogInfo(@"切换前后摄像头: %d", res);
        }
            break;
            
        case  NETSMoreSettingfilter: {
            [NETSFilterSettingActionSheet showWithMask:NO];
            YXAlogInfo(@"设置滤镜");
        }
            break;
        case NETSMoreSettingEndLive: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"结束直播", nil) message:NSLocalizedString(@"是否确认结束直播?", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCloseLive)]) {
                    [self.delegate didSelectCloseLive];
                }
            }];
            [alert addAction:cancel];
            [alert addAction:confirm];
            [[NENavigator shared].navigationController presentViewController:alert animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)setUpEarBack:(BOOL)disable {
    
    NERtcAudioOutputRouting route = [NETSLiveConfig shared].outputRoute;
    switch (route) {
        case kNERtcAudioOutputRoutingLoudspeaker:{
            [NETSToast showToast:NSLocalizedString(@"打开耳返功能前，请先插入耳机!", nil)];
        }
            break;
            
        default:{
            int res = [[NERtcEngine sharedEngine] enableEarback:!disable volume:80];
            YXAlogInfo(@"设置耳返: %d", res);
        }
            break;
    }
}

#pragma mark - lazy load

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = [NETSMoreSettingCell size];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 8;
        layout.sectionInset = UIEdgeInsetsMake(8, 5, 8, 5);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[NETSMoreSettingCell class] forCellWithReuseIdentifier:[NETSMoreSettingCell description]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.bounces = NO;
        _collectionView.scrollEnabled = NO;
    }
    return _collectionView;
}

@end
