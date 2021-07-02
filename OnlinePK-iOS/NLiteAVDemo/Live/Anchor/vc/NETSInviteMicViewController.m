//
//  NETSInviteMicViewController.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/26.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSInviteMicViewController.h"

#import "NETSInviteMicCell.h"

#import "NETSLiveApi.h"
#import "NETSConnectMicModel.h"

@interface NETSInviteMicViewController ()<UITableViewDelegate,UITableViewDataSource,NETSInviteMicViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, copy) NSString *roomId;
@property(nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation NETSInviteMicViewController

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
    [NETSLiveApi requestMicSeatsResultListWithRoomId:self.roomId type:NETSUserStatusNormal successBlock:^(NSDictionary * _Nonnull response) {
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

- (void)refreshData:(NSNotification *)notification {
    NSInteger index = [notification.userInfo[@"index"] integerValue];
    if (index == 0) {
        [self nets_getNewData];
    }
}

#pragma mark - NETSMicRequestViewDelegate
- (void)didInviteAudienceConnectMic:(NSString *)audienceId {
    
    [NETSLiveApi requestSeatManagerWithRoomId:self.roomId userId:audienceId index:1 action:NETSSeatsOperationAdminInviteJoinSeats successBlock:^(NSDictionary * _Nonnull response) {
        YXAlogDebug(@"主播主动邀请上麦成功,response = %@",response);
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogError(@"主播主动邀请上麦失败，error = %@",error.description);
    }];
    
    //硬删除数据
    for (NETSConnectMicMemberModel *userModel in self.dataArray) {
        if ([userModel.accountId isEqualToString:audienceId]) {
            NSInteger index = [self.dataArray indexOfObject:userModel];
            [self.dataArray removeObjectAtIndex:index];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
            break;
        }
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
    NETSInviteMicCell *inviteCell = [NETSInviteMicCell loadInviteMicCellWithTableView:tableView];
    inviteCell.cellIndexPath = indexPath;
    inviteCell.delegate = self;
    inviteCell.userModel = userModel;
    return inviteCell;
}

#pragma mark - Get
- (UITableView *)tableView
{
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
