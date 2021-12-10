//
//  NELiveRoom+Chat.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/15.
//

import Foundation

public extension NELiveRoom {
    
    @objc
    var chatService: NEChatServiceProtocol {
        var service = NELiveRoom.shared.service(for: NEChatServiceProtocol.self) as? NEChatServiceProtocol
        if service == nil {
            service = NEChatService()
            NELiveRoom.shared.register(service, for: NEChatServiceProtocol.self)
        }
        guard NIMSDK.shared().loginManager.currentAccount() != "" else {
            return NEChatServiceNotLoginedStub(client: service!)
        }
        guard NELiveRoom.shared.roomService.currentRoom?.roomId != nil else {
            return NEChatServiceNotInRoomStub(client: service!)
        }
        return service!
    }
    
}
