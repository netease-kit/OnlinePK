//
//  NETSAudienceMask.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSGiftAnimationView.h"
#import "NETSInvitingBar.h"
#import "LOTAnimationView.h"
#import "NETSInviteeInfoView.h"
#import "NTESKeyboardToolbarView.h"
#import "NETSToast.h"
#import "NETSPkStatusBar.h"
#import "NETSLiveChatView.h"
#import "NETSAudienceSendGiftSheet.h"
#import "NETSAudienceMask.h"
#import "NETSAnchorTopInfoView.h"
#import "TopmostView.h"
#import "NETSAudienceBottomBar.h"

#import "NETSConnectStatusViewController.h"
#import "NTESActionSheetNavigationController.h"


#import <NELivePlayerFramework/NELivePlayerNotication.h>
#import "NETSGCDTimer.h"
#import "NETSLiveUtils.h"
#import "NETSChatroomService.h"
#import "NETSLiveApi.h"
#import "NENavigator.h"
#import "NETSAudienceNum.h"
#import "NETSAudienceVM.h"
#import "NETSLiveConfig.h"
#import "NELiveRoomListModel.h"
#import "NECreateRoomResponseModel.h"
#import "AppKey.h"
#import "NEPkRoomApiService.h"
#import "NEPkRewardParams.h"
#import "NEPkChatroomMsgHandle.h"
#import "NEPkLiveAttachment.h"
#import "NEPkRoomService.h"
#import "NETSFUManger.h"
#import "NEPkLiveAttachment.h"
#import "NEPkInfoModel.h"
#define kPkAudienceTimerQueue            "com.netease.pk.audience.timer.queue"

@interface NETSAudienceMask ()
<
    NEPkChatroomMsgHandleDelegate,
    NETSAudienceBottomBarDelegate,
    NETSAudienceSendGiftSheetDelegate,
    NTESKeyboardToolbarDelegate,
    NETSInvitingBarDelegate,
    NTESAudienceConnectStatusDelegate,
    NESeatServiceDelegate
>

/// 主播信息
@property (nonatomic, strong)   NETSAnchorTopInfoView   *anchorInfo;
/// 直播中 观众数量视图
@property (nonatomic, strong)   NETSAudienceNum         *audienceInfo;
/// 聊天视图
@property (nonatomic, strong)   NETSLiveChatView        *chatView;
/// 聊天室代理
@property(nonatomic, strong)    NEPkChatroomMsgHandle *chatHandle;

/// viewModel
@property (nonatomic, strong)   NETSAudienceVM          *viewModel;
/// 底部视图
@property (nonatomic, strong)   NETSAudienceBottomBar   *bottomBar;
/// 键盘工具条
@property (nonatomic, strong)   NTESKeyboardToolbarView *toolBar;
/// pk状态条
@property (nonatomic, strong)   NETSPkStatusBar         *pkStatusBar;
/// 被邀请者信息视图
@property (nonatomic, strong)   NETSInviteeInfoView     *inviteeInfo;

/// pk胜利图标
@property (nonatomic, strong)   UIImageView     *pkSuccessIco;
/// pk失败图标
@property (nonatomic, strong)   UIImageView     *pkFailedIco;
/// 计时器操作队列
@property (nonatomic, strong) dispatch_queue_t      timerQueue;
/// 计时器,记录超时
@property (nonatomic, strong, nullable) NETSGCDTimer            *timer;
/// 礼物动画控件
@property (nonatomic, strong)   NETSGiftAnimationView   *giftAnimation;
/// 直播间状态
@property (nonatomic, assign)   NEPkliveStatus      liveStatus;
//观众请求连麦状态条
@property(nonatomic, strong) NETSInvitingBar *requestConnectMicBar;

@property(nonatomic, strong) NEPkRoomApiService *apiService;
//当前主播角色类型，邀请者还是被邀请者
@property(nonatomic, assign) NETSPkServiceRole pkRole;
//pk信息
@property(nonatomic, strong) NEPkInfoModel *pkInfoModel;
//记录已上麦的用户id
@property(nonatomic, strong) NSString *enterUserAccountId;
//是否joinrtc房间
@property(nonatomic, assign) BOOL isJoinedRtc;
@end

@implementation NETSAudienceMask

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [[NELiveRoom sharedInstance].seatService addDelegate:self];
        [[NIMSDK sharedSDK].chatManager addDelegate:self.chatHandle];
        [[NIMSDK sharedSDK].chatroomManager addDelegate:self.chatHandle];
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self.chatHandle];
        [self addSubview:self.anchorInfo];
        [self addSubview:self.audienceInfo];
        [self addSubview:self.chatView];
        [self addSubview:self.bottomBar];
        [self addSubview:self.toolBar];
        [self bringSubviewToFront:self.toolBar];
        [self _bindEvent];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayerFrameChanged:) name:NELivePlayerVideoSizeChangedNotification object:nil];
        _timerQueue = dispatch_queue_create(kPkAudienceTimerQueue, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].chatManager removeDelegate:self.chatHandle];
    [[NIMSDK sharedSDK].chatroomManager removeDelegate:self.chatHandle];
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self.chatHandle];
    [[NELiveRoom sharedInstance].seatService removeDelegate:self];
    YXAlogInfo(@"dealloc NETSAudienceMask: %p", self);
}

