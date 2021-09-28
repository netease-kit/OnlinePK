//
//  NELiveBaseViewController.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/12.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NELiveBaseViewController.h"
#import "NETSRequestManageMainController.h"
#import "NTESActionSheetNavigationController.h"

#import "NETSAnchorBottomPanel.h"
#import "NTESKeyboardToolbarView.h"
#import "NETSWarnToast.h"
#import "NETSAnchorTopInfoView.h"
#import "NETSAudienceNum.h"
#import "NETSInputToolBar.h"
#import "NETSLiveChatView.h"
#import "NETSBeautySettingActionSheet.h"
#import "NETSFilterSettingActionSheet.h"
#import "NETSLiveSettingActionSheet.h"
#import "NETSAudioMixingActionSheet.h"
#import "NETSMoreSettingActionSheet.h"

#import "NETSCanvasModel.h"
#import "NETSAnchorCoverSetting.h"
#import "NETSLiveConfig.h"
#import "NETSFUManger.h"
#import "AppKey.h"
#import "NENavigator.h"
#import "IQKeyboardManager.h"
#import "NEPkRoomService.h"
#import "NECreateRoomResponseModel.h"
#import "NETSPushStreamService.h"

@interface NELiveBaseViewController ()<
    NETSAnchorBottomPanelDelegate,
    NTESKeyboardToolbarDelegate,
    NETSInputToolBarDelegate,
    NETSMoreSettingActionSheetDelegate,
    NERtcEngineDelegateEx
>
/// 绘制单人直播摄像头采集
@property (nonatomic, strong)   UIView                  *singleRender;
/// 单人直播canvas模型
@property (nonatomic, strong)   NETSCanvasModel         *singleCanvas;
/// 绘制摄像头采集
@property (nonatomic, strong,readwrite)   UIView                  *localRender;
/// 本地canvas模型
@property (nonatomic, strong)   NETSCanvasModel         *localCanvas;
/// 远端视频面板
@property (nonatomic, strong,readwrite)   UIView                  *remoteRender;
/// 远端canvas模型
@property (nonatomic, strong)   NETSCanvasModel         *remoteCanvas;
/// 底部面板
@property (nonatomic, strong)   NETSAnchorBottomPanel   *bottomPanel;
/// 键盘工具条
@property (nonatomic, strong)   NTESKeyboardToolbarView *toolBar;
/// 封面设置面板
@property (nonatomic, strong)   NETSAnchorCoverSetting  *settingPanel;
/// 返回按钮
@property (nonatomic, strong)   UIButton                *backBtn;
/// 切换摄像头按钮
@property (nonatomic, strong)   UIButton                *switchCameraBtn;
/// 试用提示
@property (nonatomic, strong)   NETSWarnToast           *warnToast;
/// 主播信息视图
@property (nonatomic, strong)   NETSAnchorTopInfoView   *anchorInfo;
/// 直播中 观众数量视图
@property (nonatomic, strong)   NETSAudienceNum         *audienceInfo;
/// 直播中 底部工具条
@property (nonatomic, strong)   NETSInputToolBar        *livingInputTool;

@property(nonatomic, strong,readwrite) NECreateRoomResponseModel *createRoomModel;
@property(nonatomic, assign) NERoomType roomType;


@end

@implementation NELiveBaseViewController


