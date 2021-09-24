//
//  NEMenuViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEMenuViewController.h"
#import "NENavCustomView.h"
#import "NEMenuCell.h"

#import "NEUser.h"
#import "AppKey.h"

#import "NENavigator.h"
#import "NEAccount.h"
#import "NEFeedbackVC.h"
#import "NEMenuHeader.h"
#import "NETSToast.h"
#import "NEPkLiveAttachment.h"


@interface NEMenuViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)UIImageView *bgImageView;

@property (nonatomic, strong)   NSArray *datas;

@end

static NSString *cellID = @"menuCellID";
@implementation NEMenuViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDatas];
    [self setupUI];
    [self.tableView reloadData];
}

#pragma mark - private

- (void)setupDatas
{

    NEMenuCellModel *live = [[NEMenuCellModel alloc]initWithTitle:NSLocalizedString(@"PK直播", nil) subtitle:NSLocalizedString(@"从单人直播到主播间PK，观众连麦多种玩法", nil) icon:@"home_pkLive_icon"  block:^{
        [[NENavigator shared] showLiveListVCWithRoomType:NERoomTypePkLive];
    }];
    NEMenuCellModel *connectMic = [[NEMenuCellModel alloc]initWithTitle:NSLocalizedString(@"多人连麦直播", nil)  subtitle:NSLocalizedString(@"支持1V4主播和观众的视频互动", nil) icon:@"home_connectMic_icon"  block:^{
        [[NENavigator shared] showLiveListVCWithRoomType:NERoomTypeConnectMicLive];
    }];
    NSArray *sectionTwo = @[live,connectMic];
    _datas = @[sectionTwo];

}

- (void)setupUI {
    [self.view addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    NENavCustomView *customView = [[NENavCustomView alloc] init];
    [self.view addSubview:customView];
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [customView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(statusHeight + 80);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(customView.mas_bottom);
        make.right.mas_equalTo(-20);
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_datas count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_datas count] > section) {
        NSArray *arr = _datas[section];
        return [arr count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NEMenuCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_datas count] > indexPath.section) {
        NSArray *array = _datas[indexPath.section];
        if ([array count] > indexPath.row) {
            NEMenuCellModel *data = array[indexPath.row];
            return [NEMenuCell cellWithTableView:tableView indexPath:indexPath data:data];
        }
    }
    return [NEMenuCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![NEAccount shared].hasLogin) {
        [[NENavigator shared] loginWithOptions:nil];
        return;
    }
    if ([_datas count] > indexPath.section) {
        NSArray *array = _datas[indexPath.section];
        if ([array count] > indexPath.row) {
            NEMenuCellModel *data = array[indexPath.row];
            if (!data.block) { return; }
                [NETSToast showLoading];
                [self setupIMWithLoginCompletion:^(NSError * _Nullable error) {
                    [NETSToast hideLoading];
                    if (error) {
                        [NETSToast showToast:NSLocalizedString(@"IM登录失败", nil)];
                        YXAlogInfo(@"IM登录失败, error: %@", error);
                    } else {
                        data.block();
                    }
                }];
                return;
        }
    }
}

#pragma mark - private Method
/// 初始化IM引擎
- (void)setupIMWithLoginCompletion:(void(^)(NSError * _Nullable))loginCompletion {
    
    NIMSDKOption *option = [NIMSDKOption optionWithAppKey:kAppKey];
    [[NIMSDK sharedSDK] registerWithOption:option];
    [NIMCustomObject registerCustomDecoder:[[NEPKLiveAttachmentDecoder alloc] init]];

    if (![NIMSDK sharedSDK].loginManager.isLogined) {
        NEUser *user = [NEAccount shared].userModel;
        [[[NIMSDK sharedSDK] loginManager] login:user.imAccid token:user.imToken completion:^(NSError * _Nullable error) {
            if (loginCompletion) {
                loginCompletion(error);
            }
        }];
        
    } else {
        if (loginCompletion) {
            loginCompletion(nil);
        }
    }
}

#pragma mark - property
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 104;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[NEMenuCell class] forCellReuseIdentifier:cellID];
    }
    return _tableView;
}
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_bg"]];
    }
    return _bgImageView;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
