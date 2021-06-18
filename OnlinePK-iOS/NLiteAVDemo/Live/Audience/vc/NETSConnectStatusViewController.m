//
//  NETSConnectStatusViewController.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/21.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSConnectStatusViewController.h"
#import "NTESCollectStatusItem.h"
#import "NTESCollectStatusCell.h"
#import "NETSBeautySettingActionSheet.h"
#import "NETSFilterSettingActionSheet.h"




@interface NETSConnectStatusViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
// 设置项视图
@property (nonatomic, strong) UICollectionView *collectionView;
// 布局
@property (nonatomic, strong)  UICollectionViewFlowLayout *flowLayout;
// 数据源
@property (nonatomic, copy) NSArray<NTESCollectStatusItem *> *allItems;
//头像
@property(nonatomic, strong) UIImageView *headImageView;
//直播时长
@property(nonatomic, strong) UILabel *countdownLabel;

@property(nonatomic,strong) NSTimer *countDownTimer;
//时间间隔
//@property(nonatomic,assign) NSInteger countSecend;

@end

@implementation NETSConnectStatusViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)nets_initializeConfig {
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"连麦状态";
    
    NTESCollectStatusItem *cameraItem =  [NTESCollectStatusItem itemWithTitle:@"摄像头" onImage:[UIImage imageNamed:@"connectStatus_camera_open"] offImage:[UIImage imageNamed:@"connectStatus_camera_close"] tag:10003];
    cameraItem.on = NETSRtcConfig.sharedConfig.cameraOn;
    
    NTESCollectStatusItem *micItem = [NTESCollectStatusItem itemWithTitle:@"麦克风" onImage:[UIImage imageNamed:@"connectStatus_mic"] offImage:[UIImage imageNamed:@"connectStatus_mic_close"] tag:10004];
    micItem.on = NETSRtcConfig.sharedConfig.micOn;

    self.allItems = @[
        [NTESCollectStatusItem itemWithTitle:@"美颜" onImage:[UIImage imageNamed:@"connectStatus_beauty"] offImage:nil tag: 10000],
        [NTESCollectStatusItem itemWithTitle:@"滤镜" onImage:[UIImage imageNamed:@"connectStatus_filter"] offImage:nil tag:10001],
        [NTESCollectStatusItem itemWithTitle:@"挂断" onImage:[UIImage imageNamed:@"connectStatus_exitConnect"] offImage:nil tag:10002],
        cameraItem,
        micItem
    ];
    //启动定时器
    [self startTimer];
}

- (void)nets_addSubViews {
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.headImageView];
    [self.view addSubview:self.countdownLabel];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(48, 48));
        make.top.equalTo(self.view).offset(26);
        make.centerX.equalTo(self.view);
    }];
    
    [self.countdownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImageView.mas_bottom).offset(12);
        make.left.right.equalTo(self.view);
    }];

}

#pragma mark - priviteMethod
- (void)startTimer {
    NSString *localTime = [[NSUserDefaults standardUserDefaults]objectForKey:NTESConnectStartTimeKey];
    __block NSInteger second = @(NSDate.date.timeIntervalSince1970).integerValue - localTime.integerValue;
    
    __weak __typeof(self)weakSelf = self;
    _countDownTimer = [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",(second%3600)/60];//分
        NSString *str_second = [NSString stringWithFormat:@"%02ld",second%60];//秒
        NSString *content = [NSString stringWithFormat:@"连麦中，通话时长%@分%@秒",str_minute,str_second];
        weakSelf.countdownLabel.text = content;
        second ++;
       } repeats:YES];
    [_countDownTimer fire];
}

- (CGSize)preferredContentSize {
    
    return CGSizeMake(kScreenWidth, 240);
}

#pragma mark - lazyMethod
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NTESCollectStatusCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NTESCollectStatusCell" forIndexPath:indexPath];
    cell.imageView.image = self.allItems[indexPath.item].currentImage;
    cell.textLabel.text = self.allItems[indexPath.item].title;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NTESCollectStatusItem *item = self.allItems[indexPath.row];
    switch (item.tag) {
        case 10000: { // 美颜
            UIViewController *lastVC = self.presentingViewController;
            [lastVC dismissViewControllerAnimated:YES completion:^{
                [NETSBeautySettingActionSheet showWithMask:NO];
            }];
            break;
        }
        case 10001: { // 滤镜
            
            UIViewController *lastVC = self.presentingViewController;
            [lastVC dismissViewControllerAnimated:YES completion:^{
                [NETSFilterSettingActionSheet showWithMask:NO];
            }];
            break;
        }
        case 10002: { // 挂断
            item.on = !item.on;
            if (_delegate && [_delegate respondsToSelector:@selector(didResignSeats)]) {
                [_delegate didResignSeats];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 10003: { // 摄像头
            item.on = !item.on;
            [UIView performWithoutAnimation:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            
            if (_delegate && [_delegate respondsToSelector:@selector(didSetMicOn:)]) {
                [_delegate didSetVideoOn:item.on];
            }
            break;
        }
        case 10004: { // 麦克风
            item.on = !item.on;
            [UIView performWithoutAnimation:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            if (_delegate && [_delegate respondsToSelector:@selector(didSetMicOn:)]) {
                [_delegate didSetMicOn:item.on];
            }
            break;
        }

        default:
            break;
    }
}

#pragma mark - lazyMethod
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        CGFloat margin = (kScreenWidth - 60 - 5*48)/4;
        layout.minimumLineSpacing = margin;
        layout.minimumInteritemSpacing = margin;
        layout.itemSize = CGSizeMake(48, 84);
        layout.sectionInset = UIEdgeInsetsMake(136, 30, 0, 30);
        self.flowLayout = layout;
            
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.scrollEnabled = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:NTESCollectStatusCell.class forCellWithReuseIdentifier:@"NTESCollectStatusCell"];
    }
    return _collectionView;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc]init];
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:[NEAccount shared].userModel.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
        _headImageView.layer.cornerRadius = 24;
        _headImageView.layer.masksToBounds = YES;
    }
    return _headImageView;
}

- (UILabel *)countdownLabel {
    if (!_countdownLabel) {
        _countdownLabel = [[UILabel alloc]init];
        _countdownLabel.textColor = HEXCOLOR(0x333333);
        _countdownLabel.textAlignment = NSTextAlignmentCenter;
        _countdownLabel.font = TextFont_14;
        NSString *localTime = [[NSUserDefaults standardUserDefaults]objectForKey:NTESConnectStartTimeKey];
         NSInteger second = @(NSDate.date.timeIntervalSince1970).integerValue - localTime.integerValue;
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",(second%3600)/60];//分
        NSString *str_second = [NSString stringWithFormat:@"%02ld",second%60];//秒
        NSString *content = [NSString stringWithFormat:@"连麦中，通话时长%@分%@秒",str_minute,str_second];
        _countdownLabel.text = content;
    }
    return _countdownLabel;
}


- (void)dealloc {
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
    YXAlogDebug(@"连麦状态控制器销毁");
}
@end
