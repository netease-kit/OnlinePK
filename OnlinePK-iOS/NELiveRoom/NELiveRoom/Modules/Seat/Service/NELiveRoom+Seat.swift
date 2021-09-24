//
//  NELiveRoom+Seat.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/7.
//

import Foundation

public extension NELiveRoom {
    
    @objc
    var seatService: NESeatServiceProtocol {
        var service = NELiveRoom.shared.service(for: NESeatServiceProtocol.self) as? NESeatServiceProtocol
        if service == nil {
            service = NESeatService()
            NELiveRoom.shared.register(service, for: NESeatServiceProtocol.self)
        }
        guard NIMSDK.shared().loginManager.currentAccount() != "" else {
            return NESeatServiceNotLoginedStub(client: service!)
        }
        guard NELiveRoom.shared.roomService.currentRoom?.roomId != nil else {
            return NESeatServiceNotInRoomStub(client: service!)
        }
        return service!
        
    }
    
}