- (instancetype)initWithRoomType:(NERoomType)roomType {
    if (self = [super init]) {
        _roomType = roomType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ne_initializeConfig];
    [self ne_addsubview];
    [self ne_bindViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)ne_initializeConfig {
    
    self.view.backgroundColor = HEXCOLOR(0x1b1919);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // 重置更多设置
    [[NETSLiveConfig shared] resetConfig];
    // 重置美颜配置
    [[NETSFUManger shared] resetSkinParams];
    // 重置滤镜配置
    [[NETSFUManger shared] resetFilters];
    [self setupRTCEngine];
    [self _authCameraAndPrevew];
}

- (void)ne_addsubview {
    [self layoutPreview];
    [self layoutRenders];
}

- (void)ne_bindViewModel {
    @weakify(self);
//    [RACObserve(self.createRoomModel, anchor) subscribeNext:^(NECreateRoomResponseModel*  _Nullable room) {
//        @strongify(self);
//        if (!room) { return; }
//        [self.anchorInfo installWithAvatar:room.anchor.avatar nickname:room.anchor.nickname wealth:0];
//    }];
}

#pragma mark - privateMethod
/// 初始化RTC引擎
- (void)setupRTCEngine {
    NSAssert(![kAppKey isEqualToString:@"AppKey"], @"请设置AppKey");
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    
    // 设置直播模式
    [coreEngine setChannelProfile:kNERtcChannelProfileLiveBroadcasting];
    
    // 打开推流,回调摄像头采集数据
    NSDictionary *params = @{
        kNERtcKeyPublishSelfStreamEnabled: @YES,    // 打开推流
        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户
    };
    [coreEngine setParameters:params];
    [coreEngine setClientRole:kNERtcClientRoleBroadcaster];
    
    // 设置视频发送配置(帧率/分辨率)
    NERtcVideoEncodeConfiguration *config = [NETSLiveConfig shared].videoConfig;
    [coreEngine setLocalVideoConfig:config];
    
    // 设置音频质量
    NSUInteger quality = [NETSLiveConfig shared].audioQuality;
    [coreEngine setAudioProfile:kNERtcAudioProfileHighQuality scenario:quality];
    [coreEngine setChannelProfile:kNERtcChannelProfileLiveBroadcasting];

    
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.engineDelegate = self;
    context.appKey = kNertcAppkey;
    NERtcLogSetting *setting = [[NERtcLogSetting alloc] init];
     #if DEBUG
          setting.logLevel = kNERtcLogLevelInfo;
     #else
          setting.logLevel = kNERtcLogLevelWarning;
     #endif
     context.logSetting = setting;

    int res = [coreEngine setupEngineWithContext:context];
    YXAlogInfo(@"初始化设置 NERtcEngine, res: %d", res);
    
    // 启用本地音/视频
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
}
/// 预览布局
- (void)layoutPreview {
    [self.anchorInfo removeFromSuperview];
    [self.audienceInfo removeFromSuperview];
    [self.chatView removeFromSuperview];
//    [self.livingInputTool removeFromSuperview];
    
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.switchCameraBtn];
    [self.view addSubview:self.settingPanel];
    [self.view addSubview:self.bottomPanel];
    [self.view addSubview:self.warnToast];

    self.backBtn.frame = CGRectMake(20, (kIsFullScreen ? 44 : 20) + 8, 24, 24);
    self.switchCameraBtn.frame = CGRectMake(kScreenWidth - 20 - 24, (kIsFullScreen ? 44 : 20) + 8, 24, 24);
    self.settingPanel.frame = CGRectMake(20, (kIsFullScreen ? 88 : 64) + 20, kScreenWidth - 40, 88);
    self.bottomPanel.frame = CGRectMake(0, kScreenHeight - 128 - (kIsFullScreen ? 54 : 20), kScreenWidth, 128);
    self.warnToast.frame = CGRectMake(20, self.bottomPanel.top - 20 - 60, kScreenWidth - 40, 60);

    @weakify(self);
    self.warnToast.clickBlock = ^{
        @strongify(self);
        [self.warnToast removeFromSuperview];
    };
}

/// 布局视频渲染视图
- (void)layoutRenders {
    [self.view addSubview:self.localRender];
    [self.view addSubview:self.remoteRender];
    [self.view addSubview:self.singleRender];
    
    CGFloat anchorInfoBottom = (kIsFullScreen ? 44 : 20) + 36 + 4;
    self.localRender.frame = CGRectMake(0, anchorInfoBottom + 24, kScreenWidth / 2.0, kScreenWidth / 2.0 * 1280 / 720.0);
    self.remoteRender.frame = CGRectMake(self.localRender.right, self.localRender.top, self.localRender.width, self.localRender.height);
    self.singleRender.frame = self.view.bounds;
    
    [self.view sendSubviewToBack:self.singleRender];
    [self.view sendSubviewToBack:self.remoteRender];
    [self.view sendSubviewToBack:self.localRender];
}


