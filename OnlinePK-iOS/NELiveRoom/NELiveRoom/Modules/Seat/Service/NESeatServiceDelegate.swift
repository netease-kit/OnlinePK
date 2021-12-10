//
//  NESeatServiceDelegate.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/26.
//

import Foundation

@objc
public protocol NESeatServiceDelegate: NSObjectProtocol {
    
    /// 坐席加入事件
    /// @param event 事件
    @objc
    func onSeatEntered(_ event: NESeatEnterEvent)
    
    /// 坐席离开事件
    /// @param event 事件
    @objc
    func onSeatLeft(_ event: NESeatLeaveEvent)
    
    /// 坐席申请事件
    /// @param event 事件
    @objc
    func onSeatApplyRequest(_ event: NESeatApplyRequestEvent)
    
    /// 坐席申请取消事件
    /// @param event 事件
    @objc
    func onSeatApplyRequestCanceled(_ event: NESeatApplyRequestCancelEvent)
    
    /// 坐席申请同意事件
    /// @param event 事件
    @objc
    func onSeatApplyAccepted(_ event: NESeatApplyAcceptEvent)
    
    /// 坐席申请拒绝事件
    /// @param event 事件
    @objc
    func onSeatApplyRejected(_ event: NESeatApplyRejectEvent)
    
    /// 抱上坐席申请事件
    /// @param event 事件
    @objc
    func onSeatPickRequest(_ event: NESeatPickRequestEvent)
    
    /// 抱上坐席同意事件
    /// @param event 事件
    @objc
    func onSeatPickAccepted(_ event: NESeatPickAcceptEvent)
    
    /// 抱上坐席拒绝事件
    /// @param event 事件
    @objc
    func onSeatPickRejected(_ event: NESeatPickRejectEvent)
    
    /// 抱上坐席申请取消事件
    /// @param event 事件
    @objc
    func onSeatPickRequestCanceled(_ event: NESeatPickRequestCancelEvent)
    
    /// 坐席视频静音状态回调
    /// @param event 事件
    @objc
    func onSeatVideoStateChanged(_ event: NESeatVideoStateChangeEvent)
    
    /// 坐席音频静音状态回调
    /// @param event 事件
    @objc
    func onSeatAudioStateChanged(_ event: NESeatAudioStateChangeEvent)
    
    /// 坐席开关状态回调
    /// @param event 事件
    @objc
    func onSeatStateChanged(_ event: NESeatStateChangeEvent)
    
    /// 坐席自定义信息改变回调
    /// @param event 事件
    @objc
    func onSeatCustomInfoChanged(_ event: NESeatCustomInfoChangeEvent)
    
}
