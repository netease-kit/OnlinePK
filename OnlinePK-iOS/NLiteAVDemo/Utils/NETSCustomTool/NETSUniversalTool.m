//
//  NETSUniversalTool.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/5/18.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSUniversalTool.h"

@implementation NETSUniversalTool
+ (UIViewController *)getCurrentActivityViewController {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    //从根控制器开始查找
    UIViewController *rootVC = window.rootViewController;
    UIViewController *activityVC = nil;
    
    while (true) {
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            activityVC = [(UINavigationController *)rootVC visibleViewController];
        } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
            UIViewController *currentVc = [(UITabBarController *)rootVC selectedViewController];
            if ([currentVc isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navVc = (UINavigationController *)currentVc;
                activityVC = [navVc visibleViewController];
            }else {
                activityVC = currentVc;
            }
        } else if (rootVC.presentedViewController) {
            activityVC = rootVC.presentedViewController;
        } else if ([rootVC isKindOfClass:[UIViewController class]]) {
            activityVC = (UIViewController *)rootVC;
        } else {
            break;
        }
        if (![NSObject isNullOrNilWithObject:activityVC]) {
            rootVC = activityVC;
            break;
        }
    }
    
    return activityVC;
}
@end