- (void)_authCameraAndPrevew {
    void(^quitBlock)(void) = ^(void) {
        [NETSToast showToast:NSLocalizedString(@"直播需要开启相机权限", nil)];
        ntes_main_sync_safe(^{
            [[NENavigator shared].navigationController popViewControllerAnimated:YES];
        });
    };
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            quitBlock();
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (!granted) {
                    quitBlock();
                } else {
                    dispatch_queue_t queue= dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), queue, ^{
                        ntes_main_async_safe(^{
                            [self startPrevew];
                        });
                    });
                }
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized:
        {
            ntes_main_async_safe(^{
                [self startPrevew];
            });
        }
            break;
        default:
            break;
    }
}

- (void)startPrevew {
    NERtcVideoCanvas *canvas = [self setupSingleCanvas];
    int setLocalCanvasRes = [[NERtcEngine sharedEngine] setupLocalVideoCanvas:canvas];
    YXAlogInfo(@"设置本地视频画布, res: %d", setLocalCanvasRes);

    int previewRes = [[NERtcEngine sharedEngine] startPreview];
    YXAlogInfo(@"开启预览, res: %d", previewRes);
}

- (void)clickAction:(UIButton *)sender {
    if (sender == self.backBtn) {
        [self backButtonClickAction];
    }else if (sender == self.switchCameraBtn) {
        int res = [[NERtcEngine sharedEngine] switchCamera];
        YXAlogInfo(@"切换前后摄像头, res: %d", res);
    }
}

