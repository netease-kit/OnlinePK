//
//  NETSAudienceChatRoomCell.m
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2021/1/7.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSAudienceChatRoomCell.h"
#import <NELivePlayerFramework/NELivePlayerFramework.h>
#import "NETSLiveListVM.h"
#import "NETSAudienceMask.h"
#import "NETSLiveModel.h"
#import "NETSChatroomService.h"
#import "NENavigator.h"
#import "NETSLiveApi.h"
#import "NETSPullStreamErrorView.h"
#import "Reachability.h"
#import "NETSLiveEndView.h"
#import "NETSMutiConnectView.h"
#import <NERtcSDK/NERtcSDK.h>
#import "NETSLiveAttachment.h"
#import "NETSConnectMicModel.h"
#import "TopmostView.h"
#import "NETSAudienceBottomBar.h"

@interface NETSAudienceChatRoomCell ()<NETSPullStreamErrorViewDelegate, NETSAudienceMaskDelegate,NETSMutiConnectViewDelegate>

/// 蒙层
@property (nonatomic, strong) NETSAudienceMask          *mask;
/// 直播间状态
@property (nonatomic, strong) NETSLiveRoomInfoModel     *roomInfo;
/// 断网视图
@property(nonatomic, strong) NETSPullStreamErrorView    *networkFailureView;
/// 直播结束蒙层
@property(nonatomic, strong) NETSLiveEndView            *liveClosedMask;
/// 网络监测类
@property(nonatomic, strong) Reachability               *reachability;
/// 播放器
@property(nonatomic, strong) NELivePlayerController     *player;
/// 直播间状态
@property(nonatomic, assign) NETSAudienceRoomStatus     roomStatus;
//观众端连麦视图
@property(nonatomic, strong) NETSMutiConnectView *connectMicView;
//连麦者数组
@property(nonatomic, strong) NSMutableArray *connectMicArray;
//连麦者uid数组
@property(nonatomic, strong) NSArray *connectMicUidArray;

@property(nonatomic, strong) UIView *connecterBgView;

@end

@implementation NETSAudienceChatRoomCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.mask];
        
        self.reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
        [self.reachability startNotifier];
        self.mask.chatRoomAvailable = [self.reachability isReachable];
        
        // 播放器视图添加向左轻扫动作
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_swipeShowMask:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.contentView addGestureRecognizer:swipeLeft];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_swipeDismissMask:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.contentView addGestureRecognizer:swipeRight];
        
        // 播放器相关通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackFinishedNotification:) name:NELivePlayerPlaybackFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerRetryNotification:) name:NELivePlayerRetryNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFirstVideoDisplayedNotification:) name:NELivePlayerFirstVideoDisplayedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLoadStateChangedNotification:) name:NELivePlayerLoadStateChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackStateChangedNotification:) name:NELivePlayerPlaybackStateChangedNotification object:nil];
        
        // 监测网络
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audienceModeChange:) name:NotificationName_Audience_AcceptConnectMic object:nil];
    }
    return self;
}

