//
//  NEFeedbackListVC.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/22.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEFeedbackListVC.h"
#import "NEPersonTextCell.h"
#import "NEFeedbackListSectionView.h"
#import "NEFeedbackListCell.h"

@interface NEFeedbackListVC ()
@property(strong,nonatomic)NSMutableArray <NEFeedbackInfo *>*dataArray;
@end

@implementation NEFeedbackListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableview];
}
- (void)setupTableview {
    self.title = NSLocalizedString(@"意见反馈", nil);
    [self.tableView registerClass:[NEFeedbackListCell class] forCellReuseIdentifier:@"NEFeedbackListCell"];
    [self.tableView registerClass:[NEFeedbackListSectionView class] forHeaderFooterViewReuseIdentifier:@"NEFeedbackListSectionView"];
     self.dataArray = [NSMutableArray array];
    NSInteger code = 99;
    for (NSString *title in @[NSLocalizedString(@"音频问题", nil), NSLocalizedString(@"视频问题", nil), NSLocalizedString(@"交互体验", nil), NSLocalizedString(@"其他问题", nil)]) {
        NEFeedbackInfo *info = [[NEFeedbackInfo alloc] init];
        info.title = title;
        NSMutableArray *items = [NSMutableArray array];
        if ([title isEqualToString:NSLocalizedString(@"音频问题", nil)]) {
            code = 100;
            for (NSString *itemTitle in @[NSLocalizedString(@"听不到声音", nil), NSLocalizedString(@"杂音、机械音", nil), NSLocalizedString(@"声音卡顿", nil)]) {
                code = code + 1;
                NEFeedbackInfo *item = [[NEFeedbackInfo alloc] init];
                item.title = itemTitle;
                item.code = code;
                [items addObject:item];
            }
        } else if ([title isEqualToString:NSLocalizedString(@"视频问题", nil)]){
            for (NSString *itemTitle in @[NSLocalizedString(@"看不到画面", nil),NSLocalizedString(@"画面卡顿", nil), NSLocalizedString(@"画面模糊", nil), NSLocalizedString(@"声音画面不同步", nil)]) {
                code = code + 1;
                NEFeedbackInfo *item = [[NEFeedbackInfo alloc] init];
                item.title = itemTitle;
                item.code = code;
                [items addObject:item];
            }
        } else if ([title isEqualToString:NSLocalizedString(@"交互体验", nil)]){
            for (NSString *itemTitle in @[NSLocalizedString(@"意外退出", nil)]) {
                code = code + 1;
                NEFeedbackInfo *item = [[NEFeedbackInfo alloc] init];
                item.title = itemTitle;
                item.code = code;
                [items addObject:item];
            }
        }
        info.items = items;
        [self.dataArray addObject:info];
    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NEFeedbackInfo *info = self.dataArray[section];
    return info.isSelected ? info.items.count : 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 56;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NEFeedbackListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NEFeedbackListCell" forIndexPath:indexPath];
    NEFeedbackInfo *info = self.dataArray[indexPath.section];
    NEFeedbackInfo *item = info.items[indexPath.row];
    cell.titleLabel.text = item.title;
    cell.arrowButton.selected = item.isSelected;
     return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NEFeedbackListSectionView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"NEFeedbackListSectionView"];
    NEFeedbackInfo *info = self.dataArray[section];
    view.arrowButton.selected = info.isSelected;
    view.titleLabel.text = info.title;
    WEAK_SELF(weakSelf);
    view.didSelect = ^(BOOL selected) {
        STRONG_SELF(strongSelf);
        info.isSelected = selected;
        [strongSelf.tableView reloadData];
    };
    return view;
}
- (void)dealloc
{
    if (self.didSelectResult) {
        self.didSelectResult(self.dataArray.copy);
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NEFeedbackInfo *info = self.dataArray[indexPath.section];
    NEFeedbackInfo *item = info.items[indexPath.row];
    item.isSelected = !item.isSelected;
    NEFeedbackListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.arrowButton.selected = item.isSelected;
}

@end
