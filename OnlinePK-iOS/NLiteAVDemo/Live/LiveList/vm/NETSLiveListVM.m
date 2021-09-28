//
//  NETSLiveListVM.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/9.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSLiveListVM.h"
#import "NETSLiveModel.h"
#import "NETSLiveApi.h"
#import "NEAccount.h"
#import "NEPkRoomApiService.h"
#import "NELiveRoomListModel.h"

@interface NETSLiveListVM ()

@property (nonatomic, strong, readwrite)    NSArray <NELiveRoomListDetailModel *> *datas;
@property (nonatomic, assign, readwrite)    BOOL    isEnd;
@property (nonatomic, assign, readwrite)    BOOL    isLoading;
@property (nonatomic, assign, readwrite)    NSError *error;

@property (nonatomic, assign)   int32_t   pageNum;
@property (nonatomic, assign)   int32_t   pageSize;

@property(nonatomic, strong) NEPkRoomApiService *roomApiService;
@end

@implementation NETSLiveListVM

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pageNum = 1;
        _pageSize = 20;
        _datas = @[];
    }
    return self;
}

- (void)load {
    self.pageNum = 1;
    self.isLoading = YES;

    [self.roomApiService requestLiveRoomListWithRoomType:_roomType pageNum:_pageNum pageSize:_pageSize completionHandle:^(NSDictionary * _Nonnull response) {
        NSArray *list = response[@"/data/list"];
        if (list && [list isKindOfClass:[NSArray class]]) {
            self.datas = list;
        } else {
            self.datas = @[];
        }

        self.isLoading = NO;
        self.isEnd = ([list count] < self.pageSize);
        self.error = nil;
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        if (error) {
            YXAlogError(@"requestLiveRoomList failed,error:%@",error);
            self.datas = @[];
            self.isLoading = NO;
            self.isEnd = YES;
            self.error = error;
        }
    }];

    
}

- (void)loadMore {
    if (_isEnd) {
        return;
    }
    
    self.pageNum += 1;
    self.isLoading = YES;

    [self.roomApiService requestLiveRoomListWithRoomType:_roomType pageNum:_pageNum pageSize:_pageSize completionHandle:^(NSDictionary * _Nonnull response) {
        NSArray *list = response[@"/data/list"];
        if (list && [list isKindOfClass:[NSArray class]]) {
            NSMutableArray *temp = [NSMutableArray arrayWithArray:self.datas];
            [temp addObjectsFromArray:list];
            self.datas = [temp copy];

            self.isLoading = NO;
            self.isEnd = ([list count] < self.pageSize);
            self.error = nil;
        }
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        if (error) {
            YXAlogError(@"requestLiveRoomList failed,error:%@",error);
            self.isLoading = NO;
            self.isEnd = YES;
            self.error = error;
        }
    }];
    
}
-(NEPkRoomApiService *)roomApiService {
    if (!_roomApiService) {
        _roomApiService = [[NEPkRoomApiService alloc]init];
    }
    return _roomApiService;
}
@end
