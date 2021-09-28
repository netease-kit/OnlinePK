//
//  NETabbarController.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/11.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETabbarController.h"
#import "NEMenuViewController.h"
#import "NEPersonVC.h"
@interface NETabbarController ()
@property(nonatomic,strong,readwrite) UINavigationController *menuNavController;
@end

@implementation NETabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTabbarControllerStyle];
    [self addChildViewControllers];
}

- (void)initTabbarControllerStyle {
    self.tabBar.tintColor = [UIColor whiteColor];
    self.tabBar.barStyle = UIBarStyleBlack;
}

- (void)addChildViewControllers {
    NEMenuViewController *menuVC = [[NEMenuViewController alloc] init];
    UINavigationController *appNav = [[UINavigationController alloc] initWithRootViewController:menuVC];
    self.menuNavController = appNav;
    appNav.tabBarItem.title = NSLocalizedString(@"应用", nil);
    appNav.tabBarItem.image = [UIImage imageNamed:@"application"];
    appNav.tabBarItem.selectedImage = [UIImage imageNamed:@"application_select"];

    NEPersonVC *personVC = [[NEPersonVC alloc] init];
    UINavigationController *personNav = [[UINavigationController alloc] initWithRootViewController:personVC];
    personNav.tabBarItem.title = NSLocalizedString(@"个人中心", nil);
    personNav.tabBarItem.image = [UIImage imageNamed:@"mine"];
    personNav.tabBarItem.selectedImage = [UIImage imageNamed:@"mine_select"];
   
    self.viewControllers = @[appNav,personNav];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