- (void)closeLiveRoom {
    
    [[NEPkRoomService sharedRoomService] closeLiveCompletionBlock:^(NSError * _Nullable error) {
        if (error) {
            YXAlogError(@"close liveRoom failed,error = %@",error);
            [NETSToast showToast:NSLocalizedString(@"关闭房间失败", nil)];
        }
        //销毁rtc资源
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int res = [NERtcEngine destroyEngine];
            YXAlogInfo(@"destroyEngine, res: %d", res);
        });
        if ([self.presentedViewController isKindOfClass:[UIAlertController class]]) {//防止在销毁房间的时候有其他主播邀请pk
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        }else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)backButtonClickAction {
    [[NERtcEngine sharedEngine] stopPreview];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - publicMethod
/// 单人直播布局
- (void)layoutSingleLive {
   
    [self.backBtn removeFromSuperview];
    [self.switchCameraBtn removeFromSuperview];
    [self.settingPanel removeFromSuperview];
    [self.bottomPanel removeFromSuperview];

    
    [self.view addSubview:self.anchorInfo];
    [self.view addSubview:self.audienceInfo];
    [self.view addSubview:self.chatView];
    [self.view addSubview:self.livingInputTool];
    [self.view addSubview:self.toolBar];
    
    self.singleRender.hidden = NO;

    self.anchorInfo.frame = CGRectMake(8, (kIsFullScreen ? 44 : 20) + 4, 124, 36);
    self.audienceInfo.frame = CGRectMake(kScreenWidth - 8 - 195, self.anchorInfo.top + (36 - 28) / 2.0, 195, 28);
    CGFloat chatViewHeight = [self chatViewHeight];
    self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
    self.livingInputTool.frame = CGRectMake(0, kScreenHeight - (kIsFullScreen ? 34 : 0) - 14 - 36, kScreenWidth, 36);
}

/// pk直播布局
- (void)layoutPkLive
{
    [self.backBtn removeFromSuperview];
    [self.switchCameraBtn removeFromSuperview];
    [self.settingPanel removeFromSuperview];
    [self.bottomPanel removeFromSuperview];
//    [self.pkSuccessIco removeFromSuperview];
//    [self.pkFailedIco removeFromSuperview];
    
//    [self.view addSubview:self.pkStatusBar];
    [self.view addSubview:self.anchorInfo];
    [self.view addSubview:self.audienceInfo];
    [self.view addSubview:self.chatView];
//    [self.view addSubview:self.pkBtn];
    [self.view addSubview:self.livingInputTool];
//    [self.view addSubview:self.inviteeInfo];
    [self.view addSubview:self.toolBar];
    
    self.singleRender.hidden = YES;
    
//    self.pkStatusBar.frame = CGRectMake(0, self.localRender.bottom, kScreenWidth, 58);
    self.anchorInfo.frame = CGRectMake(8, (kIsFullScreen ? 44 : 20) + 4, 124, 36);
    self.audienceInfo.frame = CGRectMake(kScreenWidth - 8 - 195, self.anchorInfo.top + (36 - 28) / 2.0, 195, 28);
    CGFloat chatViewHeight = [self chatViewHeight];
    self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
//    self.pkBtn.frame = CGRectMake(kScreenWidth - 60 - 8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - 60, 60, 60);
    self.livingInputTool.frame = CGRectMake(0, kScreenHeight - (kIsFullScreen ? 34 : 0) - 14 - 36, kScreenWidth, 36);
//    self.inviteeInfo.frame = CGRectMake(self.remoteRender.right - 8 - 82, self.remoteRender.top + 8, 82, 24);
//
//    [self.pkStatusBar refreshWithLeftRewardCoins:0 leftRewardAvatars:@[] rightRewardCoins:0 rightRewardAvatars:@[]];
}


- (void)chatViewAddMessge:(NSArray<NIMMessage *> *)messages {
    [self.chatView addMessages:messages];
}

//创建房间成功后 刷新UI
- (void)createRoomRefreshUI {
    // 服务端透传开始直播消息, 保持屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    // 单人直播布局
    ntes_main_async_safe(^{
        [NETSToast hideLoading];
        [self layoutSingleLive];
    });
    
    NERtcVideoCanvas *canvas = [self setupSingleCanvas];
    int setLocalCanvasRes = [[NERtcEngine sharedEngine] setupLocalVideoCanvas:canvas];
    YXAlogInfo(@"setupSingleCanvas again, res: %d", setLocalCanvasRes);
    [self.anchorInfo installWithAvatar:self.createRoomModel.anchor.avatar nickname:self.createRoomModel.anchor.nickname wealth:0];
}

//开始直播
- (void)clickStartLiveBtn {

    // 开启直播条件判断
    NSString *topic = [self.settingPanel getTopic];
    NSString *cover = [self.settingPanel getCover];
    if (isEmptyString(topic)) {
        [NETSToast showToast:NSLocalizedString(@"直播间主题为空", nil)];

        return;
    }
    if (isEmptyString(cover)) {
        [NETSToast showToast:NSLocalizedString(@"直播间封面为空", nil)];
        return;
    }
    
    [NETSToast showLoading];
   
    [[NEPkRoomService sharedRoomService] createLiveRoomWithTopic:topic coverUrl:cover roomType:self.roomType successBlock:^(NECreateRoomResponseModel * _Nonnull roomModel, NERtcLiveStreamTaskInfo * _Nonnull taskInfo) {
        YXAlogInfo(@"create room success,roomId = %@",roomModel.live.roomId);
        [NETSToast hideLoading];
        self.warnToast.hidden = YES;
        self.createRoomModel = roomModel;
        [self createRoomRefreshUI];
        } failedBlock:^(NSError * _Nonnull error) {
            [NETSToast hideLoading];
            [NERtcEngine destroyEngine];
            NSString *msg = error.userInfo[NSLocalizedDescriptionKey] ?: NSLocalizedString(@"开启直播间失败", nil);
            [NETSToast showToast:msg];
            [[NENavigator shared].navigationController popViewControllerAnimated:YES];
            YXAlogError(@"create room failed, error: %@", error);
        }];
}
#pragma mark - 当键盘事件

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = rect.size.height;
    CGFloat chatViewHeight = [self chatViewHeight];
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - chatViewHeight - keyboardHeight - 50, kScreenWidth - 16 - 60 - 20, chatViewHeight);
        self.toolBar.frame = CGRectMake(0, kScreenHeight - keyboardHeight - 50, kScreenWidth, 50);
    }];
    [self.view bringSubviewToFront:self.toolBar];

}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    CGFloat chatViewHeight = [self chatViewHeight];
    [UIView animateWithDuration:0.1 animations:^{
        self.chatView.frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - chatViewHeight, kScreenWidth - 16 - 60 - 20, chatViewHeight);
        self.toolBar.frame = CGRectMake(0, kScreenHeight + 50, kScreenWidth, 50);
    }];
}
#pragma mark - NTESKeyboardToolbarDelegate 键盘顶部工具条代理