- (void)_bindEvent {
    @weakify(self);
    RACSignal *roomSignal = RACObserve(self, room);
    [roomSignal subscribeNext:^(NELiveRoomListDetailModel *x) {
        @strongify(self);
        if (x == nil) { return; }
        self.chatHandle.chatroomId = x.live.chatRoomId;
        [self _refreshAudienceInfoWitHRoomId:x.live.chatRoomId];
        self.anchorInfo.nickname = x.anchor.nickname;
        self.anchorInfo.avatarUrl = x.anchor.avatar;
    }];
    
    [[roomSignal zipWith:RACObserve(self, info)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        NELiveRoomListDetailModel *room = (NELiveRoomListDetailModel *)tuple.first;
        NECreateRoomResponseModel *info = (NECreateRoomResponseModel *)tuple.second;
        if (room && info) {
            // 更新主播云币
            self.anchorInfo.wealth = info.live.rewardTotal;
        }
    }];
}

- (void)layoutSubviews
{
    self.anchorInfo.frame = CGRectMake(8, (kIsFullScreen ? 44 : 20) + 4, 124, 36);
    self.audienceInfo.frame = CGRectMake(kScreenWidth - 8 - 195, self.anchorInfo.top + (36 - 28) / 2.0, 195, 28);
    CGFloat chatViewHeight = [self _chatViewHeight];
    self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
    self.bottomBar.frame = CGRectMake(0, kScreenHeight - (kIsFullScreen ? 34 : 0) - 36 - 14, kScreenWidth, 36);
}

- (void)setRoom:(NELiveRoomListDetailModel *)room {
    _room = room;
    self.bottomBar.roomType = self.room.live.type;

}

-(void)setInfo:(NECreateRoomResponseModel *)info {
    _liveStatus = info.live.liveStatus;
    if (info.live.liveStatus == NEPkliveStatusPkLiving || info.live.liveStatus == NEPkliveStatusPunish) {
        [self.apiService requestPkInfoWithRoomId:info.live.roomId completionHandle:^(NSDictionary * _Nonnull response) {
            NEPkInfoModel *pkInfoModel = response[@"/data"];
            [self refreshWithRoom:pkInfoModel];

        } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
            YXAlogError(@"requestPkInfo failed,error = %@",error);
        }];
    }else {
        [self.inviteeInfo removeFromSuperview];
        [self.pkStatusBar removeFromSuperview];
        [self.pkSuccessIco removeFromSuperview];
        [self.pkFailedIco removeFromSuperview];
    }
}

- (void)refreshWithRoom:(NEPkInfoModel *)currentPkInfo {

    //判断当前房间是否是邀请者
    if ([self.room.anchor.accountId isEqualToString:currentPkInfo.inviter.accountId]) {
        self.pkRole = NETSPkServiceInviter;
    }else {
        self.pkRole = NETSPkServiceInvitee;
    }
    
    [self _layoutPkStatusBarWithStatus:_liveStatus];

    if (currentPkInfo.status == NEPKStatusPking) {
        // pk状态栏变更
        // pk开始: 启动倒计时,刷新内容
        [self.pkStatusBar countdownWithSeconds:currentPkInfo.countDown prefix:@"PK "];
        
        if (_pkRole == NETSPkServiceInviter) {
            [self.pkStatusBar refreshWithLeftRewardCoins:currentPkInfo.inviter.rewardTotal leftRewardAvatars:currentPkInfo.inviterReward.rewardAvatars rightRewardCoins:currentPkInfo.invitee.rewardTotal rightRewardAvatars:currentPkInfo.inviteeReward.rewardAvatars];
        }else {
            [self.pkStatusBar refreshWithLeftRewardCoins:currentPkInfo.invitee.rewardTotal leftRewardAvatars:currentPkInfo.inviteeReward.rewardAvatars rightRewardCoins:currentPkInfo.inviter.rewardTotal rightRewardAvatars:currentPkInfo.inviterReward.rewardAvatars];
        }
        
    }else if(currentPkInfo.status == NEPKStatusPkPunish){
        
        if (_pkRole == NETSPkServiceInviter) {
            [self _layoutOtherAnchorWithAvatar:currentPkInfo.invitee.avatar nickname:currentPkInfo.invitee.nickname status:_liveStatus];
        }else {
            [self _layoutOtherAnchorWithAvatar:currentPkInfo.inviter.avatar nickname:currentPkInfo.inviter.nickname status:_liveStatus];
        }

        // 获取pk结果
        NETSPkResult res = NETSPkUnknownResult;
        if (currentPkInfo.invitee.rewardTotal == currentPkInfo.inviter.rewardTotal) {
            res = NETSPkTieResult;
        }else if ((currentPkInfo.invitee.rewardTotal > currentPkInfo.inviter.rewardTotal && self.pkRole == NETSPkServiceInvitee) ||
                 (currentPkInfo.invitee.rewardTotal < currentPkInfo.inviter.rewardTotal && self.pkRole == NETSPkServiceInviter)) {
            res = NETSPkCurrentAnchorWin;
        }else {
            res = NETSPkOtherAnchorWin;
        }
        
        if (res == NETSPkTieResult) {
            [self.pkStatusBar stopCountdown];
        } else {
            [self.pkStatusBar countdownWithSeconds:currentPkInfo.countDown prefix:@"惩罚 "];
        }
        //显示pk结果
        [self _layoutPkResultWhenGetCurrentAnchorWin:res];
    }
}

#pragma mark - setter/getter

-(void)setRoomStatus:(NEPkRoomStatus)roomStatus {
    _roomStatus = roomStatus;
    if (roomStatus != NEPkRoomStatusOngoing) {
        [self.inviteeInfo removeFromSuperview];
        [self.pkStatusBar removeFromSuperview];
        [self.pkSuccessIco removeFromSuperview];
        [self.pkFailedIco removeFromSuperview];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeRoomStatus:)]) {
            [self.delegate didChangeRoomStatus:NETSAudienceStreamDefault];
        }
    }
}


