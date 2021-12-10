//
//  NTESConnectStartTimeKey.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/22.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <UIKit/UIKit.h>

#pragma mark ========= 常量数据定义 =========
UIKIT_EXTERN NSString *const NTESConnectStartTimeKey;//开始连麦的时间戳




#pragma mark ========= 通知中心 NotificationCenter Key =========
// 观众同意主播邀请上麦的通知
extern NSString * const NotificationName_Audience_AcceptConnectMic;
//申请连麦的通知
extern NSString * const NotificationName_Audience_ApplyConnectMic;
//主播刷新麦位管理的通知
extern NSString * const NotificationName_Anchor_RefreshSeats;
