//
//  NEPersonVC.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEPersonVC.h"
#import "NEPersonTableViewCell.h"
#import "NEPersonInfoVC.h"
#import "NEAboutViewController.h"
#import "NEAccount.h"
#import "NEBaseWebViewController.h"
#import "NEEvaluateVC.h"
#import "NEFeedbackVC.h"
#import "NENavigator.h"

@interface NEPersonVC ()
@property(strong,nonatomic)NSArray *dataArray;

@end

@implementation NEPersonVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"个人中心", nil);
    [self.tableView registerClass:[NEPersonTableViewCell class] forCellReuseIdentifier:@"personCellID"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self initData];
    [self.tableView reloadData];
}

- (void)initData {
    NSString *name = NEAccount.shared.userModel.nickname?:@"";
    self.dataArray = @[@[name],@[NSLocalizedString(@"免费申请试用", nil),NSLocalizedString(@"关于", nil)]];
    
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = self.dataArray[section];
    return sectionArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 88;
            break;
        case 1:
            return 56;
            break;
        default:
            return 56;
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NEPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personCellID" forIndexPath:indexPath];
    NSArray *sectionArray = self.dataArray[indexPath.section];
    NSString *content = sectionArray[indexPath.row];
    if (indexPath.section == 0) {
        [cell.personView.iconImageView sd_setImageWithURL:[NSURL URLWithString:NEAccount.shared.userModel.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
        cell.personView.iconImageView.layer.cornerRadius = (56 - 20)/2.0;
        cell.personView.iconImageView.clipsToBounds = YES;
    }
    cell.personView.titleLabel.text = content;
    cell.personView.indicatorImageView.image = [UIImage imageNamed:@"menu_arrow"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (![NEAccount shared].hasLogin) {
                //[[NENavigator shared] loginWithOptions:nil];
                [[AuthorManager shareInstance] startEntranceWithCompletion:^(YXUserInfo * _Nullable userinfo, NSError * _Nullable error) {
                    [NEAccount imloginWithYXuser:[LoginManager getUserInfo]];
                }];
            }else {
                //个人信息
                NEPersonInfoVC *vc = [[NEPersonInfoVC alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }else{
        switch (indexPath.row) {
            case 0:
                //免费申请试用
                [self gotoTry];
                break;
            case 1:
                //关于
                [self gotoAboutMe];
                break;
            default:
                break;
        }
        
    }
}
- (void)gotoEvaluate {
    NEFeedbackVC *evaluateVC = [[NEFeedbackVC alloc] init];
    evaluateVC.title = NSLocalizedString(@"意见反馈", nil);
    evaluateVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:evaluateVC animated:YES];
}
- (void)gotoTry {
    NEBaseWebViewController *web = [[NEBaseWebViewController alloc] initWithUrlString:@"https://id.163yun.com/register"];
    web.title = NSLocalizedString(@"网易云信注册", nil);
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}
- (void)gotoAboutMe {
    NEAboutViewController *aboutVC = [[NEAboutViewController alloc] init];
    aboutVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:aboutVC animated:YES];
}
@end
