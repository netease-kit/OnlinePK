//
//  NESeatServiceDefs.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

/// 加入坐席回调
/// @param error 错误信息，成功则为nil
public typealias NEEnterSeatCompletion = (Error?) -> Void

/// 获取坐席信息回调
public typealias NEFetchSeatInfoCompletion = ([NESeatInfo]?, Error?) -> Void

/// 离开坐席回调
/// @param error 错误信息，成功则为nil
public typealias NELeaveSeatCompletion = (Error?) -> Void

/// 踢出坐席回调
/// @param error 错误信息，成功则为nil
public typealias NEKickSeatCompletion = (Error?) -> Void

/// 申请坐席回调
/// @param error 错误信息，成功则为nil
public typealias NEApplySeatCompletion = (NESeatApplyResponse?, Error?) -> Void

/// 同意申请坐席回调
/// @param error 错误信息，成功则为nil
public typealias NEAcceptSeatApplyCompletion = (Error?) -> Void

/// 拒绝申请坐席回调
/// @param error 错误信息，成功则为nil
public typealias NERejectSeatApplyCompletion = (Error?) -> Void

/// 取消申请坐席回调
/// @param error 错误信息，成功则为nil
public typealias NECancelSeatApplyCompletion = (Error?) -> Void

/// 申请上坐席的回调
/// @param error 错误信息，成功则为nil
public typealias NEPickSeatCompletion = (NESeatPickResponse?, Error?) -> Void

/// 同意报麦申请的回调
/// @param error 错误信息，成功则为nil
public typealias NEAcceptSeatPickCompletion = (Error?) -> Void

/// 拒绝申请上坐席的回调
/// @param error 错误信息，成功则为nil
public typealias NERejectSeatPickCompletion = (Error?) -> Void

/// 取消申请上坐席的回调
/// @param error 错误信息，成功则为nil
public typealias NECancelSeatPickCompletion = (Error?) -> Void

/// 设置坐席视频静音状态回调
/// @param error 错误信息，成功则为nil
public typealias NESetSeatVideoStateCompletion = (Error?) -> Void

/// 设置坐席音频静音状态回调
/// @param error 错误信息，成功则为nil
public typealias NESetSeatAudioStateCompletion = (Error?) -> Void

/// 设置坐席音频静音状态回调
/// @param error 错误信息，成功则为nil
public typealias NESetSeatOpenStateCompletion = (Error?) -> Void

/// 设置坐席自定义信息回调
/// @param error 错误信息，成功则为nil
public typealias NESetSeatCustomInfoCompletion = (Error?) -> Void

// 麦序操作类型定义
@objc
public enum NESeatAction: Int {
    case acceptApply = 1         // 管理员同意上麦
    case pick = 2                // 管理员抱人上麦
    case kick = 3                // 管理员踢下麦
    case leave = 4               // 上麦者下麦
    case apply = 5               // 观众申请上麦
    case cancelApply = 6         // 观众取消上麦申请
    case rejectApply = 7         // 管理员拒绝观众上麦申请
    case rejectPick = 8          // 观众拒绝抱麦
    case cancelPick = 9          // 管理员取消抱麦申请
    case acceptPick = 10         // 观众同意抱麦
}

/// 麦序事件类型定义
@objc
public enum NESeatEvent: Int {
    case unkwnown = 0               ///< 未知，不可用
    case acceptApply = 3001         ///< 管理员同意上麦
    case pick = 3002                ///< 管理员抱人上麦
    case leave = 3004               ///< 上麦者下麦
    case apply = 3005               ///< 观众申请上麦
    case cancelApply = 3006         ///< 观众取消上麦申请
    case rejectApply = 3007         ///< 管理员拒绝观众上麦申请
    case rejectPick = 3008          ///< 观众拒绝抱麦
    case cancelPick = 3009          ///< 管理员取消抱麦申请
    case acceptPick = 3010          ///< 观众同意抱麦
    case audioChange = 3011         ///< 麦位音频变化
    case videoChange = 3012         ///< 麦位视频变化
    case stateChange = 3013         ///< 麦位状态变更
    case enter = 3014           ///< 观众上麦成功
    case customInfoChange = 3015    ///< 用户自定义信息变更
}

/// 变更原因
@objc
public enum NESeatInfoChangeReason: Int {
    case normal = 0     // 正常
    case timeout = 101  // 锁定超时
    case kickout = 102  // 被踢
}
