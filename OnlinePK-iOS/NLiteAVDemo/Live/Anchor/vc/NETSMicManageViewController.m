//
//  NETSMicManageViewController.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/26.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSMicManageViewController.h"
#import "NETSConnectManageCell.h"

#import "NETSLiveApi.h"
#import "NETSConnectMicModel.h"

@interface NETSMicManageViewController ()<UITableViewDelegate,UITableViewDataSource,NETSMicManageViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataArray;
@property(nonatomic, copy) NSString *roomId;
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
    [NETSLiveApi requestMicSeatsResultListWithRoomId:self.roomId type:NETSUserStatusAlreadyOnWheat successBlock:^(NSDictionary * _Nonnull response) {
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
    int isOpenVideo = isClose ? 0:1;
    [NETSLiveApi requestChangeSeatsStatusWithRoomId:self.roomId userId:accountId video:isOpenVideo audio:-1 successBlock:^(NSDictionary * _Nonnull response) {
        YXAlogInfo(@"主播操作连麦者视屏成功,response = %@",response);
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogInfo(@"主播操作连麦者视屏失败,response = %@",response);
    }];
}

// 关闭麦克风
- (void)didCloseMicrophone:(BOOL)isClose accountId:(nonnull NSString *)accountId {
    int isOpenAudio = isClose ? 0:1;
    [NETSLiveApi requestChangeSeatsStatusWithRoomId:self.roomId userId:accountId video:-1 audio:isOpenAudio successBlock:^(NSDictionary * _Nonnull response) {
        YXAlogInfo(@"主播操作连麦者麦克风成功,response = %@",response);

    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogInfo(@"主播操作连麦者麦克风失败,response = %@",response);
    }];
}

// 挂断连麦
- (void)didHangUpConnectAccountId:(NETSConnectMicMemberModel *)userModel{
    

    NSString *contentString = [NSString stringWithFormat:@"是否挂断与用户%@的连麦",userModel.nickName];
    [NETSAlertPrompt showAlert:UIAlertControllerStyleAlert title:contentString message:@"" actionArr:@[@"取消",@"挂断"] actionColors:@[HEXCOLOR(0x666666),HEXCOLOR(0x007AFF)] cancel:nil index:^(NSInteger index) {
        if (index == 1) {//取消
            
        }else {//挂断
            
            [NETSLiveApi requestSeatManagerWithRoomId:self.roomId userId:userModel.accountId index:1 action:NETSSeatsOperationAdminKickSeats successBlock:^(NSDictionary * _Nonnull response) {
                YXAlogDebug(@"主播挂断成功,response = %@",response);
            } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
                YXAlogError(@"主播挂断失败，error = %@",error.description);
            }];

            //硬删除数据
            for (NETSConnectMicMemberModel *userModel in self.dataArray) {
                if ([userModel.accountId isEqualToString:userModel.accountId]) {
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
    NETSConnectMicMemberModel *userModel = self.dataArray[indexPath.row];
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
@end
