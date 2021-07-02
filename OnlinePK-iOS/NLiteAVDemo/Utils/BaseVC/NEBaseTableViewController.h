//
//  NEBaseTableViewController.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface NEBaseTableViewController : NEBaseViewController<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)UITableView *tableView;
@end

NS_ASSUME_NONNULL_END
