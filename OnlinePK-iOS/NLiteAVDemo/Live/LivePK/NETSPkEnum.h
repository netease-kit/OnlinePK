//
//  NETSPkEnum.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/9.
//  Copyright © 2021 Netease. All rights reserved.
//

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
    NETSPkTieResult                 // 平局
};

//麦位操作的枚举
typedef NS_ENUM(NSUInteger, NETSSeatsOperation) {
    //管理员同意上麦
    NETSSeatsOperationAdminAcceptJoinSeats = 1,
    //管理员主动邀请上麦
    NETSSeatsOperationAdminInviteJoinSeats = 2,
    //管理员踢下麦
    NETSSeatsOperationAdminKickSeats = 3,
    //上麦者下麦
    NETSSeatsOperationWheatherLeaveSeats = 4,
    //观众申请上麦
    NETSSeatsOperationAudienceApplyJoinSeats = 5,
    //观众取消上麦申请
    NETSSeatsOperationAudienceCancelApplyJoinSeats = 6,
    //管理员拒绝观众上麦申请
    NETSSeatsOperationAdminRejectAudienceApply = 7,
    //观众拒绝同意上麦
    NETSSeatsOperationAudienceRejectJoinSeats = 8,
    //观众同意上麦
    NETSSeatsOperationAudienceAcceptJoinSeats = 9,
    //管理员取消屏蔽麦位
    NETSSeatsOperationAdminReopenSeats = 10,
    //管理员屏蔽麦位
    NETSSeatsOperationAdminCloseSeats = 11,
    //麦位音视频变化
    NETSSeatsOperationAVChange = 12,
    //观众上麦成功
    NETSSeatsOperationAudienceJoinSeatsSuccess = 13
};

//麦位通知协议type
typedef NS_ENUM(NSUInteger, NETSSeatsNotification) {
    //管理员同意上麦
    NETSSeatsNotificationAdminAcceptJoinSeats = 3001,
    //管理员主动邀请上麦
    NETSSeatsNotificationAdminInviteJoinSeats = 3002,
    //管理员踢下麦
    NETSSeatsNotificationAdminKickSeats = 3003,
    //上麦者下麦
    NETSSeatsNotificationWheatherLeaveSeats = 3004,
    //观众申请上麦
    NETSSeatsNotificationAudienceApplyJoinSeats = 3005,
    //观众取消上麦申请
    NETSSeatsNotificationAudienceCancelApplyJoinSeats = 3006,
    //管理员拒绝观众上麦申请
    NETSSeatsNotificationAdminRejectAudienceApply = 3007,
    //观众拒绝同意上麦
    NETSSeatsNotificationAudienceRejectJoinSeats = 3008,
    //观众同意上麦
    NETSSeatsNotificationAudienceAcceptJoinSeats = 3009,
    //管理员取消屏蔽麦位
    NETSSeatsNotificationAdminReopenSeats = 3010,
    //管理员屏蔽麦位
    NETSSeatsNotificationAdminCloseSeats = 3011,
    //麦位音视频变化
    NETSSeatsNotificationAVChange = 3012,
    //观众上麦成功
    NETSSeatsNotificationAudienceJoinSeatsSuccess = 3013
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
#endif /* NETSPkEnum_h */