#pragma mark - private method

/// 获取聊天视图高度
- (CGFloat)_chatViewHeight
{
    if (kScreenHeight <= 568) {
        return 100;
    } else if (kScreenHeight <= 736) {
        return 130;
    }
    return 204;
}

/// 布局另一个主播信息视图
- (void)_layoutOtherAnchorWithAvatar:(NSString *)avatar nickname:(NSString *)nickname status:(NEPkliveStatus)status {
    
    if (status == NEPkliveStatusPkLiving || status == NEPkliveStatusPunish)  {
        CGFloat topOffset = 72 + (kIsFullScreen ? 44 : 20);
        self.inviteeInfo.frame = CGRectMake(self.right - 8 - 82, topOffset, 82, 24);
        [self.inviteeInfo reloadAvatar:avatar nickname:nickname];
        [self addSubview:self.inviteeInfo];
    } else {
        [self.inviteeInfo removeFromSuperview];
    }
}

/// 布局pk状态条
- (void)_layoutPkStatusBarWithStatus:(NEPkliveStatus)status {
    if (status == NEPkliveStatusPkLiving || status == NEPkliveStatusPunish) {
        CGFloat topOffset = (kIsFullScreen ? 44 : 20) + 44 + 20 + kScreenWidth * 640 / 720.0;
        CGRect rect = CGRectMake(0, topOffset, self.width, 58);
        self.pkStatusBar.frame = rect;
        [self addSubview:self.pkStatusBar];
        
        [self bringSubviewToFront:self.pkStatusBar];
        [self bringSubviewToFront:self.toolBar];
    }
}

/// 布局胜负标志: pk阶段结束,返回pk结果
- (void)_layoutPkResultWhenGetCurrentAnchorWin:(NETSPkResult)pkResult {
    
    CGFloat top = 64 + (kIsFullScreen ? 44 : 20) + kScreenWidth * 0.5 * 640 / 360.0 - 100;
    CGRect leftIcoFrame = CGRectMake((kScreenWidth * 0.5 - 100) * 0.5, top, 100, 100);
    CGRect rightIcoFrame = CGRectMake(kScreenWidth * 0.5 + (kScreenWidth * 0.5 - 100) * 0.5, top, 100, 100);
    
    self.pkSuccessIco.image = [UIImage imageNamed:@"pk_succeed_ico"];
    self.pkFailedIco.image = [UIImage imageNamed:@"pk_failed_ico"];
    
    switch (pkResult) {
        case NETSPkCurrentAnchorWin:
        {
            self.pkSuccessIco.frame = leftIcoFrame;
            self.pkFailedIco.frame = rightIcoFrame;
        }
            break;
        case NETSPkOtherAnchorWin:
        {
            self.pkSuccessIco.frame = rightIcoFrame;
            self.pkFailedIco.frame = leftIcoFrame;
        }
            break;
        case NETSPkTieResult:
        {
            self.pkSuccessIco.image = [UIImage imageNamed:@"pk_tie_ico"];
            self.pkFailedIco.image = [UIImage imageNamed:@"pk_tie_ico"];
            
            self.pkSuccessIco.frame = leftIcoFrame;
            self.pkFailedIco.frame = rightIcoFrame;
        }
            break;
            
        default:
            break;
    }
    
    [self addSubview:self.pkSuccessIco];
    [self addSubview:self.pkFailedIco];
}

/// 布局胜负标志: 惩罚结束(pk结束)
- (void)_layoutPkResultWhenPunishmentEnd
{
    [self.pkSuccessIco removeFromSuperview];
    [self.pkFailedIco removeFromSuperview];
}

/// 获取打赏列表
- (void)_fetchRewardListWithLiveCid:(NSString *)liveCid anchorAccountId:(NSString *)anchorAccountId successBlock:(void(^)(NETSPkLiveContriList *))successBlock failedBlock:(void(^)(NSError *))failedBlock
{
    [NETSLiveApi getPkLiveContriListWithLiveCid:liveCid liveType:NETSLiveTypePK anchorAccountId:anchorAccountId successBlock:^(NSDictionary * _Nonnull response) {
        NETSPkLiveContriList *list = response[@"/data"];
        if (list) {
            if (successBlock) { successBlock(list); }
        } else {
            YXAlogInfo(@"观众获取pk打赏榜数据为空...");
        }
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogInfo(@"观众获取pk打赏榜失败, error: %@", error);
    }];
}

/// 点击屏幕收起键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.toolBar resignFirstResponder];
    [self.bottomBar resignFirstResponder];
}


/// 播放礼物动画
- (void)_playGiftWithName:(NSString *)name
{
    [self addSubview:self.giftAnimation];
    [self bringSubviewToFront:self.giftAnimation];
    [self.giftAnimation addGift:name];
}

- (void)joinChannelWithData:(NEAvRoomUserDetail *)data {
        
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    
    // 打开推流,回调摄像头采集数据
    NSDictionary *params = @{
        kNERtcKeyPublishSelfStreamEnabled: @YES,    // 打开推流
        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户
    };
    [coreEngine setClientRole:kNERtcClientRoleBroadcaster];
    [coreEngine setParameters:params];

    // 启用本地音/视频
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
    
    int result = [NERtcEngine.sharedEngine joinChannelWithToken:data.avRoomCheckSum channelName:data.avRoomCName myUid:[data.avRoomUid longLongValue] completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
        if (error) {
            YXAlogError(@"audience joinChannel failed， error = %@",error);
        }else{
            self.isJoinedRtc = YES;
            YXAlogInfo(@"audience joinChannel success!");
        }
    }];
    if (result != 0) {
        self.isJoinedRtc = NO;
        if (result == kNERtcErrInvalidState) {//30005是因为还未退出rtc导致的
            if (self.delegate && [self.delegate respondsToSelector:@selector(joinchannelFailed:)]) {
                [self.delegate joinchannelFailed:result];
            }
        }
        YXAlogError(@"audience joinChannel failed ，errorcode = %d",result);
    }
}


