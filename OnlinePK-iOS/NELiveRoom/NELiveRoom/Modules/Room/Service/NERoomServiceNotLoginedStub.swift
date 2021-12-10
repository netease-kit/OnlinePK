//
//  NERoomServiceNotLoginedStub.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/7.
//

import Foundation

open class NERoomServiceNotLoginedStub: NSObject, NERoomServiceProtocol {
    
    public var currentUser: NERoomUserDetail?
    
    public var currentRoom: NERoomDetail?

    fileprivate weak var client: NERoomServiceProtocol?
    
    internal init(client: NERoomServiceProtocol) {
        self.client = client
        super.init()
    }
    
    // MARK: Errors
    public func createRoom(_ params: NECreateRoomParams, completion: NECreateRoomCompletion?) {
        completion?(nil, nil, NSError.notLoginedError)
    }
    
    public func destroyRoom(_ params: NEDestroyRoomParams, completion: NEDestroyRoomCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func enterRoom(_ params: NEEnterRoomParams, completion: NEEnterRoomCompletion?) {
        completion?(nil, nil, NSError.notLoginedError)
    }
    
    public func leaveRoom(_ params: NELeaveRoomParams, completion: NELeaveRoomCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    // MARK: Forward to client
    public func listRooms(_ params: NEListRoomParams, completion: NEListRoomCompletion?) {
        self.client?.listRooms(params, completion: completion)
    }
    
    public func add(delegate: NERoomServiceDelegate) {
        self.client?.add(delegate: delegate)
    }
    
    public func remove(delegate: NERoomServiceDelegate) {
        self.client?.remove(delegate: delegate)
    }
    
}
