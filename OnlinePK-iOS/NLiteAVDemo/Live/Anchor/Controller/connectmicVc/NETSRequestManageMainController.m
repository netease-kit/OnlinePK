//
//  NETSRequestManageController.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/22.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSRequestManageMainController.h"
#import "NTESSegmentCtrl.h"
#import "NETSInviteMicViewController.h"

@interface NETSRequestManageMainController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *segmentScrollView;

@property (nonatomic, strong) NSArray *childVcArray;

@property(nonatomic, strong) NTESSegmentCtrl *segmentCtrl;
//title数组
@property(nonatomic, strong) NSArray *titleArray;

@property(nonatomic, strong) NSString *roomId;
@end

@implementation NETSRequestManageMainController


- (instancetype)initWithRoomId:(NSString *)roomId {
    if (self = [super init]) {
        _roomId = roomId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)nets_initializeConfig {
    self.view.backgroundColor = UIColor.whiteColor;
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationName_Audience_ApplyConnectMic object:nil userInfo:@{@"isDisPlay":@NO}];
}

- (void)nets_addSubViews {
    
    [self.navigationController.navigationBar addSubview:self.segmentCtrl];
    [self.view addSubview:self.segmentScrollView];
    [self addChildSubViewControllers];
}

- (CGSize)preferredContentSize {
    return CGSizeMake(kScreenWidth, 240);
}

#pragma mark - Private Method
//添加子控制器
- (void)addChildSubViewControllers {
    NSString *childVc = self.childVcArray.firstObject;
    Class cls = NSClassFromString(childVc);
    NETSBaseViewController *baseVc = [[cls alloc]init];
    baseVc.params = self.roomId;
    [self addChildViewController:baseVc];
    baseVc.view.frame = CGRectMake(0, 0, kScreenWidth, self.segmentScrollView.bounds.size.height);
    [self.segmentScrollView addSubview:baseVc.view];
    [self switchSubViewController:1];

}

//切换子控制器
- (void)switchSubViewController:(NSInteger)index {

    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationName_Anchor_RefreshSeats object:nil userInfo:@{@"index":@(index)}];
    
    
    [self.segmentScrollView setContentOffset:CGPointMake(index*kScreenWidth, 0) animated:YES ];
    NSString *childVc = self.childVcArray[index];
    Class cls = NSClassFromString(childVc);
    NETSBaseViewController *baseVc = [[cls alloc]init];
    for (NSInteger i = 0; i < self.childViewControllers.count; i ++) {
        NETSBaseViewController *vc = self.childViewControllers[i];
        if ([baseVc isMemberOfClass:[vc class]]) {
            return ;
        }
    }
    baseVc.params = self.roomId;
    [self addChildViewController:baseVc];
    baseVc.view.frame = CGRectMake(kScreenWidth*index, 0, kScreenWidth, self.segmentScrollView.bounds.size.height);
    [self.segmentScrollView addSubview:baseVc.view];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.segmentCtrl.sIndex = index;
    [self switchSubViewController:index];
}

#pragma mark - lazyMethod

- (UIScrollView *)segmentScrollView {
    if (!_segmentScrollView) {
        _segmentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-self.currentNavHeight)];
        _segmentScrollView.contentSize = CGSizeMake(kScreenWidth*self.childVcArray.count, kScreenHeight -self.currentNavHeight);
        _segmentScrollView.delegate = self;
        _segmentScrollView.showsHorizontalScrollIndicator = NO;
        _segmentScrollView.pagingEnabled = YES;
        _segmentScrollView.scrollEnabled = YES;
        _segmentScrollView.directionalLockEnabled = YES;
        _segmentScrollView.bounces = YES;
    }
    return _segmentScrollView;
}

- (NSArray *)childVcArray {
    if (!_childVcArray) {
        _childVcArray = @[@"NETSInviteMicViewController",@"NETSMicRequestViewController",@"NETSMicManageViewController"];
    }
    return _childVcArray;
}

- (NTESSegmentCtrl *)segmentCtrl {
    if (!_segmentCtrl) {
        @weakify(self)
        _segmentCtrl = [[NTESSegmentCtrl alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 48)];
        _segmentCtrl.bottomLineType = BottomLineTypeShortestFont;
        _segmentCtrl.fontSize = 15;
        _segmentCtrl.selectTextFont = Font_Size(@"PingFangSC-Medium", 15);
        _segmentCtrl.normalLabelColor = HEXCOLOR(0x333333);
        _segmentCtrl.selectLabelColor = HEXCOLOR(0x337EFF);
        _segmentCtrl.lineViewColor = HEXCOLOR(0x337EFF);
        _segmentCtrl.lineViewHeight = 3;
        _segmentCtrl.lineViewWidth = 20;
        _segmentCtrl.isShowLineBottomRoundedCorners = YES;
        _segmentCtrl.lineBottomDistanceInterval = 2;
        _segmentCtrl.titleArray = self.titleArray;
        _segmentCtrl.sIndex = 1;
        _segmentCtrl.clickBlock = ^(NSInteger selectIndex) {
            @strongify(self)
            [self switchSubViewController:selectIndex];
        };
    }
    return _segmentCtrl;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[
            NSLocalizedString(@"邀请上麦", nil),
            NSLocalizedString(@"连麦申请", nil),
            NSLocalizedString(@"连麦管理", nil)
        ];    }
    return _titleArray;
}
@end