#pragma mark - 当键盘事件

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float keyBoardHeight = keyboardRect.size.height;
    CGFloat chatViewHeight = [self _chatViewHeight];
    [UIView animateWithDuration:0.1 animations:^{
        self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - chatViewHeight - keyBoardHeight - 50, kScreenWidth - 16 - 60 - 20, chatViewHeight);
        self.toolBar.frame = CGRectMake(0, kScreenHeight - keyBoardHeight - 50, kScreenWidth, 50);
    }];
    [self bringSubviewToFront:self.toolBar];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    CGFloat chatViewHeight = [self _chatViewHeight];
    [UIView animateWithDuration:0.1 animations:^{
        self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
        self.toolBar.frame = CGRectMake(0, kScreenHeight + 50, kScreenWidth, 50);
    }];
}

/// 刷新观众信息
- (void)_refreshAudienceInfoWitHRoomId:(NSString *)roomId {
    [NETSChatroomService fetchMembersRoomId:roomId limit:10 successBlock:^(NSArray<NIMChatroomMember *> * _Nullable members) {
        YXAlogInfo(@"members: %@", members);
        [self.audienceInfo reloadWithDatas:members];
    } failedBlock:^(NSError * _Nonnull error) {
        YXAlogInfo(@"观众端获取IM聊天室成员失败, error: %@", error);
    }];
}

#pragma mark - 播放器通知

- (void)didPlayerFrameChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];

    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeRoomStatus:)]) {
        CGFloat height = [userInfo[NELivePlayerVideoHeightKey] floatValue];
        NETSAudienceStreamStatus status = NETSAudienceStreamDefault;
        if (height == 640) {
            status = NETSAudienceStreamMerge;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate didChangeRoomStatus:status];
        });
    }
    YXAlogInfo(@"video size changed, width: %@, height: %@", userInfo[NELivePlayerVideoWidthKey] ?: @"-", userInfo[NELivePlayerVideoHeightKey] ?: @"-");
}

#pragma mark - NEPkChatroomMsgHandleDelegate 聊天室代理
/// 进入或离开房间
-(void)didChatroomMember:(NIMChatroomNotificationMember *)member enter:(BOOL)enter sessionId:(NSString *)sessionId {
    if (![sessionId isEqualToString:self.room.live.chatRoomId]) {
        return;
    }
    
    if ([self.room.anchor.imAccid isEqualToString:member.userId]) {//主播进出房间的聊天室消息 不显示
        return;
    }
    
    if (enter) {
        _viewModel.chatroom.onlineUserCount++;
        YXAlogInfo(@"[demo] user %@ enter room.", member.userId);
    } else {
        _viewModel.chatroom.onlineUserCount--;
        YXAlogInfo(@"[demo] user %@ leaved room.", member.userId);
    }

    NIMMessage *message = [[NIMMessage alloc] init];
    message.text = [NSString stringWithFormat:@"\"%@\" %@房间", member.nick, (enter ? @"加入":@"离开")];
    message.remoteExt = @{@"type":@(1)};
    [_chatView addMessages:@[message]];
    [self _refreshAudienceInfoWitHRoomId:self.room.live.chatRoomId];
}



/// 直播间关闭
- (void)didChatroomClosedWithRoomId:(NSString *)roomId {
    if (![roomId isEqualToString:self.room.live.chatRoomId]) {
        return;
    }
    YXAlogInfo(@"聊天室关闭");
    [self _liveRoomClosed];
}

- (void)didChatroomKickWithRoomId:(NSString *)roomId {
    if (![roomId isEqualToString:self.room.live.chatRoomId]) {
        return;
    }
    [NETSAlertPrompt showAlert:UIAlertControllerStyleAlert title:NSLocalizedString(@"已被其他设备踢出", nil) message:NSLocalizedString(@"暂不支持多台设备进入同一直播间，\n您可以去其他直播间转转～", nil) actionArr:@[NSLocalizedString(@"确定", nil)] actionColors:@[HEXCOLOR(0x007AFF)] cancel:nil index:^(NSInteger index) {
        if (index) {
            [self clickCloseBtn];
        }
    } presentVc:[NETSUniversalTool getCurrentActivityViewController]];
    
}

/// 聊天室收到PK消息
-(void)receivePkStartAttachment:(NEPkLiveStartAttachment *)liveStartData {
  
    _liveStatus = NEPkliveStatusPkLiving;

    // pk开始:通知外围变更播放器frame
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeRoomStatus:)]) {
        [self.delegate didChangeRoomStatus:NETSAudienceIMPkStart];
    }

    if ([self.room.anchor.accountId isEqualToString:liveStartData.inviter.accountId]) {//判断自己是否是邀请者
        // pk第二主播信息载入
        self.pkRole = NETSPkServiceInviter;
        [self _layoutOtherAnchorWithAvatar:liveStartData.invitee.avatar nickname:liveStartData.invitee.nickname status:_liveStatus];
    }else {
        self.pkRole = NETSPkServiceInvitee;
        [self _layoutOtherAnchorWithAvatar:liveStartData.inviter.avatar nickname:liveStartData.inviter.nickname status:_liveStatus];
    }
    
    // pk状态栏变更
    [self _layoutPkStatusBarWithStatus:_liveStatus];
    // pk开始: 启动倒计时,刷新内容
    int32_t countdown = kPkLiveTotalTime - (int32_t)((liveStartData.sendTime - liveStartData.pkStartTime) / 1000);
    [self.pkStatusBar countdownWithSeconds:countdown prefix:@"PK "];
    [self.pkStatusBar refreshWithLeftRewardCoins:0 leftRewardAvatars:@[] rightRewardCoins:0 rightRewardAvatars:@[]];
    
}

