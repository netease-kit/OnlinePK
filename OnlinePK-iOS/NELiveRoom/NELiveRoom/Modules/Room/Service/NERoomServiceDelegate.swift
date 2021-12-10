//
//  NERoomServiceDelegate.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
public protocol NERoomServiceDelegate: NSObjectProtocol {
    
    /// 用户加入房间事件
    /// @param event 事件
    @objc
    func onUserEntered(_ event: NEUserEnterRoomEvent)
    
    /// 用户离开房间事件
    /// @param event 事件
    @objc
    func onUserLeft(_ event: NEUserLeaveRoomEvent)
    
    /// 房间销毁事件
    /// @param event 事件
    @objc
    func onRoomDestroyed(_ event: NERoomDestroyEvent)
    
    /// 房间人数变化事件
    @objc
    func onUserCountChange(_ count: Int)
    
}
