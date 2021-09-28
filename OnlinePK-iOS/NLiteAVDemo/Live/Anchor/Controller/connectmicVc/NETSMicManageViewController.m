//
//  NETSMicManageViewController.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/26.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSMicManageViewController.h"
#import "NETSConnectManageCell.h"

#import "NETSLiveApi.h"
#import "NEPkRoomApiService.h"
#import "NESeatInfoFilterModel.h"

@interface NETSMicManageViewController ()<UITableViewDelegate,UITableViewDataSource,NETSMicManageViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray <NESeatInfoFilterModel *>*dataArray;
@property(nonatomic, copy) NSString *roomId;
@property(nonatomic, strong) NEPkRoomApiService *apiService;

@end

@implementation NETSMicManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)nets_initializeConfig {
    self.roomId = (NSString *)self.params;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData:) name:NotificationName_Anchor_RefreshSeats object:nil];
}

- (void)nets_addSubViews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(240);
    }];
}

- (void)nets_getNewData {

    [self.apiService requestConnectMicListWithRoomId:self.roomId filterType:NESeatFilterTypeOnSeat successBlock:^(NSDictionary * _Nonnull response) {
        NSArray *list = response[@"/data/seatList"];
        if (list && [list isKindOfClass:[NSArray class]]) {
            self.dataArray = [[NSMutableArray alloc]initWithArray:list];
        } else {
            self.dataArray = [NSMutableArray array];
        }
        [self.tableView reloadData];
        YXAlogInfo(@"请求邀请上麦列表成功,response = %@",response);
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogError(@"请求邀请上麦列表失败，error = %@",error.description);
    }];
}

// 关闭视屏
- (void)didCloseVideo:(BOOL)isClose accountId:(nonnull NSString *)accountId {

    NESetSeatVideoStateParams *params = [[NESetSeatVideoStateParams alloc]init];
    params.userId = accountId;
    params.state = isClose ? NESeatVideoStateClosed : NESeatVideoStateOpen;
    [[NELiveRoom sharedInstance].seatService setSeatVideoState:params completion:^(NSError * _Nullable error) {
        if (error) {
            YXAlogError(@"anchor setSeatVideoState failed,error = %@",error);
        }else {
            YXAlogInfo(@"anchor setSeatVideoState success");
        }
    }];
}

// 关闭麦克风
- (void)didCloseMicrophone:(BOOL)isClose accountId:(nonnull NSString *)accountId {

    NESetSeatAudioStateParams *params = [[NESetSeatAudioStateParams alloc]init];
    params.userId = accountId;
    params.state = isClose ? NESeatAudioStateClosed:NESeatAudioStateOpen;
    [[NELiveRoom sharedInstance].seatService setSeatAudioState:params completion:^(NSError * _Nullable error) {
        if (error) {
            YXAlogError(@"anchor setSeatAudioState failed,error = %@",error);
        }else {
            YXAlogInfo(@"anchor setSeatAudioState success");
        }
    }];
}

-(void)didHangUpConnectAccountId:(NESeatInfoFilterModel *)hangUpModel {
    // 挂断连麦
    NSString *contentString = [NSString stringWithFormat:NSLocalizedString(@"是否挂断与用户%@的连麦", nil),hangUpModel.nickName];
    [NETSAlertPrompt showAlert:UIAlertControllerStyleAlert title:contentString message:@"" actionArr:@[NSLocalizedString(@"取消", nil),NSLocalizedString(@"挂断", nil)] actionColors:@[HEXCOLOR(0x666666),HEXCOLOR(0x007AFF)] cancel:nil index:^(NSInteger index) {
        if (index == 1) {//取消
            
        }else {//挂断
            NEKickSeatParams *params = [[NEKickSeatParams alloc]init];
            params.userId = hangUpModel.accountId;
            [[NELiveRoom sharedInstance].seatService kickSeat:params completion:^(NSError * _Nullable error) {
                if (error) {
                    YXAlogError(@"anchor kick failed,error = %@",error);
                }else {
                    YXAlogInfo(@"anchor kick suceess");
                }
            }];

            //硬删除数据
            for (NESeatInfoFilterModel *userModel in self.dataArray) {
                if ([userModel.accountId isEqualToString:hangUpModel.accountId]) {
                    NSInteger index = [self.dataArray indexOfObject:userModel];
                    [self.dataArray removeObjectAtIndex:index];
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    break;
                }
            }
        }
    } presentVc:self];
}

- (void)refreshData:(NSNotification *)notification {
    NSInteger index = [notification.userInfo[@"index"] integerValue];
    if (index == 2) {
        [self nets_getNewData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NESeatInfoFilterModel *userModel = self.dataArray[indexPath.row];
    NETSConnectManageCell *managerCell = [NETSConnectManageCell loadConnectManageCellWithTableView:tableView];
    managerCell.cellIndexPath = indexPath;
    managerCell.userModel = userModel;
    managerCell.delegate = self;
    return managerCell;
}

#pragma mark - Get
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(NEPkRoomApiService *)apiService {
    if (!_apiService) {
        _apiService = [[NEPkRoomApiService alloc]init];
    }
    return _apiService;
}
@end