- (void)audienceModeChange:(NSNotification *)notification{
    
    if ([NSObject isNullOrNilWithObject:self.roomModel]) {
        return;
    }
    
    NSDictionary *userInfo = (NSDictionary *)[notification object];
    BOOL isLeave = [userInfo[@"isLeave"] boolValue];
    NSDictionary *memberDict = userInfo[@"memberInfo"];
    NETSConnectMicMemberModel *changeMemberModel = [NETSConnectMicMemberModel yy_modelWithDictionary:memberDict];
    
    if (isLeave) {//下麦操作
        if ([changeMemberModel.accountId isEqualToString:[NEAccount shared].userModel.accountId]) {
            [self changeToAudience];//切为观众视图
        }
        [self.connectMicArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NETSConnectMicMemberModel *memberModel = obj;
            if ([memberModel.accountId isEqualToString:changeMemberModel.accountId]) {
                [self.connectMicArray removeObject:obj];
                *stop = NO;
            }
        }];

    }else {//上麦操作

        if ([changeMemberModel.accountId isEqualToString:[NEAccount shared].userModel.accountId]) {
            [self _obtainChatroomInfo:_roomModel isNeedEnterChatRoom:NO];//上麦拉取远端麦位人数
            [self changeToConnecterView];
            [self.mask addSubview:self.connectMicView];
            [self.mask addSubview:self.connecterBgView];
            [self.mask sendSubviewToBack:self.connecterBgView];
            NERtcVideoCanvas *canvas = [[NERtcVideoCanvas alloc] init];
            canvas.container = self.connecterBgView;
            int result = [[NERtcEngine sharedEngine] setupRemoteVideoCanvas:canvas forUserID:self.roomModel.avRoomUid.longLongValue];
            if (result != 0) {
                YXAlogError(@"设置远端用户视图失败");
            }
            if (![self.connectMicUidArray containsObject:changeMemberModel.accountId]) {//去重过滤
                [self.connectMicArray insertObject:changeMemberModel atIndex:0];
            }

        }else {
            [self didChangeRoomStatus:NETSAudienceConnectStart];
            if (![self.connectMicUidArray containsObject:changeMemberModel.accountId]) {//去重过滤
                [self.connectMicArray addObject:changeMemberModel];
            }
        }
    }
    [self.connectMicView reloadDataSource:self.connectMicArray];

}

- (void)updateLocalConnecterArray:(NSArray *)serverArray {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NETSConnectMicMemberModel *member in serverArray) {
        [tempArray addObject:member.accountId];
    }
    self.connectMicUidArray = tempArray;
}

//切换到连麦者视图
- (void)changeToConnecterView {
    [self didChangeRoomStatus:NETSAudienceStreamDefault];
    [self shutdownPlayer];
}

//切换到观众视图
- (void)changeToAudience {
    [self userLeaveRtcRoomAction];
    //重新添加播放器视图
    [self _layoutPlayerWithY:0];
    [self _playWithUrl:self.roomModel.liveConfig.rtmpPullUrl];
    [self.connectMicArray removeAllObjects];
}

//自己下麦操作
- (void)userLeaveRtcRoomAction {
    [NERtcEngine.sharedEngine leaveChannel];//观众离开rtc房间
    [self.connecterBgView removeFromSuperview];
    [self.connectMicView removeFromSuperview];
    self.connectMicView = nil;
    self.connecterBgView = nil;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self shutdownPlayer];
}

#pragma mark - public method

- (void)resetPageUserinterface
{
    // 添加mask之前先移除关闭直播的蒙版
    self.roomStatus = NETSAudienceRoomPullStream;
    [self.liveClosedMask removeFromSuperview];
    self.mask.left = 0;
}

- (void)shutdownPlayer;
{
    YXAlogInfo(@"观众端 关闭播放器");
    if (!_player) { return; }
    [self.player pause];
    [self.player shutdown];
    [self.player.view removeFromSuperview];
    self.player = nil;
}

- (void)closeConnectMicRoomAction {
    
    [self.mask setUpBottomBarButtonType:NETSAudienceBottomRequestTypeNormal];
    if (_connectMicView) {
        [self disconnectRoomWithUserId:self.roomModel.accountId];
        [self userLeaveRtcRoomAction];
    }
}

#pragma mark - get/set

- (void)setRoomModel:(NETSLiveRoomModel *)roomModel
{
    _roomModel = roomModel;
    self.mask.room = roomModel;
    [self _obtainChatroomInfo:roomModel isNeedEnterChatRoom:YES];
}

#pragma mark - NETSPullStreamErrorViewDelegate

/// 点击返回
- (void)clickBackAction
{
    [[NENavigator shared].navigationController popViewControllerAnimated:YES];
}

