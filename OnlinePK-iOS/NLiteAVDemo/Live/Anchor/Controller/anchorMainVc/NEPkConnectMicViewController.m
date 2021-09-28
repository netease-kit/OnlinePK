//
//  NEPkConnectMicViewController.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/12.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEPkConnectMicViewController.h"
#import "NETSRequestManageMainController.h"
#import "NTESActionSheetNavigationController.h"

#import "TopmostView.h"
#import "NETSInvitingBar.h"
#import "NETSMutiConnectView.h"
#import "NETSAudienceNum.h"
#import "NETSAnchorTopInfoView.h"

#import "AppKey.h"
#import "Reachability.h"
#import "NETSLiveApi.h"
#import "NECreateRoomResponseModel.h"
#import "NEPkChatroomMsgHandle.h"
#import "NEPkLiveAttachment.h"
#import "NENavigator.h"
#import "NETSPushStreamService.h"
#import "NSString+NTES.h"
#import "NETSChatroomService.h"

@interface NEPkConnectMicViewController ()<NESeatServiceDelegate,NEPkChatroomMsgHandleDelegate,NETSMutiConnectViewDelegate>
//断网检测
@property(nonatomic, assign) BOOL isBrokenNetwork;
/// 网络监测类
@property(nonatomic, strong) Reachability *reachability;
//IM 聊天室消息处理类
@property(nonatomic, strong) NEPkChatroomMsgHandle *pkChatRoomMsgHandle;
//请求上麦状态条
@property (nonatomic, strong)   NETSInvitingBar         *requestConnectMicBar;
//连麦缩略视图
@property(nonatomic, strong) NETSMutiConnectView *connectMicView;
//已上麦人员
@property(nonatomic, strong) NSMutableArray <NESeatInfo *>*connectMicArray;
//已上麦人员uid
@property(nonatomic, strong) NSArray*connectMicUidArray;
/// 直播中 观众数量视图
@property (nonatomic, strong)   NETSAudienceNum         *audienceInfo;
/// 主播信息视图
@property (nonatomic, strong)   NETSAnchorTopInfoView   *anchorInfo;
@end

@implementation NEPkConnectMicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeConfig];
    [self bindAction];
}

- (void)initializeConfig {
    // 监测网络
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [self.reachability startNotifier];
    [[NIMSDK sharedSDK].chatManager addDelegate:self.pkChatRoomMsgHandle];
    [[NIMSDK sharedSDK].chatroomManager addDelegate:self.pkChatRoomMsgHandle];
    [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self.pkChatRoomMsgHandle];

    //添加连麦缩略视图
    [self.view addSubview:self.connectMicView];

}

