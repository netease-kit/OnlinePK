//
//  NETSAudienceMask.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/25.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSGiftAnimationView.h"
#import "NETSInvitingBar.h"
#import "LOTAnimationView.h"
#import "NETSInviteeInfoView.h"
#import "NTESKeyboardToolbarView.h"
#import "NETSToast.h"
#import "NETSPkStatusBar.h"
#import "NETSLiveChatView.h"
#import "NETSAudienceSendGiftSheet.h"
#import "NETSMoreSettingActionSheet.h"
#import "NETSAudienceMask.h"
#import "NETSAnchorTopInfoView.h"
#import "TopmostView.h"
#import "NETSAudienceBottomBar.h"

#import "NETSConnectStatusViewController.h"
#import "NTESActionSheetNavigationController.h"

#import "NETSConnectMicService.h"
#import "NETSAudienceChatroomMessageHandle.h"
#import <NELivePlayerFramework/NELivePlayerNotication.h>
#import "NETSGCDTimer.h"
#import "NETSLiveUtils.h"
#import "NETSChatroomService.h"
#import "NETSLiveAttachment.h"
#import "NETSLiveApi.h"
#import "NENavigator.h"
#import "NETSAudienceNum.h"
#import "NETSLiveChatViewHandle.h"
#import "NETSAudienceVM.h"
#import "NETSLiveConfig.h"
#import "NETSLiveAttachment.h"
#import "NETSConnectMicModel.h"

#define kPkAudienceTimerQueue            "com.netease.pk.audience.timer.queue"

@interface NETSAudienceMask ()
<
    NETSLiveChatViewHandleDelegate,
    NETSAudienceBottomBarDelegate,
    NETSAudienceSendGiftSheetDelegate,
    NTESKeyboardToolbarDelegate,
    NETSInvitingBarDelegate,
    NETSConnectMicServiceDelegate,
    NTESAudienceConnectStatusDelegate,
    NETSAudienceChatroomMessageHandleDelegate

>

/// 主播信息
@property (nonatomic, strong)   NETSAnchorTopInfoView   *anchorInfo;
/// 直播中 观众数量视图
@property (nonatomic, strong)   NETSAudienceNum         *audienceInfo;
/// 聊天视图
@property (nonatomic, strong)   NETSLiveChatView        *chatView;
/// 聊天室代理
@property (nonatomic, strong)   NETSLiveChatViewHandle  *chatHandle;
//观众的聊天室代理
@property (nonatomic, strong)   NETSAudienceChatroomMessageHandle  *audienceMessageHandle;

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
/// 获取PK左侧打赏榜单信号
@property (nonatomic, strong)   RACSubject      *leftPkRewardSubject;
/// 获取PK右侧打赏榜单信号
@property (nonatomic, strong)   RACSubject      *rightPkRewardSubject;
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
@property (nonatomic, assign)   NETSRoomLiveStatus      liveStatus;
//观众请求连麦状态条
@property(nonatomic, strong) NETSInvitingBar *requestConnectMicBar;
//处理透传消息类
@property(nonatomic, strong) NETSConnectMicService *connectMicService;
@end

@implementation NETSAudienceMask

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _chatHandle = [[NETSLiveChatViewHandle alloc] initWithDelegate:self];
        _audienceMessageHandle = [[NETSAudienceChatroomMessageHandle alloc] init];
        _audienceMessageHandle.delegate = self;
        [[NIMSDK sharedSDK].passThroughManager addDelegate:self.connectMicService];
        [[NIMSDK sharedSDK].chatManager addDelegate:_chatHandle];
        [[NIMSDK sharedSDK].chatroomManager addDelegate:_chatHandle];
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:_chatHandle];
        
        [[NIMSDK sharedSDK].chatManager addDelegate:_audienceMessageHandle];
        
        [self addSubview:self.anchorInfo];
        [self addSubview:self.audienceInfo];
        [self addSubview:self.chatView];
        [self addSubview:self.bottomBar];
        [self addSubview:self.toolBar];
        [self bringSubviewToFront:self.toolBar];
        
        _leftPkRewardSubject = [RACSubject subject];
        _rightPkRewardSubject = [RACSubject subject];
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
    [[NIMSDK sharedSDK].chatManager removeDelegate:_chatHandle];
    [[NIMSDK sharedSDK].chatroomManager removeDelegate:_chatHandle];
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:_chatHandle];
    [[NIMSDK sharedSDK].chatManager removeDelegate:_audienceMessageHandle];
    [[NIMSDK sharedSDK].passThroughManager removeDelegate:_connectMicService];
    YXAlogInfo(@"dealloc NETSAudienceMask: %p", self);
}

