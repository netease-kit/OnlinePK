//
//  NERoomServiceProtocol.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
public protocol NERoomAPIServiceProtocol: NSObjectProtocol {
    
    /// 当前房间，如果没有房间则为nil
    @objc
    var currentRoom: NERoomDetail? { get set}
    
    /// 当前用户，创建房间或加入房间后由server返回
    @objc
    var currentUser: NERoomUserDetail? { get }

    /// 创建房间
    /// @param params 参数 @see NECreateRoomParams
    /// @param completion 回调
    @objc
    func createRoom(_ params: NECreateRoomParams, completion: NECreateRoomCompletion?)

    /// 销毁房间，成功后会触发NERoomServiceDelegate#onRoomDestroyed()
    /// @param params 参数 @see NEDestroyRoomParams
    /// @param completion 回调
    @objc
    func destroyRoom(_ params: NEDestroyRoomParams, completion: NEDestroyRoomCompletion?)
    
    /// 加入房间，成功后触发NERoomServiceDelegate#onUserEnterRoom()
    /// @param params 参数 @see NEEnterRoomParams
    /// @param completion 回调
    @objc
    func enterRoom(_ params: NEEnterRoomParams, completion: NEEnterRoomCompletion?)
    
    /// 离开房间，成功后触发NERoomServiceDelegate#onUserLeaveRoom()
    /// @param params 参数 @see NELeaveRoomParams
    /// @param completion 回调
    @objc
    func leaveRoom(_ params: NELeaveRoomParams, completion: NELeaveRoomCompletion?)
    
    /// 获取房间列表
    /// @param params 参数 @see NEListRoomParams
    /// @param completion 回调
    @objc
    func listRooms(_ params: NEListRoomParams, completion: NEListRoomCompletion?)
    
}

@objc
public protocol NERoomServiceProtocol: NERoomAPIServiceProtocol {
    
    /// 添加事件代理
    /// @param delegate 需要添加的代理对象
    @objc(addDelegate:)
    func add(delegate: NERoomServiceDelegate)

    /// 移除事件回调
    /// @param delegate 需要移除的代理对象
    @objc(removeDelegate:)
    func remove(delegate: NERoomServiceDelegate)
    
}