- (void)connectMicManagerClick {
      [self.requestConnectMicBar dismiss];
}
#pragma mark - privateMethod
- (void)bindAction {
    @weakify(self);
    [RACObserve(self, createRoomModel) subscribeNext:^(NECreateRoomResponseModel*  _Nullable room) {
        @strongify(self);
        if (!room) { return; }
        self.pkChatRoomMsgHandle.chatroomId = room.live.chatRoomId;
        [NELiveRoom sharedInstance].options.accessToken = [NEAccount shared].accessToken;
        NERoomDetail *roomdetail = [[NERoomDetail alloc]init];
        roomdetail.roomId = room.live.roomId;
        [NELiveRoom sharedInstance].roomService.currentRoom = roomdetail;
        [[NELiveRoom sharedInstance].seatService addDelegate:self];
    }];    
}
- (void)reachabilityChanged:(NSNotification *)note {
    
    Reachability *currentReach = [note object];
    NSCParameterAssert([currentReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [currentReach currentReachabilityStatus];
    if (netStatus == NotReachable) {//断网
        YXAlogInfo(@"主播检测到断网");
        self.isBrokenNetwork = YES;
    }else {//有网络
//        if (self.isBrokenNetwork) {
//            [NETSLiveApi requestMicSeatsResultListWithRoomId:self.liveRoomModel.liveCid type:NETSUserStatusAlreadyOnWheat successBlock:^(NSDictionary * _Nonnull response) {
//                NSArray *memberList = response[@"/data/seatList"];
//                NSMutableArray *currentConnecterArray = [NSMutableArray arrayWithArray:self.connectMicArray];
//                for (NETSConnectMicMemberModel *memberModel in memberList) {
//                    if (![self.connectMicUidArray containsObject:memberModel.accountId]) {
//                        [currentConnecterArray addObject:memberModel];
//                    }
//                }
//                //刷新麦位人数
//                if (![self.view.subviews containsObject:self.connectMicView]) {
//                    [self.view addSubview:self.connectMicView];
//                }
//                [self.connectMicView reloadDataSource:currentConnecterArray];
//                YXAlogInfo(@"请求连麦者列表成功,response = %@",response);
//            } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
//                YXAlogError(@"请求连麦者列表失败，error = %@",error.description);
//            }];
//        }
    }
}


- (void)updateStreamUserTrans:(uint64_t)uid {

    NERtcLiveStreamTaskInfo *taskInfo = [[NERtcLiveStreamTaskInfo alloc] init];
    taskInfo.taskID = [NSString md5ForLower32Bate:self.createRoomModel.live.liveConfig.pushUrl];
    taskInfo.streamURL = self.createRoomModel.live.liveConfig.pushUrl;
    taskInfo.lsMode = kNERtcLsModeVideo;
    CGFloat width = 720;
    CGFloat height = 1280;


    //设置整体布局
    NERtcLiveStreamLayout *streamLayout = [[NERtcLiveStreamLayout alloc] init];
    streamLayout.width = width;
    streamLayout.height = height;
    taskInfo.layout = streamLayout;

    NSMutableArray *usersArray = [NSMutableArray array];
    //设置主播布局
    if (self.createRoomModel.anchor.roomUid) {
        NERtcLiveStreamUserTranscoding *userTranscoding = [[NERtcLiveStreamUserTranscoding alloc] init];
        userTranscoding.uid = self.createRoomModel.anchor.roomUid;
        userTranscoding.audioPush = YES;
        userTranscoding.videoPush = YES;
        userTranscoding.width = width;
        userTranscoding.height = height;
        userTranscoding.adaption = kNERtcLsModeVideoScaleCropFill;
        [usersArray addObject:userTranscoding];
    }

    //设置连麦者布局
    for (int i = 0; i<self.connectMicArray.count; i ++) {
        NESeatInfo *memberModel = self.connectMicArray[i];
        NERtcLiveStreamUserTranscoding *userTranscoding = [[NERtcLiveStreamUserTranscoding alloc] init];
        userTranscoding.uid = memberModel.avRoomUid;
        userTranscoding.audioPush = YES;
        userTranscoding.videoPush = YES;
        userTranscoding.x = 575;
        userTranscoding.y = 200 + (170+12)*i;
        userTranscoding.width = 132;
        userTranscoding.height = 170;
        userTranscoding.adaption = kNERtcLsModeVideoScaleCropFill;
        [usersArray addObject:userTranscoding];
    }
    taskInfo.layout.users = usersArray;
    //更新推流任务
    [NETSPushStreamService updateLiveStreamTask:taskInfo successBlock:^{
       YXAlogInfo(@"updateLiveStreamTask success")
    } failedBlock:^(NSError * _Nonnull error) {
       YXAlogError(@"updateLiveStreamTask failed,error = %@",error);
    }];
}


- (void)closeLiveRoom {
    [super closeLiveRoom];
    if (_requestConnectMicBar) {
        [self.requestConnectMicBar dismiss];
    }
}
#pragma mark - NETSInvitingBarDelegate 取消连麦代理

- (void)clickCancelInviting:(NETSInviteBarType)barType {
    
    if (barType == NETSInviteBarTypeConnectMic) {
        if (_requestConnectMicBar) {
            [self.requestConnectMicBar dismiss];
        }
        NETSRequestManageMainController *statusVc = [[NETSRequestManageMainController alloc] initWithRoomId:self.createRoomModel.live.roomId];
        NTESActionSheetNavigationController *nav = [[NTESActionSheetNavigationController alloc] initWithRootViewController:statusVc];
        nav.dismissOnTouchOutside = YES;
        [[NENavigator shared].navigationController presentViewController:nav animated:YES completion:nil];
    }
}


#pragma mark - NEPkChatroomMsgHandleDelegate
- (void)onRecvRoomTextMsg:(NSArray<NIMMessage *> *)messages {
    [self chatViewAddMessge:messages];
}

- (void)receivePkRewardAttachment:(NEPkRewardAttachment *)rewardData {
    NIMCustomObject *object = [[NIMCustomObject alloc] init];
    object.attachment = rewardData;
    NIMMessage *msg = [[NIMMessage alloc] init];
    msg.messageObject = object;
    [self.chatView addMessages:@[msg]];
    
    
    // 更新用户信息栏(云币值)
    int32_t coins = rewardData.anchorReward.rewardTotal;
    [self.anchorInfo updateCoins:coins];
}

-(void)didChatroomMember:(NIMChatroomNotificationMember *)member enter:(BOOL)enter sessionId:(NSString *)sessionId {

    // 主播的聊天室id
    NSString *chatRoomCreatorId = self.createRoomModel.anchor.imAccid;
    if ([chatRoomCreatorId isEqualToString:member.userId]) {
        YXAlogInfo(@"聊天室创建者: \"%@\" %@房间", member.userId, (enter ? @"加入":@"离开"));
    } else {
        // 提示非聊天室创建者 加入/离开 消息
        NIMMessage *message = [[NIMMessage alloc] init];
        message.text = enter ? [NSString stringWithFormat:NSLocalizedString(@"\"%@\" 加入房间", nil), member.nick] : [NSString stringWithFormat:NSLocalizedString(@"\"%@\" 离开房间", nil), member.nick];
        message.remoteExt = @{@"type":@(1)};
        [self.chatView addMessages:@[message]];
    }
    
    // 聊天室信息成员变更
    NSString *roomId = self.createRoomModel.live.chatRoomId;
    [NETSChatroomService fetchMembersRoomId:roomId limit:10 successBlock:^(NSArray<NIMChatroomMember *> * _Nullable members) {
        YXAlogInfo(@"members: %@", members);
        [self.audienceInfo reloadWithDatas:members];
    } failedBlock:^(NSError * _Nonnull error) {
        YXAlogInfo(@"主播端获取IM聊天室成员失败, error: %@", error);
    }];
}

#pragma mark - NESeatServiceDelegate
- (void)onSeatApplyAccepted:(NESeatApplyAcceptEvent * _Nonnull)event {
    
}

- (void)onSeatApplyRejected:(NESeatApplyRejectEvent * _Nonnull)event {
    
}

- (void)onSeatApplyRequest:(NESeatApplyRequestEvent * _Nonnull)event {
    // 消除顶层视图
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    for (UIView *subview in topmostView.subviews) {
        [subview removeFromSuperview];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NotificationName_Audience_ApplyConnectMic object:nil userInfo:@{@"isDisPlay":@YES}];
    [self.requestConnectMicBar dismiss];
    self.requestConnectMicBar = [NETSInvitingBar showInvitingWithTarget:self title:NSLocalizedString(@"收到新的连麦申请", nil) barType:NETSInviteBarTypeConnectMic];
}

- (void)onSeatApplyRequestCanceled:(NESeatApplyRequestCancelEvent * _Nonnull)event {
    
}

- (void)onSeatCustomInfoChanged:(NESeatCustomInfoChangeEvent * _Nonnull)event {
    
}

- (void)onSeatEntered:(NESeatEnterEvent * _Nonnull)event {

    for (NESeatInfo *seatInfo in self.connectMicArray) {//防重
        if ([seatInfo.userInfo.accountId  isEqualToString:event.seatInfo.userInfo.accountId]) {
            return;
        }
    }
    event.seatInfo.avRoomUid = event.avRoomUser.avRoomUid.longLongValue;
    [self.connectMicArray addObject:event.seatInfo];
    NIMMessage *message = [[NIMMessage alloc] init];
    message.text = [NSString stringWithFormat:NSLocalizedString(@"\"%@\" 成功上麦", nil), event.seatInfo.userInfo.userName];

    message.remoteExt = @{@"type":@(1)};
    [self.chatView addMessages:@[message]];
    self.connectMicView.hidden = NO;
    [self.connectMicView reloadDataSource:self.connectMicArray];
    [self updateStreamUserTrans:event.seatInfo.avRoomUid];

}

- (void)onSeatLeft:(NESeatLeaveEvent * _Nonnull)event {
    
    for (NESeatInfo *seatInfo in self.connectMicArray) {
        if ([seatInfo.userInfo.accountId  isEqualToString:event.seatInfo.userInfo.accountId]) {
            [self.connectMicArray removeObject:seatInfo];
            break;
        }
    }
    
    if (self.connectMicArray.count > 0) {
        [self.connectMicView reloadDataSource:self.connectMicArray];
        [self updateStreamUserTrans:event.seatInfo.avRoomUid];
    }else {//无上麦观众
        self.connectMicView.hidden = YES;
    }
    
    NIMMessage *message = [[NIMMessage alloc] init];
    message.text = [NSString stringWithFormat:@"\"%@\" 成功下麦",event.seatInfo.userInfo.userName];
    message.remoteExt = @{@"type":@(1)};
    [self.chatView addMessages:@[message]];
}

- (void)onSeatPickAccepted:(NESeatPickAcceptEvent * _Nonnull)event {
    
}

- (void)onSeatPickRejected:(NESeatPickRejectEvent * _Nonnull)event {
    [NETSToast showToast:NSLocalizedString(@"对方拒绝了你的邀请", nil)];
}

- (void)onSeatPickRequest:(NESeatPickRequestEvent * _Nonnull)event {
    
}

- (void)onSeatPickRequestCanceled:(NESeatPickRequestCancelEvent * _Nonnull)event {
    
}

- (void)onSeatStateChanged:(NESeatStateChangeEvent * _Nonnull)event {
    
}

- (void)onSeatAudioStateChanged:(NESeatAudioStateChangeEvent * _Nonnull)event {
    //更新上麦者的音频信息
    for (NESeatInfo *memberModel in self.connectMicArray) {
        if ([event.seatInfo.userInfo.accountId isEqualToString:memberModel.userInfo.accountId]) {
            memberModel.audioState = event.seatInfo.audioState;
            break;
        }
    }
    [self.connectMicView reloadDataSource:self.connectMicArray];
}

- (void)onSeatVideoStateChanged:(NESeatVideoStateChangeEvent * _Nonnull)event {
    //更新上麦者的视屏信息
    for (NESeatInfo *memberModel in self.connectMicArray) {
        if ([event.seatInfo.userInfo.accountId isEqualToString:memberModel.userInfo.accountId]) {
            memberModel.videoState = event.seatInfo.videoState;
            break;
        }
    }
    [self.connectMicView reloadDataSource:self.connectMicArray];
}

#pragma mark - NETSMutiConnectViewDelegate
-(void)disconnectRoomWithUserId:(NSString *)userId {

    NEKickSeatParams *params = [[NEKickSeatParams alloc]init];
    params.userId = userId;
    [[NELiveRoom sharedInstance].seatService kickSeat:params completion:^(NSError * _Nullable error) {
        if (error) {
            YXAlogError(@"anchor kickSeat failed,error = %@",error);
        }else {
            YXAlogInfo(@"anchor kickSeat success");
        }
    }];
}

-(void)dealloc  {
    [[NELiveRoom sharedInstance].seatService removeDelegate:self];
    [[NIMSDK sharedSDK].chatManager removeDelegate:self.pkChatRoomMsgHandle];
    [[NIMSDK sharedSDK].chatroomManager removeDelegate:self.pkChatRoomMsgHandle];
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self.pkChatRoomMsgHandle];
}

#pragma mark - lazyMethod
-(NEPkChatroomMsgHandle *)pkChatRoomMsgHandle {
    if (!_pkChatRoomMsgHandle) {
        _pkChatRoomMsgHandle = [[NEPkChatroomMsgHandle alloc]init];
        _pkChatRoomMsgHandle.delegate = self;
    }
    return _pkChatRoomMsgHandle;
}


- (NETSMutiConnectView *)connectMicView {
    if (!_connectMicView) {
        _connectMicView = [[NETSMutiConnectView alloc]initWithDataSource:self.connectMicArray frame:CGRectMake(kScreenWidth-88-10, 104, 88, kScreenHeight-2*104)];
        _connectMicView.roleType = NETSUserModeAnchor;
        _connectMicView.hidden = YES;
        _connectMicView.delegate = self;
    }
    return _connectMicView;
}

-(NSMutableArray<NESeatInfo *> *)connectMicArray {
    if (!_connectMicArray) {
        _connectMicArray = [NSMutableArray array];
    }
    return _connectMicArray;
}

- (NETSAudienceNum *)audienceInfo {
    if (!_audienceInfo) {
        _audienceInfo = [[NETSAudienceNum alloc] initWithFrame:CGRectZero];
    }
    return _audienceInfo;
}

- (NETSAnchorTopInfoView *)anchorInfo {
    if (!_anchorInfo) {
        _anchorInfo = [[NETSAnchorTopInfoView alloc] init];
    }
    return _anchorInfo;
}
@end