//开始惩罚
- (void)receivePunishStartAttachment:(NEStartPunishAttachment *)punishData {
    
    _liveStatus = NEPkliveStatusPunish;

    // 获取pk结果
    NETSPkResult res = NETSPkUnknownResult;
    if (punishData.inviteeRewards == punishData.inviterRewards) {
        res = NETSPkTieResult;
    }else if ((punishData.inviteeRewards > punishData.inviterRewards && self.pkRole == NETSPkServiceInvitee) ||
             (punishData.inviteeRewards < punishData.inviterRewards && self.pkRole == NETSPkServiceInviter)) {
        res = NETSPkCurrentAnchorWin;
    }else {
        res = NETSPkOtherAnchorWin;
    }
    
    if (res == NETSPkTieResult) {
        [self.pkStatusBar stopCountdown];
    } else {
        [self.pkStatusBar countdownWithSeconds:punishData.pkPenaltyCountDown prefix:@"惩罚 "];
    }
    //显示pk结果
    [self _layoutPkResultWhenGetCurrentAnchorWin:res];

}

- (void)receivePkEndAttachment:(NEPkEndAttachment *)pkEndData {
    _liveStatus = NEPkliveStatusPkEnd;
    [self.pkStatusBar stopCountdown];
    [self.pkStatusBar removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeRoomStatus:)]) {
        ntes_main_async_safe(^{
            [self.delegate didChangeRoomStatus:NETSAudienceStreamDefault];
        });
    }
    [self _layoutPkResultWhenPunishmentEnd];
}


//打赏消息
- (void)receivePkRewardAttachment:(NEPkRewardAttachment *)rewardData {
    
    if (_liveStatus == NEPkliveStatusPkLiving) {//只有pk阶段才更新分值条
        // pk状态栏变更
        [self.pkStatusBar refreshWithLeftRewardCoins:rewardData.anchorReward.pkRewardTotal
                                   leftRewardAvatars:[rewardData.anchorReward rewardAvatars]
                                    rightRewardCoins:rewardData.otherAnchorReward.pkRewardTotal
                                  rightRewardAvatars:[rewardData.otherAnchorReward rewardAvatars]];
    }
   

    // 更新主播云币值
    self.anchorInfo.wealth = rewardData.anchorReward.rewardTotal;

    // 展示礼物动画
    NETSGiftModel *giftModel = [NETSLiveUtils getRewardWithGiftId:rewardData.giftId];
    if (giftModel) {
        NSString *giftName = [NSString stringWithFormat:@"anim_gift_0%lld",rewardData.giftId];
        [self _playGiftWithName:giftName];
    }
    
    NIMCustomObject *object = [[NIMCustomObject alloc] init];
    object.attachment = rewardData;
    NIMMessage *msg = [[NIMMessage alloc] init];
    msg.messageObject = object;
    
    // 聊天室增加打赏信息
    [self.chatView addMessages:@[msg]];
    
}
/// 收到文本消息
-(void)onRecvRoomTextMsg:(NSArray<NIMMessage *> *)messages {
    
    NIMMessage *message = messages.firstObject;
    if (![message.session.sessionId isEqualToString:_room.live.chatRoomId]) {
        return;
    }
    [self.chatView addMessages:messages];
}

/// 直播间关闭
- (void)_liveRoomClosed
{
    // 关闭计时器
    [self.timer invalidate];
    
    // 调用代理
    if (_delegate && [_delegate respondsToSelector:@selector(didLiveRoomClosed)]) {
        [_delegate didLiveRoomClosed];
    }
    self.chatRoomAvailable = NO;
}

#pragma mark - NESeatServiceDelegate
//主播同意了观众的连麦申请
- (void)onSeatApplyAccepted:(NESeatApplyAcceptEvent *)event {
    self.bottomBar.buttonType = NETSAudienceBottomRequestTypeAccept;
    //取消观众申请连麦的bar
    [self.requestConnectMicBar dismiss];
    //防止复用问题
    if ([event.respondor.accountId isEqualToString:self.room.anchor.accountId]) {//操作主播和当前房间主播的id要一致
        [self joinChannelWithData:event.avRoomUser];//加入频道
    }
}

//主播拒绝观众的连麦申请
- (void)onSeatApplyRejected:(NESeatApplyRejectEvent *)event {
    [NETSAlertPrompt showAlert:UIAlertControllerStyleAlert title:NSLocalizedString(@"主播拒绝了你的连麦申请", nil) message:@"" actionArr:@[NSLocalizedString(@"我知道了", nil)] actionColors:@[HEXCOLOR(0x007AFF)] cancel:nil index:^(NSInteger index) {} presentVc:[NETSUniversalTool getCurrentActivityViewController]];
    //恢复按钮正常状态
    self.bottomBar.buttonType = NETSAudienceBottomRequestTypeNormal;
    //取消观众申请连麦的bar
    [self.requestConnectMicBar dismiss];
}