- (void)didToolBarSendText:(NSString *)text {
    if (isEmptyString(text)) {
        [NETSToast showToast:NSLocalizedString(@"所发消息为空", nil)];

        return;
    }
    [self.livingInputTool resignFirstResponder];
    [[NEPkRoomService sharedRoomService] sendTextMessage:text];
}

#pragma mark - NETSInputToolBarDelegate 底部工具条代理事件
- (void)clickInputToolBarAction:(NETSInputToolBarAction)action {
    switch (action) {
        case NETSInputToolBarInput: {
            [self.toolBar becomeFirstResponse];
        }
            break;
        case NETSInputToolBarBeauty: {
            [NETSBeautySettingActionSheet show];
        }
            break;
        case NETSInputToolBarConnectRequest: {//主播连麦管理
            [self connectMicManagerClick];
            NETSRequestManageMainController *statusVc = [[NETSRequestManageMainController alloc] initWithRoomId:self.createRoomModel.live.roomId];
            NTESActionSheetNavigationController *nav = [[NTESActionSheetNavigationController alloc] initWithRootViewController:statusVc];
            nav.dismissOnTouchOutside = YES;
            [[NENavigator shared].navigationController presentViewController:nav animated:YES completion:nil];
        }
            break;
        case NETSInputToolBarMusic: {
            [NETSAudioMixingActionSheet show];
        }
            break;
        case NETSInputToolBarMore: {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSArray *items = [NETSLiveConfig shared].moreSettings;
                [NETSMoreSettingActionSheet showWithTarget:self items:items];
            });
          
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - NETSMoreSettingActionSheetDelegate 点击更多设置代理
/// 开启/关闭 摄像头
- (void)didSelectCameraEnable:(BOOL)enable {
    if (!enable) {
        [self.localCanvas resetCanvas];
    } else {
        [self.localCanvas setupCanvas];
    }
}

/// 关闭直播间
- (void)didSelectCloseLive {
    [self closeLiveRoom];
}



#pragma mark - NETSAnchorBottomPanelDelegate 底部操作面板代理
- (void)clickBeautyBtn {
    [NETSBeautySettingActionSheet showWithMask:NO];
}

- (void)clickFilterBtn {
    [NETSFilterSettingActionSheet showWithMask:NO];
}

- (void)clickSettingBtn {
    [NETSLiveSettingActionSheet show];
}

#pragma mark - NERtcEngineDelegateEx G2音视频

- (void)onNERtcEngineVideoFrameCaptured:(CVPixelBufferRef)bufferRef rotation:(NERtcVideoRotationType)rotation {
    [[NETSFUManger shared] renderItemsToPixelBuffer:bufferRef];
}

- (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName
{
    NERtcVideoCanvas *canvas = [self setupRemoteCanvas];
    [NERtcEngine.sharedEngine setupRemoteVideoCanvas:canvas forUserID:userID];
}

- (void)onNERtcEngineUserVideoDidStartWithUserID:(uint64_t)userID videoProfile:(NERtcVideoProfileType)profile
{
    _remoteCanvas.subscribedVideo = YES;
    [NERtcEngine.sharedEngine subscribeRemoteVideo:YES forUserID:userID streamType:kNERtcRemoteVideoStreamTypeHigh];
}

- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID reason:(NERtcSessionLeaveReason)reason
{
    // 如果远端的人离开了，重置远端模型和UI
    if (userID == _remoteCanvas.uid) {
        [_remoteCanvas resetCanvas];
        _remoteCanvas = nil;
    }
}

/// 离开channel
- (void)onNERtcEngineDidLeaveChannelWithResult:(NERtcError)result
{
    if (result != kNERtcNoError) {
        YXAlogInfo(@"离开单人channel失败, error: %d", result);
        return;
    }
    // 离开channel,重置混音索引
    [NETSLiveConfig shared].mixingIdx = -1;
}

- (void)onNERtcEngineDidDisconnectWithReason:(NERtcError)reason {
    [NETSToast showToast:@"网络断开"];
    [NERtcEngine destroyEngine];
    [[NENavigator shared].navigationController popViewControllerAnimated:YES];
}

/// 直播推流状态回调
- (void)onNERTCEngineLiveStreamState:(NERtcLiveStreamStateCode)state taskID:(NSString *)taskID url:(NSString *)url
{

}

/// 音效播放结束回调
- (void)onAudioEffectFinished:(uint32_t)effectId
{
    NSDictionary *info = @{ @"effectId": @(effectId) };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNetsRtcEffectStopNoti object:nil userInfo:info];
}

-(void)onNERtcEngineAudioDeviceRoutingDidChange:(NERtcAudioOutputRouting)routing {
    [NETSLiveConfig shared].outputRoute = routing;
}


- (void)dealloc {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - lazy load

- (UIView *)singleRender
{
    if (!_singleRender) {
        _singleRender = [[UIView alloc] init];
    }
    return _singleRender;
}

- (UIView *)localRender
{
    if (!_localRender) {
        _localRender = [[UIView alloc] init];
    }
    return _localRender;
}

- (UIView *)remoteRender
{
    if (!_remoteRender) {
        _remoteRender = [[UIView alloc] init];
    }
    return _remoteRender;
}

- (NETSAnchorBottomPanel *)bottomPanel
{
    if (!_bottomPanel) {
        _bottomPanel = [[NETSAnchorBottomPanel alloc] init];
        _bottomPanel.delegate = self;
    }
    return _bottomPanel;
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

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"back_ico"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)switchCameraBtn
{
    if (!_switchCameraBtn) {
        _switchCameraBtn = [[UIButton alloc] init];
        UIImage *img = [[UIImage imageNamed:@"switch_camera_ico"] sd_tintedImageWithColor:[UIColor whiteColor]];
        [_switchCameraBtn setImage:img forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

- (NETSAnchorCoverSetting *)settingPanel
{
    if (!_settingPanel) {
        _settingPanel = [[NETSAnchorCoverSetting alloc] init];
    }
    return _settingPanel;
}

- (NETSWarnToast *)warnToast
{
    if (!_warnToast) {
        _warnToast = [[NETSWarnToast alloc] init];
        _warnToast.toast = NSLocalizedString(@"本应用为测试产品、请勿商用。单次直播最长10分钟，每个频道最多10人", nil);

    }
    return _warnToast;
}

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

- (NETSInputToolBar *)livingInputTool
{
    if (!_livingInputTool) {
        _livingInputTool = [[NETSInputToolBar alloc] initWithRoomType:self.roomType];
        _livingInputTool.delegate = self;
        _livingInputTool.textField.inputAccessoryView = [[UIView alloc] init];
    }
    return _livingInputTool;
}


- (NETSLiveChatView *)chatView {
    if (!_chatView) {
        CGRect frame = CGRectMake(8, kScreenHeight - (kIsFullScreen ? 34 : 0) - 64 - 204, kScreenWidth - 16 - 60 - 20, 204);
        _chatView = [[NETSLiveChatView alloc] initWithFrame:frame];
    }
    return _chatView;
}

- (CGFloat)chatViewHeight
{
    if (kScreenHeight <= 568) {
        return 100;
    } else if (kScreenHeight <= 736) {
        return 130;
    }
    return 204;
}


/// 建立单人直播canvas模型
- (NERtcVideoCanvas *)setupSingleCanvas
{
    if (!_singleCanvas) {
        _singleCanvas = [[NETSCanvasModel alloc] init];
        _singleCanvas.renderContainer = self.singleRender;
    }
    [_singleCanvas resetCanvas];
    return [_singleCanvas setupCanvas];
}

/// 建立本地canvas模型
- (NERtcVideoCanvas *)setupLocalCanvas {
    if (!_localCanvas) {
        _localCanvas = [[NETSCanvasModel alloc] init];
        _localCanvas.renderContainer = self.localRender;
    }
    [_localCanvas resetCanvas];
    return [_localCanvas setupCanvas];
}

/// 建立远端canvas模型
- (NERtcVideoCanvas *)setupRemoteCanvas
{
    if (!_remoteCanvas) {
        _remoteCanvas = [[NETSCanvasModel alloc] init];
        _remoteCanvas.renderContainer = self.remoteRender;
    }
    [_remoteCanvas resetCanvas];
    return [_remoteCanvas setupCanvas];
}



@end
