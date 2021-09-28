//
//  AppDelegate.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/18.
//  Copyright © 2020 Netease. All rights reserved.
//

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

@interface AppDelegate ()<UNUserNotificationCenterDelegate,NERtcEngineDelegate>
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initWindow];
    [self setIQKeyboard];
    setupLogger();
    [self autoLogin];
    return YES;
}


- (void)initWindow {
    
     self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
     self.window.backgroundColor = UIColor.whiteColor;
     if (![NSObject isNullOrNilWithObject:[NEAccount shared].accessToken]) {
         NETabbarController *tabbarCtrl = [[NETabbarController alloc]init];
         self.window.rootViewController = tabbarCtrl;
         [NENavigator shared].navigationController = tabbarCtrl.menuNavController;
     }else {
         UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[NTELoginVC alloc] initWithOptions:nil isShowClose:YES]];
         self.window.rootViewController = nav;
         [NENavigator shared].loginNavigationController  = nav;
     }
     
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

@end