/// 重新连接
- (void)clickRetryAction
{
    [self.networkFailureView removeFromSuperview];
    self.mask.roomStatus = NETSAudienceRoomPullStream;
    [self _obtainChatroomInfo:self.roomModel isNeedEnterChatRoom:YES];
}

#pragma mark - Notification Method

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability *currentReach = [note object];
    NSCParameterAssert([currentReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [currentReach currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:{// 网络不可用
            YXAlogInfo(@"断网了");
            [self _showLiveRoomErrorView];
            [self shutdownPlayer];
            
        }
            break;

        default:
            break;
    }
}

#pragma mark - player notification

/// 播放器播放完成或播放发生错误时的消息通知
- (void)playerPlaybackFinishedNotification:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    [self _playerLoadErrorInfo:info];
    YXAlogInfo(@"观众端 播放器播放完成或播放发生错误时的消息通知, info: %@", info);
}

/// 播放器失败重试通知
- (void)playerRetryNotification:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    [self _playerLoadErrorInfo:info];
    YXAlogInfo(@"观众端 播放器重试加载, info: %@", info);
}

/// 播放器第一帧视频显示时的消息通知
- (void)playerFirstVideoDisplayedNotification:(NSNotification *)notification
{
    YXAlogInfo(@"观众端 播放器首帧播放");
    self.roomStatus = NETSAudienceRoomPlaying;
}

/// 播放器加载状态发生改变时的消息通知
- (void)playerLoadStateChangedNotification:(NSNotification *)notification
{
    YXAlogInfo(@"观众端 播放器加载状态发生改变时的消息通知, info: %ld", (long)_player.loadState);
}

/// 播放器播放状态发生改变时的消息通知
- (void)playerPlaybackStateChangedNotification:(NSNotification *)notification
{
    YXAlogInfo(@"观众端 播放器播放状态发生改变时的消息通知, playbackState: %ld", (long)_player.playbackState);
}