- (void)onSeatPickRequest:(NESeatPickRequestEvent *)event {
    
    //rtc delegate强引用导致观众控制器无法释放，这里需做去重判断，弹窗避免弹两次
    [NETSAlertPrompt showAlert:UIAlertControllerStyleAlert title:NSLocalizedString(@"邀请上麦", nil) message:NSLocalizedString(@"主播邀请你上麦", nil) actionArr:@[NSLocalizedString(@"拒绝", nil),NSLocalizedString(@"上麦", nil)] actionColors:@[HEXCOLOR(0x666666),HEXCOLOR(0x007AFF)] cancel:nil index:^(NSInteger index) {
        if (index == 1) {
            NERejectSeatPickParams *params = [[NERejectSeatPickParams alloc]init];
            [[NELiveRoom sharedInstance].seatService rejectSeatPick:params completion:^(NSError * _Nullable error) {
                if (error) {
                    YXAlogError(@"audience rejectSeatPick failed,error = %@",error);
                }else {
                    YXAlogInfo(@"acaudience rejectSeatPick success");
                }
            }];
            
        }else {
            NEAcceptSeatPickParams *params = [[NEAcceptSeatPickParams alloc]init];
            [[NELiveRoom sharedInstance].seatService acceptSeatPick:params completion:^(NSError * _Nullable error) {
                if (error) {
                    [NETSToast showToast:NSLocalizedString(@"观众同意上麦失败", nil)];
                    YXAlogError(@"audience acceptSeatPick failed,error = %@",error);
                }else {
                    [self joinChannelWithData:event.avRoomUser];//加入频道
                    YXAlogInfo(@"acaudience acceptSeatPick success");
                }
            }];
        }
    } presentVc:[NETSUniversalTool getCurrentActivityViewController]];
}

-(void)onSeatPickAccepted:(NESeatPickAcceptEvent *)event {
    
}

-(void)onSeatEntered:(NESeatEnterEvent *)event {

    event.seatInfo.avRoomUid = event.avRoomUser.avRoomUid.longLongValue;
    if (self.delegate && [self.delegate respondsToSelector:@selector(memberSeatStateChanged:seatInfo:)]) {
        [self.delegate memberSeatStateChanged:YES seatInfo:event.seatInfo];
    }
    
    if ([event.seatInfo.userInfo.accountId isEqualToString:[NEAccount shared].userModel.accountId]) {//是自己在记录时间
        [[NSUserDefaults standardUserDefaults]setObject:@(NSDate.date.timeIntervalSince1970).stringValue forKey:NTESConnectStartTimeKey];//记录上麦开始时间
        [[NSUserDefaults standardUserDefaults]synchronize];
        self.bottomBar.buttonType = NETSAudienceBottomRequestTypeAccept;
        if (_requestConnectMicBar) {
            [self.requestConnectMicBar dismiss];
        }
    }
    NIMMessage *message = [[NIMMessage alloc] init];
    message.text = [NSString stringWithFormat:@"\"%@\" 成功上麦", event.seatInfo.userInfo.userName];
    message.remoteExt = @{@"type":@(1)};
    [_chatView addMessages:@[message]];
}

- (void)onSeatLeft:(NESeatLeaveEvent *)event {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(memberSeatStateChanged:seatInfo:)]) {
        [self.delegate memberSeatStateChanged:NO seatInfo:event.seatInfo];
    }
    NIMMessage *message = [[NIMMessage alloc] init];
    message.text = [NSString stringWithFormat:@"\"%@\" 成功下麦", event.seatInfo.userInfo.userName];
    message.remoteExt = @{@"type":@(1)};
    [_chatView addMessages:@[message]];
    if ([event.seatInfo.userInfo.accountId isEqualToString:[NEAccount shared].userModel.accountId]) {//如果操作是自己重置麦克风和摄像头状态
        self.isJoinedRtc = NO;
        NETSRtcConfig.sharedConfig.cameraOn = YES;
        NETSRtcConfig.sharedConfig.micOn = YES;
        self.bottomBar.buttonType = NETSAudienceBottomRequestTypeNormal;
        if (event.reason == NESeatInfoChangeReasonKickout) {
            [NETSToast showToast:NSLocalizedString(@"您已被主播踢下麦位", nil)];
        }
    }
}

- (void)onSeatAudioStateChanged:(NESeatAudioStateChangeEvent *)event {
    
    NESeatAudioState audioState = event.seatInfo.audioState;
    BOOL micOn = event.seatInfo.audioState == NESeatAudioStateOpen ? YES : NO;
    if ([event.seatInfo.userInfo.accountId isEqualToString:[NEAccount shared].userModel.accountId]
        && [event.responder.accountId isEqualToString:self.room.anchor.accountId]) {//操作者是主播 被操作者是自己
        if (audioState == NESeatAudioStateClosed) {
            [NETSToast showToast:NSLocalizedString(@"主播关闭了你的麦克风", nil)];
        }else if (audioState == NESeatAudioStateOpen) {
            [NETSToast showToast:NSLocalizedString(@"主播打开了你的麦克风", nil)];
        }
        [NETSRtcConfig sharedConfig].micOn = micOn;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didAudioChanged:)]) {
        [self.delegate didAudioChanged:event.seatInfo];
    }
}