- (void)_bindEvent
{
    @weakify(self);
    RACSignal *roomSignal = RACObserve(self, room);
    [roomSignal subscribeNext:^(NETSLiveRoomModel *x) {
        @strongify(self);
        if (x == nil) { return; }
        self.chatHandle.roomId = x.chatRoomId;
        self.audienceMessageHandle.roomId = x.chatRoomId;
        [self _refreshAudienceInfoWitHRoomId:x.chatRoomId];
        self.anchorInfo.nickname = x.nickname;
        self.anchorInfo.avatarUrl = x.avatar;
    }];
    
    [[roomSignal zipWith:RACObserve(self, info)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        NETSLiveRoomModel *room = (NETSLiveRoomModel *)tuple.first;
        NETSLiveRoomInfoModel *info = (NETSLiveRoomInfoModel *)tuple.second;
        if (room && info) {
            // 更新主播云币
            self.anchorInfo.wealth = info.coinTotal;
            // 刷新直播间
            [self refreshWithRoom:room info:info];
        }
    }];
    
    // pk左右榜单请求结果信号
    RACSignal *signal = [self.leftPkRewardSubject zipWith:self.rightPkRewardSubject];
    [signal subscribeNext:^(RACTuple *tuple) {
        NETSPkLiveContriList *leftData = (NETSPkLiveContriList *)tuple.first;
        NETSPkLiveContriList *rightData = (NETSPkLiveContriList *)tuple.second;
        ntes_main_async_safe(^{
            @strongify(self);
            [self.pkStatusBar refreshWithLeftRewardCoins:leftData.rewardCoinTotal
                                       leftRewardAvatars:leftData.rewardAvatars
                                        rightRewardCoins:rightData.rewardCoinTotal
                                      rightRewardAvatars:rightData.rewardAvatars];
        });
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

- (void)setRoom:(NETSLiveRoomModel *)room
{
    _room = room;
    self.connectMicService.roomModel = room;
}

- (void)refreshWithRoom:(NETSLiveRoomModel *)room info:(NETSLiveRoomInfoModel *)info
{
    _liveStatus = NETSRoomLiving;
    if (info.pkRecord) {
        _liveStatus = info.pkRecord.status;
    }
    
    if (_liveStatus == NETSRoomPKing || _liveStatus == NETSRoomPunishment) {
        // 布局PK状态栏
        [self _layoutPkStatusBarWithStatus:info.status];
        // 启动PK倒计时
        int32_t totalTime = kPkLiveTotalTime;
        int64_t startTime = info.pkRecord.pkStartTime;
        NSString *prefix = @"PK ";
        if (_liveStatus == NETSRoomPunishment) {
            totalTime = kPkLivePunishTotalTime;
            startTime = info.pkRecord.punishmentStartTime;
            prefix = @"惩罚 ";
        }
        int32_t countdown = totalTime - (int32_t)((info.pkRecord.currentTime - startTime) / 1000);
        [self.pkStatusBar countdownWithSeconds:countdown prefix:prefix];
        
        // 获取PK榜打赏信息
        @weakify(self);
        [self _fetchRewardListWithLiveCid:room.liveCid anchorAccountId:room.accountId successBlock:^(NETSPkLiveContriList *list) {
            @strongify(self);
            [self.leftPkRewardSubject sendNext:list];
        } failedBlock:nil];
        
        NSString *rightCid = info.pkRecord.inviterLiveCid;
        NSString *rightAcid = info.pkRecord.inviter;
        if ([room.liveCid isEqualToString:info.pkRecord.inviterLiveCid]) {
            rightCid = info.pkRecord.inviteeLiveCid;
            rightAcid = info.pkRecord.invitee;
        }
        [self _fetchRewardListWithLiveCid:rightCid anchorAccountId:rightAcid successBlock:^(NETSPkLiveContriList *list) {
            @strongify(self);
            [self.rightPkRewardSubject sendNext:list];
        } failedBlock:nil];
        
        // 布局PK被邀请者信息视图
        if ([info.members count] > 1) {
            NETSLiveRoomModel *obj = [info.members firstObject];
            for (NETSLiveRoomModel *item in info.members) {
                if (![item.chatRoomCreator isEqualToString:room.chatRoomCreator]) {
                    obj = item;
                    break;
                }
            }
            [self _layoutOtherAnchorWithAvatar:obj.avatar nickname:obj.nickname status:info.status];
        }
        
        // 惩罚态获取胜负信息
        if (_liveStatus == NETSRoomPunishment) {
            // 默认当前主播为邀请者
            int currentAuthorWinValue = 0;//默认是平局
            if (info.pkRecord.inviterRewards > info.pkRecord.inviteeRewards) {
                currentAuthorWinValue = 1;
            }else if(info.pkRecord.inviterRewards < info.pkRecord.inviteeRewards){
                currentAuthorWinValue = -1;
            }
            
            if ([_room.liveCid isEqualToString:info.pkRecord.inviteeLiveCid]) {
                // 当前主播为被邀请者
                if (info.pkRecord.inviteeRewards > info.pkRecord.inviterRewards) {
                    currentAuthorWinValue = 1;
                }else if(info.pkRecord.inviteeRewards < info.pkRecord.inviterRewards){
                    currentAuthorWinValue = -1;
                }
            }
            [self _layoutPkResultWhenGetCurrentAnchorWin:currentAuthorWinValue];
        }
        
        // 设定播放器偏移
        if (_delegate && [_delegate respondsToSelector:@selector(didChangeRoomStatus:)]) {
            [_delegate didChangeRoomStatus:info.status];
        }
    } else {
        [self.inviteeInfo removeFromSuperview];
        [self.pkStatusBar removeFromSuperview];
        [self.pkSuccessIco removeFromSuperview];
        [self.pkFailedIco removeFromSuperview];
    }
}

#pragma mark - setter/getter

- (void)setRoomStatus:(NETSAudienceRoomStatus)roomStatus
{
    _roomStatus = roomStatus;
    if (roomStatus != NETSAudienceRoomPlaying) {
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
- (void)_layoutOtherAnchorWithAvatar:(NSString *)avatar nickname:(NSString *)nickname status:(NETSRoomLiveStatus)status
{
    if (_roomStatus == NETSAudienceRoomLiveClosed || _room == NETSAudienceRoomLiveError) { return; }
    if (status == NETSRoomPKing || status == NETSRoomPunishment)  {
        CGFloat topOffset = 72 + (kIsFullScreen ? 44 : 20);
        self.inviteeInfo.frame = CGRectMake(self.right - 8 - 82, topOffset, 82, 24);
        [self.inviteeInfo reloadAvatar:avatar nickname:nickname];
        [self addSubview:self.inviteeInfo];
    } else {
        [self.inviteeInfo removeFromSuperview];
    }
}

/// 布局pk状态条
- (void)_layoutPkStatusBarWithStatus:(NETSRoomLiveStatus)status
{
    if (_roomStatus == NETSAudienceRoomLiveClosed || _room == NETSAudienceRoomLiveError) { return; }
    if (status == NETSRoomPKing || status == NETSRoomPunishment) {
        CGFloat topOffset = (kIsFullScreen ? 44 : 20) + 44 + 20 + kScreenWidth * 640 / 720.0;
        CGRect rect = CGRectMake(0, topOffset, self.width, 58);
        self.pkStatusBar.frame = rect;
        [self addSubview:self.pkStatusBar];
        
        [self bringSubviewToFront:self.pkStatusBar];
        [self bringSubviewToFront:self.toolBar];
    }
}

/// 布局胜负标志: pk阶段结束,返回pk结果
- (void)_layoutPkResultWhenGetCurrentAnchorWin:(int32_t)currentAnchorWin
{
    if (_roomStatus == NETSAudienceRoomLiveClosed || _roomStatus == NETSAudienceRoomLiveError) { return; }
    
    CGFloat top = 64 + (kIsFullScreen ? 44 : 20) + kScreenWidth * 0.5 * 640 / 360.0 - 100;
    CGRect leftIcoFrame = CGRectMake((kScreenWidth * 0.5 - 100) * 0.5, top, 100, 100);
    CGRect rightIcoFrame = CGRectMake(kScreenWidth * 0.5 + (kScreenWidth * 0.5 - 100) * 0.5, top, 100, 100);
    
    self.pkSuccessIco.image = [UIImage imageNamed:@"pk_succeed_ico"];
    self.pkFailedIco.image = [UIImage imageNamed:@"pk_failed_ico"];
    
    switch (currentAnchorWin) {
        case 1:
        {
            self.pkSuccessIco.frame = leftIcoFrame;
            self.pkFailedIco.frame = rightIcoFrame;
        }
            break;
        case -1:
        {
            self.pkSuccessIco.frame = rightIcoFrame;
            self.pkFailedIco.frame = leftIcoFrame;
        }
            break;
        case 0:
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

/// 主播进/出直播间操作
- (void)_didAuthorEnterLiveRoom:(BOOL)enter userId:(NSString *)userId
{
    if (![userId isEqualToString:_room.imAccid]) { return; }
    if (enter) {
        [self.timer invalidate];
        YXAlogInfo(@"主播进入直播间,清除计时器");
    } else {
        @weakify(self);
        self.timer = [NETSGCDTimer scheduledTimerWithTimeInterval:25 repeats:NO queue:self.timerQueue triggerImmediately:NO block:^{
            @strongify(self);
            [self _liveRoomClosed];
        }];
        YXAlogInfo(@"主播离开直播间,设定超时离开");
    }
}

/// 播放礼物动画
- (void)_playGiftWithName:(NSString *)name
{
    [self addSubview:self.giftAnimation];
    [self bringSubviewToFront:self.giftAnimation];
    [self.giftAnimation addGift:name];
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

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    CGFloat chatViewHeight = [self _chatViewHeight];
    [UIView animateWithDuration:0.1 animations:^{
        self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
        self.toolBar.frame = CGRectMake(0, kScreenHeight + 50, kScreenWidth, 50);
    }];
}

/// 刷新观众信息
- (void)_refreshAudienceInfoWitHRoomId:(NSString *)roomId
{
    [NETSChatroomService fetchMembersRoomId:self.room.chatRoomId limit:10 successBlock:^(NSArray<NIMChatroomMember *> * _Nullable members) {
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

#pragma mark - NETSLiveChatViewHandleDelegate 聊天室代理

/// 进入或离开房间
- (void)didChatroomMember:(NIMChatroomNotificationMember *)member enter:(BOOL)enter sessionId:(NSString *)sessionId
{
    if (![sessionId isEqualToString:_room.chatRoomId]) {
        return;
    }
    [self _didAuthorEnterLiveRoom:enter userId:member.userId];
    
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
    [self _refreshAudienceInfoWitHRoomId:_room.chatRoomId];
}

/// 直播间关闭
- (void)didChatroomClosedWithRoomId:(NSString *)roomId
{
    if (![roomId isEqualToString:_room.chatRoomId]) {
        return;
    }
    YXAlogInfo(@"聊天室关闭");
    [self _liveRoomClosed];
}

- (void)didChatroomKickWithRoomId:(NSString *)roomId {
    if (![roomId isEqualToString:_room.chatRoomId]) {
        return;
    }
    [NETSAlertPrompt showAlert:UIAlertControllerStyleAlert title:@"已被其他设备踢出" message:@"暂不支持多台设备进入同一直播间，\n您可以去其他直播间转转～" actionArr:@[@"确定"] actionColors:@[HEXCOLOR(0x007AFF)] cancel:nil index:^(NSInteger index) {
        if (index) {
            [self clickCloseBtn];
        }
    } presentVc:[NETSUniversalTool getCurrentActivityViewController]];
    
}
/// 聊天室收到PK消息
- (void)didReceivedPKMessage:(NIMMessage *)message
{
    if (![message.session.sessionId isEqualToString:_room.chatRoomId]) {
        return;
    }
    NETSLivePKAttachment *attch = [NETSLivePKAttachment getAttachmentWithMessage:message];
    if (attch.type != NETSLiveAttachmentPkType) {
        return;
    }
    YXAlogInfo(@"观众端 聊天室收到PK消息, status: %lu", (unsigned long)attch.state);
    
    if (attch.state == NETSLiveAttachmentStatusStart) {
        _liveStatus = NETSRoomPKing;
    }
    
    // pk开始:通知外围变更播放器frame
    if (attch.state == NETSLiveAttachmentStatusStart && self.delegate && [self.delegate respondsToSelector:@selector(didChangeRoomStatus:)]) {
        [self.delegate didChangeRoomStatus:NETSAudienceIMPkStart];
    }
    
    // pk第二主播信息载入
    [self _layoutOtherAnchorWithAvatar:attch.otherAnchorAvatar nickname:attch.otherAnchorNickname status:_liveStatus];
    // pk状态栏变更
    [self _layoutPkStatusBarWithStatus:_liveStatus];
    // pk开始: 启动倒计时,刷新内容
    if (attch.state == NETSLiveAttachmentStatusStart) {
        int32_t countdown = kPkLiveTotalTime - (int32_t)((attch.currentTimestamp - attch.startedTimestamp) / 1000);
        [self.pkStatusBar countdownWithSeconds:countdown prefix:@"PK "];
        [self.pkStatusBar refreshWithLeftRewardCoins:0 leftRewardAvatars:@[] rightRewardCoins:0 rightRewardAvatars:@[]];
    }
    // 显示pk结果
    if (attch.state == NETSLiveAttachmentStatusEnd) {
        [self _layoutPkResultWhenGetCurrentAnchorWin:attch.currentAnchorWin];
    }
}

/// 聊天室收到惩罚消息
- (void)didReceivedPunishMessage:(NIMMessage *)message
{
    if (![message.session.sessionId isEqualToString:_room.chatRoomId]) {
        return;
    }
    NETSLivePKAttachment *attch = [NETSLivePKAttachment getAttachmentWithMessage:message];
    if (attch.type != NETSLiveAttachmentPunishType) {
        return;
    }
    YXAlogInfo(@"观众端 聊天室收到惩罚消息, attch: %@", attch);
    // pk状态条
    if (attch.state == NETSLiveAttachmentStatusStart) {
        if (attch.currentAnchorWin == 0) {
            // 平局
            [self.pkStatusBar stopCountdown];
        } else {
            _liveStatus = NETSRoomPunishment;
            int32_t seconds = kPkLivePunishTotalTime - (int32_t)((attch.startedTimestamp - attch.currentTimestamp) / 1000);
            [self.pkStatusBar countdownWithSeconds:seconds prefix:@"惩罚 "];
        }
    } else {
        _liveStatus = NETSRoomPKEnd;
        
        [self.pkStatusBar stopCountdown];
        [self.pkStatusBar removeFromSuperview];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeRoomStatus:)]) {
            ntes_main_async_safe(^{
                [self.delegate didChangeRoomStatus:NETSAudienceStreamDefault];
            });
        }
    }
    // pk结束:通知外围变更播放器frame(因视频帧尺寸变化和信令可能有时差,取消该处操作)
//    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeRoomStatus:)] && attch.state == NETSLiveAttachmentStatusEnd) {
//        [self.delegate didChangeRoomStatus:NETSAudienceIMPkEnd];
//    }
    // 第二主播信息载入
    [self _layoutOtherAnchorWithAvatar:attch.otherAnchorAvatar nickname:attch.otherAnchorNickname status:_liveStatus];
    // 移除pk结果
    if (attch.state == NETSLiveAttachmentStatusEnd) {
        [self _layoutPkResultWhenPunishmentEnd];
    }
}

/// 收到主播发出的云币同步消息
- (void)didReceivedSyncWealthMessage:(NIMMessage *)message
{
    if (![message.session.sessionId isEqualToString:_room.chatRoomId]) {
        return;
    }
    YXAlogInfo(@"观众端 收到主播发出的云币同步消息");
    NETSLiveWealthChangeAttachment *attach = [NETSLiveWealthChangeAttachment getAttachmentWithMessage:message];
    
    // pk状态栏变更
    [self.pkStatusBar refreshWithLeftRewardCoins:attach.PKCoinCount
                               leftRewardAvatars:[attach originRewardAvatars]
                                rightRewardCoins:attach.otherPKCoinCount
                              rightRewardAvatars:[attach originOtherRewardAvatars]];
    
    // 更新主播云币值
    self.anchorInfo.wealth = attach.totalCoinCount;
    
    // 确认是给当前直播间打赏
    if ([attach.fromUserAvRoomUid isEqualToString:_room.roomUid]) {
        // 展示礼物动画
        NETSGiftModel *giftModel = [NETSLiveUtils getRewardWithGiftId:attach.giftId];
        if (giftModel) {
            NSString *giftName = [NSString stringWithFormat:@"anim_gift_0%d",giftModel.giftId];
            [self _playGiftWithName:giftName];
        }
        
        // 聊天室增加打赏信息
        [self.chatView addMessages:@[message]];
    }
}

/// 收到文本消息
- (void)didReceivedTextMessage:(NIMMessage *)message
{
    if (![message.session.sessionId isEqualToString:_room.chatRoomId]) {
        return;
    }
    YXAlogInfo(@"观众端 收到文本消息");
    [self.chatView addMessages:@[message]];
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

- (void)clickCloseBtn
{
    YXAlogInfo(@"退出直播间");
    if (self.bottomBar.buttonType == NETSAudienceBottomRequestTypeAccept) {//进入rtc房间才做离开操作
        [[NERtcEngine sharedEngine] leaveChannel];//离开rtc房间
    }
    if (_requestConnectMicBar) {
        [self.requestConnectMicBar dismiss];
    }
    // 关闭计时器
    [self.timer invalidate];
    [NETSChatroomService exitWithRoomId:_room.chatRoomId];
    [[NENavigator shared].navigationController popViewControllerAnimated:YES];

}

- (void)clickRequestConnect:(NETSAudienceBottomRequestType)requestType {
    switch (requestType) {
        case NETSAudienceBottomRequestTypeNormal:{
            self.bottomBar.buttonType = NETSAudienceBottomRequestTypeApplying;

            //请求上麦
            [NETSLiveApi requestSeatManagerWithRoomId:self.room.liveCid userId:[NEAccount shared].userModel.accountId index:1 action:NETSSeatsOperationAudienceApplyJoinSeats successBlock:^(NSDictionary * _Nonnull response) {
                self.requestConnectMicBar = [NETSInvitingBar showInvitingWithTarget:self title:@"等待主播接受连麦申请…"];
                
                YXAlogDebug(@"观众请求上麦成功，response = %@",response);
                } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
                    if (error) {
                        [NETSToast showToast:response[@"msg"]];
                    }
                    YXAlogError(@"观众请求上麦失败，error = %@",error.description);
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
    [NETSLiveApi requestSeatManagerWithRoomId:self.room.liveCid userId:[NEAccount shared].userModel.accountId index:1 action:NETSSeatsOperationAudienceCancelApplyJoinSeats successBlock:^(NSDictionary * _Nonnull response) {
        self.bottomBar.buttonType = NETSAudienceBottomRequestTypeNormal;
        [self.requestConnectMicBar dismiss];
        YXAlogDebug(@"观众取消上麦申请成功，response = %@",response);
        } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
            YXAlogError(@"观众取消上麦申请失败，error = %@",error.description);
    }];
 
}



#pragma mark -  NETSAudienceSendGiftSheetDelegate 打赏面板代理事件

- (void)didSendGift:(NETSGiftModel *)gift onSheet:(NETSAudienceSendGiftSheet *)sheet
{
    [sheet dismiss];
    
    if (isEmptyString(_room.accountId) || isEmptyString(_room.liveCid)) {
        YXAlogInfo(@"观众打赏参数错误 Error");
        return;
    }
    NETSLiveType type = NETSLiveTypeNormal;
    if (_liveStatus == NETSRoomPKing || _liveStatus == NETSRoomPunishment) {
        type = NETSLiveTypePK;
    }
    [NETSLiveApi rewardLiveCid:_room.liveCid liveType:type anchorAccountId:_room.accountId giftId:gift.giftId completionHandle:^(NSDictionary * _Nonnull response) {
        NSDictionary *res = response[@"/"];
        NSInteger code = [res[@"code"] integerValue];
        if (code != 200) {
            YXAlogInfo(@"观众打赏失败, Error: %ld", (long)code);
        }
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        if (error) {
            YXAlogInfo(@"观众打赏失败, Error: %@", error);
        }
    }];
}

#pragma mark - NETSKeyboardToolbarDelegate

- (void)didToolBarSendText:(NSString *)text
{
    if (isEmptyString(text)) {
        [NETSToast showToast:@"消息内容为空"];
        return;
    }
    NSString *roomId = self.room.chatRoomId;
    NSString *nickname = self.room.nickname;
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
}
#pragma mark - NETSConnectMicServiceDelegate
//主播同意观众申请上麦
-(void)adminAcceptJoinSeats {
    self.bottomBar.buttonType = NETSAudienceBottomRequestTypeAccept;
    //取消观众申请连麦的bar
    [self.requestConnectMicBar dismiss];
}

//主播拒绝观众申请上麦
- (void)adminRefuseAudienceApplyJoinSeats {
    //恢复按钮正常状态
    self.bottomBar.buttonType = NETSAudienceBottomRequestTypeNormal;
    //取消观众申请连麦的bar
    [self.requestConnectMicBar dismiss];
}

#pragma mark - NTESAudienceConnectStatusDelegate
 //设置麦克风开关
- (void)didSetMicOn:(BOOL)micOn {
    
    int isOpenAudio = micOn ? 1:0;
    [NETSLiveApi requestChangeSeatsStatusWithRoomId:self.room.liveCid userId:[NEAccount shared].userModel.accountId video:-1 audio:isOpenAudio successBlock:^(NSDictionary * _Nonnull response) {
        YXAlogInfo(@"连麦者操作麦克风成功,response = %@",response);
        [NETSRtcConfig sharedConfig].micOn = micOn;
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogInfo(@"连麦者操作麦克风失败,response = %@",response);
    }];
}

//设置摄像头开关
- (void)didSetVideoOn:(BOOL)videoOn {
    int isOpenVideo = videoOn ? 1:0;
    [NETSLiveApi requestChangeSeatsStatusWithRoomId:self.room.liveCid userId:[NEAccount shared].userModel.accountId video:isOpenVideo audio:-1 successBlock:^(NSDictionary * _Nonnull response) {
        YXAlogInfo(@"连麦者操作视屏成功,response = %@",response);
        [NETSRtcConfig sharedConfig].cameraOn = videoOn;
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogInfo(@"连麦者操作视屏失败,response = %@",response);
    }];
}

//挂断（下麦）
- (void)didResignSeats {
    [NETSLiveApi requestSeatManagerWithRoomId:self.room.liveCid userId:[NEAccount shared].userModel.accountId index:1 action:NETSSeatsOperationWheatherLeaveSeats successBlock:^(NSDictionary * _Nonnull response) {
        YXAlogDebug(@"上麦者下麦成功,response = %@",response);
    } failedBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        YXAlogError(@"上麦者下麦失败，error = %@",error.description);
    }];
}

#pragma mark - NETSAudienceChatroomMessageHandleDelegate
- (void)receivedAudienceConnectMicSuccess:(NETSConnectMicAttachment *)msgAttachment {
    
    if ([msgAttachment.member.accountId isEqualToString:[NEAccount shared].userModel.accountId]) {//是自己在记录时间
        [[NSUserDefaults standardUserDefaults]setObject:@(NSDate.date.timeIntervalSince1970).stringValue forKey:NTESConnectStartTimeKey];//记录上麦开始时间
        [[NSUserDefaults standardUserDefaults]synchronize];
        self.bottomBar.buttonType = NETSAudienceBottomRequestTypeAccept;
        if (_requestConnectMicBar) {
            [self.requestConnectMicBar dismiss];
        }
    }
    NIMMessage *message = [[NIMMessage alloc] init];
    message.text = [NSString stringWithFormat:@"\"%@\" 成功上麦", msgAttachment.member.nickName];
    message.remoteExt = @{@"type":@(1)};
    [_chatView addMessages:@[message]];
}


- (void)receivedAudienceLeaveMicSuccess:(NETSConnectMicAttachment *)msgAttachment{
    NIMMessage *message = [[NIMMessage alloc] init];
    message.text = [NSString stringWithFormat:@"\"%@\" 成功下麦", msgAttachment.member.nickName];
    message.remoteExt = @{@"type":@(1)};
    [_chatView addMessages:@[message]];
    if ([msgAttachment.member.accountId isEqualToString:[NEAccount shared].userModel.accountId]) {//如果操作是自己重置麦克风和摄像头状态
        NETSRtcConfig.sharedConfig.cameraOn = YES;
        NETSRtcConfig.sharedConfig.micOn = YES;
        self.bottomBar.buttonType = NETSAudienceBottomRequestTypeNormal;
    }
}

- (void)receivedAudioAndVideoChange:(NETSConnectMicAttachment *)msgAttachment {
    if ([self.delegate respondsToSelector:@selector(didAudioAndVideoChanged:)]) {
        [self.delegate didAudioAndVideoChanged:msgAttachment];
    }
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

- (NETSConnectMicService *)connectMicService {
    if (!_connectMicService) {
        _connectMicService = [[NETSConnectMicService alloc]init];
        _connectMicService.delegate = self;
    }
    return _connectMicService;
}

@end
