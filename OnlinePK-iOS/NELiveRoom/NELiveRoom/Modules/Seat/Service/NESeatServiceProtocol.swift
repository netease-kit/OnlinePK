//
//  NESeatServiceProtocol.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
public protocol NESeatAPIServiceProtocol: NSObjectProtocol {
    
    /// 获取坐席信息
    @objc
    func fetchSeatInfos(completion: NEFetchSeatInfoCompletion?)
    
    /// 加入坐席，加入成功后触发NESeatServiceDelegate#onSeatEntered()
    /// @param params 参数
    /// @param completion 回调
    @objc
    func enterSeat(_ params: NEEnterSeatParams, completion: NEEnterSeatCompletion?)
    
    /// 离开坐席，离开成功后触发NESeatServiceDelegate#onSeatLeft()
    /// @param params 参数
    /// @param completion 回调
    @objc
    func leaveSeat(_ params: NELeaveSeatParams, completion: NELeaveSeatCompletion?)
    
    /// 踢出坐席，成功后触发NESeatServiceDelegate#onSeatLeft()
    /// @param params 参数@see NEKickSeatParams
    /// @param completion 回调
    @objc
    func kickSeat(_ params: NEKickSeatParams, completion: NEKickSeatCompletion?)
    
    /// 申请坐席，成功后触发NESeatServiceDelegate#onSeatApplyRequest()
    /// @param params 参数
    /// @param completion 回调
    @objc
    func applySeat(_ params: NEApplySeatParams, completion: NEApplySeatCompletion?)
    
    /// 同意申请坐席
    /// @param params 参数
    /// @param completion 回调
    @objc
    func acceptSeatApply(_ params: NEAcceptSeatApplyParams, completion: NEAcceptSeatApplyCompletion?)
    
    /// 拒绝申请坐席
    /// @param params 参数
    /// @param completion 回调
    @objc
    func rejectSeatApply(_ params: NERejectSeatApplyParams, completion: NERejectSeatApplyCompletion?)
    
    /// 取消申请坐席
    /// @param params 参数
    /// @param completion 回调
    @objc
    func cancelSeatApply(_ params: NECancelSeatApplyParams, completion: NECancelSeatApplyCompletion?)
    /// 抱上坐席申请
    /// @param params 参数
    /// @param completion 回调
    @objc
    func pickSeat(_ params: NEPickSeatParams, completion: NEPickSeatCompletion?)
    
    /// 同意抱上坐席申请
    /// @param params 参数
    /// @param completion 回调
    @objc
    func acceptSeatPick(_ params: NEAcceptSeatPickParams, completion: NEAcceptSeatPickCompletion?)
    
    /// 拒绝抱上坐席申请
    /// @param params 参数
    /// @param completion 回调
    @objc
    func rejectSeatPick(_ params: NERejectSeatPickParams, completion: NERejectSeatPickCompletion?)
    
    /// 取消抱上坐席申请
    /// @param params 参数
    /// @param completion 回调
    @objc
    func cancelSeatPick(_ params: NECancelSeatPickParams, completion: NECancelSeatPickCompletion?)

    /// 设置坐席视频静音状态，成功后触发NESeatServiceDelegate#onSeatVideoStateChanged()
    /// @param params 参数
    /// @param completion 回调
    @objc
    func setSeatVideoState(_ params: NESetSeatVideoStateParams, completion: NESetSeatVideoStateCompletion?)

    /// 设置坐席音频静音状态，成功后触发NESeatServiceDelegate#onSeatAudioStateChanged()
    /// @param params 参数
    /// @param completion 回调
    @objc
    func setSeatAudioState(_ params: NESetSeatAudioStateParams, completion: NESetSeatAudioStateCompletion?)

    /// 设置坐席开关状态，成功后触发NESeatServiceDelegate#onSeatStateChanged()
    /// @param params 参数
    /// @param completion 回调
    @objc
    func setSeatOpenState(_ params: NESetSeatOpenStateParams, completion: NESetSeatOpenStateCompletion?)

    /// 设置坐席自定义信息，成功后触发NESeatServiceDelegate#onSeatCustomInfoChanged()
    /// @param params 参数
    /// @param completion 回调
    @objc
    func setSeatCustomInfo(_ params: NESetSeatCustomInfoParams, completion: NESetSeatCustomInfoCompletion?)
    
}

@objc
public protocol NESeatServiceProtocol: NESeatAPIServiceProtocol {
    
    /// 添加事件代理
    /// @param delegate 需要添加的代理对象
    @objc(addDelegate:)
    func add(delegate: NESeatServiceDelegate)

    /// 移除事件回调
    /// @param delegate 需要移除的代理对象
    @objc(removeDelegate:)
    func remove(delegate: NESeatServiceDelegate)
    
}