- (void)onSeatVideoStateChanged:(NESeatVideoStateChangeEvent *)event {

    NESeatVideoState videoState = event.seatInfo.videoState;
    BOOL cameraOn = event.seatInfo.videoState == NESeatVideoStateOpen ? YES : NO;
    if ([event.seatInfo.userInfo.accountId isEqualToString:[NEAccount shared].userModel.accountId]
        && [event.responder.accountId isEqualToString:self.room.anchor.accountId]) {//操作者是主播 被操作者是自己
        if (videoState == NESeatVideoStateClosed) {
            [NETSToast showToast:NSLocalizedString(@"主播关闭了你的摄像头", nil)];
        }else if (videoState == NESeatVideoStateOpen) {
            [NETSToast showToast:NSLocalizedString(@"主播打开了你的摄像头", nil)];
        }
        [NETSRtcConfig sharedConfig].cameraOn = cameraOn;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didVideoChanged:)]) {
        [self.delegate didVideoChanged:event.seatInfo];
    }
}

- (void)onSeatStateChanged:(NESeatStateChangeEvent *)event {
    if (event.reason == NESeatInfoChangeReasonTimeout) {
        if (_requestConnectMicBar) {
            self.bottomBar.buttonType = NETSAudienceBottomRequestTypeNormal;
            [self.requestConnectMicBar dismiss];
        }
    }
}

#pragma mark - NETSAudienceBottomBarDelegate 底部工具条代理

- (void)clickTextLabel:(UILabel *)label
{
    YXAlogInfo(@"点击输入框");
    [self.toolBar becomeFirstResponse];
}

- (void)clickGiftBtn
{
    YXAlogInfo(@"点击礼物");
    NSArray *gifts = [NETSLiveConfig shared].gifts;
    [NETSAudienceSendGiftSheet showWithTarget:self gifts:gifts];
    
}

- (void)clickCloseBtn {
    YXAlogInfo(@"退出直播间");
    if (self.bottomBar.buttonType == NETSAudienceBottomRequestTypeAccept) {//进入rtc房间才做离开操作
        [[NERtcEngine sharedEngine] leaveChannel];//离开rtc房间
    }
    if (_requestConnectMicBar) {
        [self.requestConnectMicBar dismiss];
    }
    
    [self _liveRoomClosed];
    [NETSChatroomService exitWithRoomId:_room.live.chatRoomId];
    [[NENavigator shared].navigationController popViewControllerAnimated:YES];
}