/// 播放器加载错误处理
- (void)_playerLoadErrorInfo:(NSDictionary *)info
{
    YXAlogInfo(@"观众端 处理播放器通知参数, info: %@", info);
    // 播放器播放结束原因的key
    NELPMovieFinishReason reason = [info[NELivePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    if (reason != NELPMovieFinishReasonPlaybackError) {
        return;
    }
    // 播放成功时，此字段为nil。播放器播放结束具体错误码。具体至含义见NELPPLayerErrorCode
    NELPPLayerErrorCode errorCode = [info[NELivePlayerPlaybackDidFinishErrorKey] integerValue];
    if (errorCode != 0) {
        [self _showLiveRoomErrorView];
    }
}

#pragma mark - NETSAudienceMaskDelegate

- (void)didChangeRoomStatus:(NETSAudienceStreamStatus)status
{
    // 视频上边缘距离设备顶部
    CGFloat top = 64 + (kIsFullScreen ? 44 : 20);
    // 获取播放器视图
    UIView *playerView = self.player.view;
    switch (status) {
        case NETSAudienceIMPkStart:
        {
            CGFloat scale = 1280 / 720.0;
            playerView.frame = CGRectMake(0, top, kScreenWidth * 0.5, kScreenWidth * 0.5 * scale);
        }
            break;
        case NETSAudienceStreamMerge:
        {
            CGFloat y = top - (kScreenHeight - (640 / 720.0 * kScreenWidth)) / 2.0;
            playerView.frame = CGRectMake(0, y, kScreenWidth, kScreenHeight);
        }
            break;
        case NETSAudienceIMPkEnd:
        {
            playerView.frame = CGRectMake(0, 0, kScreenWidth * 2, kScreenHeight * 2);
            playerView.centerX = kScreenWidth;
            playerView.centerY = self.contentView.centerY;
        }
            break;
        case NETSAudienceConnectStart:
        {
            CGFloat scale = 1280 / 720.0;
            playerView.frame = CGRectMake(0, top, kScreenWidth , kScreenWidth * scale);
        }
            break;
            
        default:
        {
            playerView.frame = [self _fillPlayerRect];
        }
            break;
    }
    YXAlogInfo(@"观众端播放器状态, status: %ld", (long)status);
}

/// 直播间关闭
- (void)didLiveRoomClosed {
    [self _showLiveRoomClosedView];
}

- (void)didAudioAndVideoChanged:(NETSConnectMicAttachment *)msgAttachment {
    //主播收到音视频变化的信息
    for (NETSConnectMicMemberModel *memberModel in self.connectMicArray) {
        if ([msgAttachment.member.accountId isEqualToString:memberModel.accountId]) {
            memberModel.audio = msgAttachment.member.audio;
            memberModel.video = msgAttachment.member.video;
            break;
        }
    }
    [self.connectMicView reloadDataSource:self.connectMicArray];
}

#pragma mark - NETSMutiConnectViewDelegate
-(void)disconnectRoomWithUserId:(NSString *)userId {
    [NETSLiveApi requestSeatManagerWithRoomId:self.roomModel.liveCid userId:userId index:1 action:NETSSeatsOperationWheatherLeaveSeats successBlock:^(NSDictionary * _Nonnull response) {
        YXAlogDebug(@"上麦者下麦成功,response = %@",response);
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogError(@"上麦者下麦失败，error = %@",error.description);
    }];
}

#pragma mark - private mehod

- (void)_showLiveRoomClosedView
{
    ntes_main_async_safe(^{
        self.roomStatus = self.mask.roomStatus = NETSAudienceRoomLiveClosed;
        [self.liveClosedMask installWithAvatar:self.roomModel.avatar nickname:self.roomModel.nickname];
        [self.mask addSubview:self.liveClosedMask];
    });
    [self.mask closeConnectMicRoom];

    if (self.connectMicArray.count >0) {
        [self userLeaveRtcRoomAction];
    }
    
    //清除顶层视图的subview
    UIView *topmostView = [TopmostView viewForApplicationWindow];
    for (UIView *subview in topmostView.subviews) {
        [subview removeFromSuperview];
    }
    topmostView.userInteractionEnabled = NO;

}

- (void)_showLiveRoomErrorView
{
    ntes_main_async_safe(^{
        self.roomStatus = self.mask.roomStatus = NETSAudienceRoomLiveError;
        [self.mask addSubview:self.networkFailureView];
    });
}

/// 获取直播间详情
- (void)_obtainChatroomInfo:(NETSLiveRoomModel *)roomModel isNeedEnterChatRoom:(BOOL)isNeed
{
    @weakify(self);
    void(^joinRoomSuccess)(NETSLiveRoomModel *, NETSLiveRoomInfoModel *) = ^(NETSLiveRoomModel *room, NETSLiveRoomInfoModel *info){
        ntes_main_async_safe(^{
            @strongify(self);
            self.mask.info = info;
            CGFloat y = 0;
            if (info.pkRecord && (info.status == NETSRoomPKing || info.status == NETSRoomPunishment)) {
                CGFloat top = 64 + (kIsFullScreen ? 44 : 20);
                y = top - (kScreenHeight - (640 / 720.0 * kScreenWidth)) / 2.0;
            }
            [self _layoutPlayerWithY:y];
            NSString *urlStr = room.liveConfig.rtmpPullUrl;
            YXAlogInfo(@"观众端 设置播放地址: %@", room.liveConfig.rtmpPullUrl);
            [self _playWithUrl:urlStr];
        });
        
        YXAlogInfo(@"观众端 加入直播间成功");
    };
    
    void(^joinRoomFailed)(NSError *) = ^(NSError *error){
        @strongify(self);
        [self _alertToExitRoomWithError:error];
        YXAlogInfo(@"观众端 加入直播间失败, error: %@", error);
    };
    
    [NETSLiveApi roomInfoWithCid:roomModel.liveCid completionHandle:^(NSDictionary * _Nonnull response) {
        @strongify(self);
        NETSLiveRoomInfoModel *info = response[@"/data"];
        if (!info) {
            YXAlogInfo(@"获取直播间详情失败, 房间信息为空");
            return;
        }
        self.roomInfo = info;
        self.connectMicArray = [[NSMutableArray alloc]initWithArray:info.seatList];
        [self updateLocalConnecterArray:info.seatList];//更新本地uid数组
        if (info.type == NETSLiveTypeConnectMic && self.connectMicArray.count >0) {
            [self.connectMicView reloadDataSource:self.connectMicArray];
        }
        if (isNeed) {//pk多人连麦不需要重新加入
            [self _joinChatRoom:roomModel.chatRoomId successBlock:^{
                joinRoomSuccess(roomModel, info);
            } failedBlock:joinRoomFailed];
        }
        
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        @strongify(self);
        if ([self.reachability isReachable]) {
            [self.mask closeChatRoom];
        }
        YXAlogInfo(@"获取直播间详情失败, error: %@", error);
    }];
}

/// 布局播放器
- (void)_layoutPlayerWithY:(CGFloat)y
{
    [self.contentView addSubview:self.player.view];
    [self.contentView sendSubviewToBack:self.player.view];
    
    self.player.view.top = y;
    
    if (y == 0) {
        self.player.view.frame = [self _fillPlayerRect];
    }
}

/// 缩放后播放器尺寸大小
- (CGRect)_fillPlayerRect {
    
    if (self.roomInfo.seatList.count > 0) {
        CGFloat scale = 1280 / 720.0;
        return CGRectMake(0, (kScreenHeight-kScreenWidth * scale)/2, kScreenWidth , kScreenWidth * scale);
    }else {
        CGFloat nor = 1280 / 720.0;
        CGFloat cur = kScreenHeight / kScreenWidth * 1.0;
        if (nor == cur) {
            return self.bounds;
        }
        CGFloat xOffset = (kScreenHeight / nor - kScreenWidth) * 0.5;
        return CGRectMake(-xOffset, 0, kScreenHeight / nor, kScreenHeight);
    }
}

/// 播放指定url源
- (void)_playWithUrl:(NSString *)urlStr
{
    NSURL *url = [NSURL URLWithString:urlStr];
    [self.player setPlayUrl:url];
    [self.player prepareToPlay];
}

/// 加入聊天室
- (void)_joinChatRoom:(NSString *)roomId successBlock:(void(^)(void))successBlock failedBlock:(void(^)(NSError *))failedBlock
{
    if (isEmptyString(roomId)) {
        if (failedBlock) {
            NSError *error = [NSError errorWithDomain:@"NETSAudience" code:NETSRequestErrorMapping userInfo:@{NSLocalizedDescriptionKey: @"观众端聊天室ID为空"}];
            failedBlock(error);
        }
        return;
    }
    
   // 检查主播是否在线
    void(^checkAuthodOnline)(NSString *) = ^(NSString *roomId) {
        [NETSChatroomService isOnlineWithRoomId:roomId completion:^(BOOL isOnline) {
            if (isOnline) {
                if (successBlock) { successBlock(); }
            } else {
                if (failedBlock) {
                    NSError *error = [NSError errorWithDomain:@"NETSAudience" code:NETSRequestErrorMapping userInfo:@{NSLocalizedDescriptionKey: @"主播已下线"}];
                    failedBlock(error);
                }
            }
        }];
    };
    
    // 加入直播间
    [NETSChatroomService enterWithRoomId:roomId userMode:NETSUserModeAudience success:^(NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me) {
        checkAuthodOnline(roomId);
    } failed:^(NSError * _Nullable error) {
        if (failedBlock) { failedBlock(error); }
    }];
}

/// 直播间关闭弹窗
- (void)_alertToExitRoomWithError:(nullable NSError *)error
{
    BOOL accountErr = NO;
    if ([error.domain isEqualToString:@"NIMLocalErrorDomain"] && error.code == 13) {
        accountErr = YES;
    }
    NSString *title = accountErr ? @"您的账号已登出" : @"直播间已关闭";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"点击确定关闭该直播间" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (accountErr) {
            [[NENavigator shared].navigationController popToRootViewControllerAnimated:YES];
        } else {
            [[NENavigator shared].navigationController popViewControllerAnimated:YES];
        }
    }];
    [alert addAction:confirm];
    [[NENavigator shared].navigationController presentViewController:alert animated:YES completion:nil];
}

