//
//  NEPersonInfoVC.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEPersonInfoVC.h"
#import "NEPersonTableViewCell.h"
#import "NEPersonTextCell.h"
#import "NEAccount.h"
#import "NENicknameVC.h"
#import "NENavigator.h"

@interface NEPersonInfoVC ()
@property(strong,nonatomic)NSArray *dataArray;
@property(strong,nonatomic)NSString *nickname;

@end

@implementation NEPersonInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    if ([NEAccount shared].hasLogin) {
        self.dataArray = @[@[NSLocalizedString(@"头像", nil),NSLocalizedString(@"昵称", nil)],@[NSLocalizedString(@"退出登录", nil)]];
    } else {
        self.dataArray = @[@[NSLocalizedString(@"头像", nil),NSLocalizedString(@"昵称", nil)]];
    }
}

- (void)setupUI {
    self.title = NSLocalizedString(@"个人信息", nil);
    [self.tableView registerClass:[NEPersonTextCell class] forCellReuseIdentifier:@"NEPersonTextCell"];
    [self.tableView registerClass:[NEPersonTableViewCell class] forCellReuseIdentifier:@"NEPersonTableViewCell"];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = [self.dataArray objectAtIndex:section];
    if ([sectionArray isKindOfClass:[NSArray class]]) {
        return sectionArray.count;
    }else {
        return 0;
    }
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NEPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NEPersonTableViewCell" forIndexPath:indexPath];
        NSArray *sectionArray = self.dataArray[indexPath.section];
        NSString *content = sectionArray[indexPath.row];
        if (indexPath.row == 0) {
            [cell.personView.indicatorImageView sd_setImageWithURL:[NSURL URLWithString:NEAccount.shared.userModel.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
        }else {
            
            NSString *nickname = NEAccount.shared.userModel.nickname.length ? NEAccount.shared.userModel.nickname : @"";
            cell.personView.detailLabel.text = nickname;
        }
        cell.personView.titleLabel.text = content;
        return cell;
    }else {
        NEPersonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NEPersonTextCell" forIndexPath:indexPath];
        cell.titleLabel.text = NSLocalizedString(@"退出登录", nil);
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
    }else {
        if (indexPath.row == 0) {
            //退出登录
            [self logout];
        }
    }
}

- (void)logout {
    
    __weak typeof(self) weakSelf = self;
    [LoginManager logoutWithConfirm:nil withCompletion:^(YXUserInfo * _Nullable userinfo, NSError * _Nullable error) {
        if (error == nil) {
            [NEAccount localLogoutWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
                if (error) {
                    [weakSelf.view makeToast:error.description];
                }else {
                    [[NENavigator shared] showRootNavWitnIndex:0];
                }
            }];
        }else {
            [weakSelf.view makeToast:error.description];
        }
    }];
    /*
    UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"确认退出登录%@", nil),[NEAccount shared].userModel.mobile] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [NEAccount localLogoutWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            if (error) {
                [self.view makeToast:error.localizedDescription];
            } else {
                [[NENavigator shared] showRootNavWitnIndex:0];
            }
        }];
    }];
    [alerVC addAction:cancelAction];
    [alerVC addAction:okAction];
    [self presentViewController:alerVC animated:YES completion:nil];
     */
}
@end