- (void)clickRequestConnect:(NETSAudienceBottomRequestType)requestType {
    
    __weak __typeof(self)weakSelf = self;
    switch (requestType) {
        case NETSAudienceBottomRequestTypeNormal:{
            self.bottomBar.buttonType = NETSAudienceBottomRequestTypeApplying;
            // 请求上麦
            NEApplySeatParams *params = [[NEApplySeatParams alloc]init];
            [[NELiveRoom sharedInstance].seatService applySeat:params completion:^(NESeatApplyResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    ntes_main_sync_safe(^{
                        [NETSToast showToast:error.userInfo[@"NSLocalizedDescription"]];
                        weakSelf.bottomBar.buttonType = NETSAudienceBottomRequestTypeApplying;
                        YXAlogError(@"applySeat failed,error = %@",error.description);
                    });
                }else {
                    ntes_main_sync_safe(^{
                        YXAlogInfo(@"applySeat success");
                        weakSelf.requestConnectMicBar = [NETSInvitingBar showInvitingWithTarget:self title:NSLocalizedString(@"等待主播接受连麦申请…", nil)];
                    });
                }
            }];
        }
            break;
        case NETSAudienceBottomRequestTypeApplying:{
            
        }
            break;
        case NETSAudienceBottomRequestTypeAccept:{
            NETSConnectStatusViewController *statusCtrl = [[NETSConnectStatusViewController alloc]init];
            statusCtrl.delegate = self;
            NTESActionSheetNavigationController *nav = [[NTESActionSheetNavigationController alloc] initWithRootViewController:statusCtrl];
            nav.dismissOnTouchOutside = YES;
            [[NENavigator shared].navigationController presentViewController:nav animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark -  NETSInvitingBarDelegate 请求上麦状态条代理事件

- (void)clickCancelInviting:(NETSInviteBarType)barType {
    //观众取消请求上麦
    if (self.isJoinedRtc) {
        return;
    }
    NECancelSeatApplyParams *params = [[NECancelSeatApplyParams alloc]init];
    [[NELiveRoom sharedInstance].seatService cancelSeatApply:params completion:^(NSError * _Nullable error) {
        if (error) {
            YXAlogError(@"cancelSeatApply failed, error = %@",error.description);
        }else {
            ntes_main_sync_safe(^{
                self.bottomBar.buttonType = NETSAudienceBottomRequestTypeNormal;
                [self.requestConnectMicBar dismiss];
            });
        }
    }];
}


#pragma mark -  NETSAudienceSendGiftSheetDelegate 打赏面板代理事件

- (void)didSendGift:(NETSGiftModel *)gift onSheet:(NETSAudienceSendGiftSheet *)sheet
{
    [sheet dismiss];
    
    if (isEmptyString(_room.anchor.accountId) || isEmptyString(_room.live.roomCid)) {
        YXAlogInfo(@"观众打赏参数错误 Error");
        return;
    }
    NEPkRewardParams *params = [[NEPkRewardParams alloc]init];
    params.roomId = self.room.live.roomId;
    params.giftId = gift.giftId;
    [self.apiService requestRewardLiveRoomWithParams:params successBlock:^(NSDictionary * _Nonnull response) {
        YXAlogInfo(@"andience reward success");
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogError(@"andience reward failed,error = %@",error);
    }];

}

#pragma mark - NETSKeyboardToolbarDelegate

- (void)didToolBarSendText:(NSString *)text
{
    if (isEmptyString(text)) {
        [NETSToast showToast:NSLocalizedString(@"消息内容为空", nil)];
        return;
    }

    NSString *roomId = self.room.live.chatRoomId;
    NSString *nickname = self.room.anchor.nickname;
    NSError *error = nil;
    [NETSChatroomService sendMessage:text inRoomId:roomId userMode:NETSUserModeAudience nickname:nickname errorPtr:&error];
    if (error) {
        YXAlogInfo(@"观众端发送消息失败: %@", error);
    }

}

// 关闭直播间
- (void)closeChatRoom {
    [self _liveRoomClosed];
}

- (void)closeConnectMicRoom {
    
    if (_requestConnectMicBar) {
        [self.requestConnectMicBar dismiss];
    }
    [[NENavigator shared].navigationController dismissViewControllerAnimated:YES completion:nil];

}

- (void)setUpBottomBarButtonType:(NETSAudienceBottomRequestType)buttonType {
    self.bottomBar.buttonType = buttonType;
    if (_requestConnectMicBar) {
        [self.requestConnectMicBar dismiss];
    }
}


#pragma mark - NTESAudienceConnectStatusDelegate
 //设置麦克风开关
- (void)didSetMicOn:(BOOL)micOn {

    NESetSeatAudioStateParams *params = [[NESetSeatAudioStateParams alloc]init];
    params.userId = [NEAccount shared].userModel.accountId;
    params.state = micOn ? NESeatAudioStateOpen:NESeatAudioStateClosed;
    [[NELiveRoom sharedInstance].seatService setSeatAudioState:params completion:^(NSError * _Nullable error) {
        if (error) {
            YXAlogError(@"anchor setSeatAudioState failed,error = %@",error);
        }else {
            [NETSRtcConfig sharedConfig].micOn = micOn;
            YXAlogInfo(@"anchor setSeatAudioState success");
        }
    }];
    
}

//设置摄像头开关
- (void)didSetVideoOn:(BOOL)videoOn {

    NESetSeatVideoStateParams *params = [[NESetSeatVideoStateParams alloc]init];
    params.userId = [NEAccount shared].userModel.accountId;
    params.state = videoOn ? NESeatVideoStateOpen : NESeatVideoStateClosed;
    [[NELiveRoom sharedInstance].seatService setSeatVideoState:params completion:^(NSError * _Nullable error) {
        if (error) {
            YXAlogError(@"connector setSeatVideoState failed,error = %@",error);
        }else {
            [NETSRtcConfig sharedConfig].cameraOn = videoOn;
            YXAlogInfo(@"connector setSeatVideoState success");
        }
    }];
}

//挂断（下麦）
- (void)didResignSeats {
    NELeaveSeatParams *params = [[NELeaveSeatParams alloc]init];
    [[NELiveRoom sharedInstance].seatService leaveSeat:params completion:^(NSError * _Nullable error) {
        if (error) {
            YXAlogError(@"connector leave seat failed,error = %@",error);
        }else {
            YXAlogInfo(@"connector leave seat success");
        }
    }];
}


#pragma mark - lazy load

- (NETSAnchorTopInfoView *)anchorInfo
{
    if (!_anchorInfo) {
        _anchorInfo = [[NETSAnchorTopInfoView alloc] init];
    }
    return _anchorInfo;
}

- (NETSAudienceNum *)audienceInfo
{
    if (!_audienceInfo) {
        _audienceInfo = [[NETSAudienceNum alloc] initWithFrame:CGRectZero];
    }
    return _audienceInfo;
}

- (NETSLiveChatView *)chatView
{
    if (!_chatView) {
        CGRect frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - 204, kScreenWidth - 16 - 60 - 20, 204);
        _chatView = [[NETSLiveChatView alloc] initWithFrame:frame];
    }
    return _chatView;
}

- (NETSAudienceBottomBar *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [[NETSAudienceBottomBar alloc] init];
        _bottomBar.delegate = self;
    }
    return _bottomBar;
}

- (NTESKeyboardToolbarView *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[NTESKeyboardToolbarView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 50)];
        _toolBar.backgroundColor = UIColor.whiteColor;
        _toolBar.cusDelegate = self;
    }
    return _toolBar;
}

- (NETSPkStatusBar *)pkStatusBar
{
    if (!_pkStatusBar) {
        _pkStatusBar = [[NETSPkStatusBar alloc] init];
    }
    return _pkStatusBar;
}

- (NETSInviteeInfoView *)inviteeInfo
{
    if (!_inviteeInfo) {
        _inviteeInfo = [[NETSInviteeInfoView alloc] init];
    }
    return _inviteeInfo;
}

- (UIImageView *)pkSuccessIco
{
    if (!_pkSuccessIco) {
        _pkSuccessIco = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    return _pkSuccessIco;
}

- (UIImageView *)pkFailedIco
{
    if (!_pkFailedIco) {
        _pkFailedIco = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    return _pkFailedIco;
}

- (NETSGiftAnimationView *)giftAnimation
{
    if (!_giftAnimation) {
        _giftAnimation = [[NETSGiftAnimationView alloc] init];
    }
    return _giftAnimation;
}

-(NEPkRoomApiService *)apiService {
    if (!_apiService) {
        _apiService = [[NEPkRoomApiService alloc]init];
    }
    return _apiService;
}

- (NEPkChatroomMsgHandle *)chatHandle {
    if (!_chatHandle) {
        _chatHandle = [[NEPkChatroomMsgHandle alloc]init];
        _chatHandle.delegate  = self;
    }
    return _chatHandle;
}
@end