/// 向左轻扫显示蒙层
- (void)_swipeShowMask:(UISwipeGestureRecognizer *)gesture
{
    YXAlogInfo(@"向左轻扫显示蒙层");
    if (self.mask.left > kScreenWidth/2.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.mask.left = 0;
        }];
    }
}
- (void)_swipeDismissMask:(UISwipeGestureRecognizer *)gesture
{
    if (_roomStatus == NETSAudienceRoomLiveClosed || _roomStatus == NETSAudienceRoomLiveError) {
        YXAlogInfo(@"页面故障,阻止向右轻扫隐藏蒙层");
        return;
    }
    YXAlogInfo(@"向右轻扫隐藏蒙层");
    if (self.mask.left < kScreenWidth/2.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.mask.left = kScreenWidth;
        }];
    }
}



#pragma mark - lazy load

- (NETSAudienceMask *)mask
{
    if (!_mask) {
        _mask = [[NETSAudienceMask alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _mask.delegate = self;
    }
    return _mask;
}

- (NETSPullStreamErrorView *)networkFailureView
{
    if (!_networkFailureView) {
        _networkFailureView = [[NETSPullStreamErrorView alloc]init];
        [_networkFailureView installWithAvatar:self.roomModel.avatar nickname:self.roomModel.nickname];
        _networkFailureView.delegate = self;
        _networkFailureView.userInteractionEnabled = YES;
    }
    return _networkFailureView;
}

- (NETSLiveEndView *)liveClosedMask
{
    if (!_liveClosedMask) {
        _liveClosedMask = [[NETSLiveEndView alloc] init];
    }
    return _liveClosedMask;
}

- (NELivePlayerController *)player
{
    if (!_player) {
        _player = [[NELivePlayerController alloc] init];
        [_player setBufferStrategy:NELPTopSpeed];
        [_player setScalingMode:NELPMovieScalingModeNone];
        [_player setShouldAutoplay:YES];
        [_player setHardwareDecoder:YES];
        [_player setPauseInBackground:NO];
        [_player setPlaybackTimeout:(3 * 1000)];
        
        NELPRetryConfig *retryConfig = [[NELPRetryConfig alloc] init];
        retryConfig.count = 1;
        [_player setRetryConfig:retryConfig];
    }
    return _player;
}

- (NETSMutiConnectView *)connectMicView {
    if (!_connectMicView) {
        _connectMicView = [[NETSMutiConnectView alloc]initWithDataSource:self.connectMicArray frame:CGRectMake(kScreenWidth-88-10, 104, 88, kScreenHeight-2*104)];
        _connectMicView.roleType = NETSUserModeConnecter;
        _connectMicView.delegate = self;
    }
    return _connectMicView;
}

- (UIView *)connecterBgView {
    if (!_connecterBgView) {
        _connecterBgView = [[UIView alloc]initWithFrame:self.contentView.bounds];
    }
    return _connecterBgView;
}

- (NSMutableArray *)connectMicArray {
    if (!_connectMicArray) {
        _connectMicArray = [NSMutableArray array];
    }
    return _connectMicArray;
}
- (void)dealloc {
    YXAlogInfo(@"dealloc NETSAudienceChatRoomCell: %p", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self shutdownPlayer];
}
@end
