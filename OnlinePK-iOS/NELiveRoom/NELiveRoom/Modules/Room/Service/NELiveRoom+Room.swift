//
//  NELiveRoom+Room.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/7.
//

import Foundation

public extension NELiveRoom {
    
    @objc
    var roomService: NERoomServiceProtocol {
        var service = NELiveRoom.shared.service(for: NERoomServiceProtocol.self) as? NERoomServiceProtocol
        if service == nil {
            service = NERoomService()
            NELiveRoom.shared.register(service, for: NERoomServiceProtocol.self)
        }
        guard NIMSDK.shared().loginManager.currentAccount() != "" else {
            return NERoomServiceNotLoginedStub(client: service!)
        }
        return service!
        
    }
   
}
