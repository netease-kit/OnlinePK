//
//  NETSPkEnum.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/9.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

///
/// pk直播服务 枚举
///

#ifndef NETSPkEnum_h
#define NETSPkEnum_h

/// 被邀请者忙碌,拒绝pk邀请自定义字段
static NSString *kInviteeBusyRejectPk = @"busy_now";
/// 邀请者超时,取消pk邀请自定义字段
static NSString *kInviterTimeoutCancelPk = @"time_out_cancel";


/**
 用户角色类型
 */
typedef NS_ENUM(NSUInteger, NETSUserMode) {
    NETSUserModeAnchor      = 0,    // 主播
    NETSUserModeAudience    = 1,    // 观众
    NETSUserModeConnecter   = 2     //连麦者
};


/// 直播状态枚举
typedef NS_ENUM(NSUInteger, NETSPkServiceStatus) {
    NETSPkServiceInit               = 0,    // 初始化状态
    NETSPkServicePrevew             = 1,    // 预览状态
    NETSPkServiceSingleLive         = 2,    // 单人直播状态
    NETSPkServicePkInviting         = 3,    // pk直播邀请中
    NETSPkServicePkLive             = 4,    // PK直播状态
    NETSPkServiceConnectMicInviting = 5     //连麦邀请中
};

/// 当前角色枚举
typedef NS_ENUM(NSUInteger, NETSPkServiceRole) {
    NETSPkServiceUnknown    = -1,   // 未知直播者
    NETSPkServiceDefault    = 0,    // 普通直播者
    NETSPkServiceInviter    = 1,    // pk邀请者
    NETSPkServiceInvitee    = 2     // pk被邀请者
};

/// 邀请者被拒绝pk类型
typedef NS_ENUM(NSUInteger, NETSPkRejectedType) {
    NETSPkRejectedArtificial        = 0,    // 被邀请者手动拒绝
    NETSPkRejectedForBusyInvitee    = 1     // 因被邀请者忙碌,自动拒绝邀请者pk邀请
};

/// pk结果枚举
typedef NS_ENUM(NSUInteger, NETSPkResult) {
    NETSPkUnknownResult     = -1,   // 未知获胜状态
    NETSPkCurrentAnchorWin  = 0,    // 当前主播获胜
    NETSPkOtherAnchorWin    = 1,    // 另一个主播获胜
    NETSPkTieResult         = 2      // 平局
};


//麦位状态枚举
typedef NS_ENUM(NSUInteger, NETSSeatsStatus) {
    //麦位初始化（无人，可以上麦）
    NETSSeatsStatusInitInitialize = 0,
    //麦位正在被申请（无人）
    NETSSeatsStatusIsApplying = 1,
    //麦位上有人
    NETSSeatsStatusHasSomeone = 2,
    //麦位关闭（无人）
    NETSSeatsStatusHasClosed = 3,
};


//连麦观众列表操作枚举
typedef NS_ENUM(NSUInteger, NETSUserStatus) {
    
    NETSUserStatusApply = 1,//1 麦位申请
    NETSUserStatusNormal = 2,//2 普通观众
    NETSUserStatusAlreadyOnWheat = 3,//3：已经上麦
};

//连麦状态
typedef NS_ENUM(NSUInteger, NETSAudienceBottomRequestType) {
    NETSAudienceBottomRequestTypeNormal = 1,//正常状态
    NETSAudienceBottomRequestTypeApplying = 2,//申请中
    NETSAudienceBottomRequestTypeAccept = 3,//已同意上麦
};

//房间类型
typedef NS_ENUM(NSUInteger,NERoomType) {
    NERoomTypePkLive = 2,//pk直播
    NERoomTypeConnectMicLive = 3,//pk连麦
};


//pk邀请动作(和透传消息体code通用)
typedef NS_ENUM(NSUInteger,NEPkOperation) {
    NEPkOperationInvite = 1,//邀请
    NEPkOperationAgree = 2,//同意
    NEPkOperationRefuse = 3,//拒绝
    NEPkOperationCancel = 4,//取消
    NEPkOperationTimeout = 5,//超时
};

//pk聊天室消息
typedef NS_ENUM(NSUInteger,NEPKChatRoomMessageBody) {
    NEPKChatRoomMessageBodyPkInvite = 2000,//PK 邀请信息（透传）
    NEPKChatRoomMessageBodyPkStart  = 2001,//PK 开始信息
    NEPKChatRoomMessageBodyPkPunish = 2002,//PK 惩罚开始消息
    NEPKChatRoomMessageBodyPkEnd    = 2003,//PK结束消息
    NEPKChatRoomMessageBodyPkReward = 1001,//观众打赏消息
};


/// 新直播状态枚举
typedef NS_ENUM(NSUInteger, NEPkliveStatus) {
    NEPkliveStatusNone               = 0,    // 未开始
    NEPkliveStatusLiving             = 1,    // 直播中
    NEPkliveStatusPkLiving           = 2,    // PK 直播中
    NEPkliveStatusPkEnd              = 3,    // PK 结束
    NEPkliveStatusLiveEnd            = 4,    // 直播结束
    NEPkliveStatusPunish             = 5,    //惩罚阶段
    NEPkliveStatusConnectMic         = 6,    //连麦中
    NEPkliveStatusInvitePking        = 7,    //邀请 PK 中
    NEPkliveStatusBeInvitedPking     = 8,    //被邀请 PK 中
};

/// 房间状态状态枚举
typedef NS_ENUM(NSUInteger, NEPkRoomStatus) {
    NEPkRoomStatusError               = 0,    // 无效
    NEPkRoomStatusNotStart            = 1,    // 未开始
    NEPkRoomStatusOngoing             = 2,    // 进行中
    NEPkRoomStatusShutDown            = 3,    // 已终止
    NEPkRoomStatusCancel              = 4,    // 已取消
    NEPkRoomStatusRecycled            = 5,    // 已回收
};

//pk状态
typedef NS_ENUM(NSUInteger,NEPKStatus) {
    NEPKStatusInit          = 0,//未开始
    NEPKStatusPking         = 1,//PK 中
    NEPKStatusPkEnd         = 2,//PK 结束
    NEPKStatusPkCancel      = 3,//已取消
    NEPKStatusPkRefuse      = 4,//已拒绝
    NEPKStatusPkInviting    = 5,//邀请中
    NEPKStatusPkPunish      = 6,//惩罚中
};

typedef NS_ENUM(NSUInteger,NESeatFilterType) {
    NESeatFilterTypeApplying    = 1, //观众正在申请
    NESeatFilterTypeNormal      = 2, //普通观众
    NESeatFilterTypeOnSeat      = 3  //在麦上

};

#endif /* NETSPkEnum_h */
