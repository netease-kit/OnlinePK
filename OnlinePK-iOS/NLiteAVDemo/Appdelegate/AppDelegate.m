//
//  AppDelegate.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/18.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "AppDelegate.h"
#import "NEMenuViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "NENavigator.h"
#import "NEPersonVC.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <NERtcSDK/NERtcSDK.h>
#import "NETabbarController.h"
#import "NTELoginVC.h"
#import "AppKey.h"
#import "NEPkLiveAttachment.h"


@interface AppDelegate ()<UNUserNotificationCenterDelegate,NERtcEngineDelegate>
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initWindow];
    [self setupLoginSDK];
    [self setIQKeyboard];
    setupLogger();
    
    return YES;
}


- (void)initWindow {
    
     self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
     self.window.backgroundColor = UIColor.whiteColor;
     NETabbarController *tabbarCtrl = [[NETabbarController alloc]init];
     self.window.rootViewController = tabbarCtrl;
     [NENavigator shared].navigationController = tabbarCtrl.menuNavController;
     [self.window makeKeyAndVisible];
    
    //设置麦位组件
    NELiveRoomOptions *options = [[NELiveRoomOptions alloc] initWithAppKey:kAppKey apiHost:kApiHost];
    [NELiveRoom.sharedInstance setupWithOptions:options];
    
}

- (void)autoLogin {
    
    if ([[NEAccount shared].accessToken length] > 0) {
        [NEAccount loginByTokenWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSString *msg = data[@"msg"] ?: @"请求错误";
                YXAlogError(@"loginByToken failed,error = %@",msg);
            }
        }];
    }
}
- (void)setIQKeyboard {
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)setupSDK {
    NIMSDKOption *option = [NIMSDKOption optionWithAppKey:kAppKey];
    [[NIMSDK sharedSDK] registerWithOption:option];
    [NIMCustomObject registerCustomDecoder:[[NEPKLiveAttachmentDecoder alloc] init]];
}

- (void)setupLoginSDK {
    YXConfig *config = [[YXConfig alloc] init];
    config.appKey = kAppKey;
    config.parentScope = [NSNumber numberWithInt:1];
    config.scope = [NSNumber numberWithInt:3];
    config.isOnline = YES;
    config.type = YXLoginEmail;

    [[AuthorManager shareInstance] initAuthorWithConfig:config];
//    __weak typeof(self) weakSelf = self;
    if ([LoginManager canAutologin] == YES) {
        [LoginManager autoLoginWithCompletion:^(YXUserInfo * _Nullable userinfo, NSError * _Nullable error) {
            if (error == nil) {
                
                NSLog(@"统一登录sdk登录成功");
                [NEAccount syncLoginData:userinfo];
                //[weakSelf imLogin];
            }else {
                [UIApplication.sharedApplication.keyWindow makeToast:error.localizedDescription];
            }
        }];
    }else {
        NSLog(@"LoginManager startEntrance");
        /*
        [LoginManager startLoginWithCompletion:^(YXUserInfo * _Nullable userinfo, NSError * _Nullable error) {
            if (error == nil) {
                NSLog(@"统一登录sdk登录成功");
                [NEAccount syncLoginData:userinfo];
                //[weakSelf imLogin];
            }else {
                [UIApplication.sharedApplication.keyWindow makeToast:error.localizedDescription];
            }
        }]; */
        
        [LoginManager startEntranceWithCompletion:^(YXUserInfo * _Nullable userinfo, NSError * _Nullable error) {
            if (error == nil) {
                NSLog(@"统一登录sdk登录成功");
                [NEAccount syncLoginData:userinfo];
                //[weakSelf imLogin];
            }else {
                [UIApplication.sharedApplication.keyWindow makeToast:error.localizedDescription];
            }
        }];
    }
}

- (void)imLogin{
    [NEAccount imloginWithYXuser:[LoginManager getUserInfo]];
}

@end
