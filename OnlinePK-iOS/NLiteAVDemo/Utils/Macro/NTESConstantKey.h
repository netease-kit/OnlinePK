//
//  NTESConnectStartTimeKey.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/22.
//  Copyright © 2021 Netease. All rights reserved.
//

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
