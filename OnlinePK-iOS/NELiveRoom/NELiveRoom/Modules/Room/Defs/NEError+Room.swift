//
//  NEError+Room.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/15.
//

import Foundation

extension NSError {
    
    static var notInRoomError: NSError {
        NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorNotInRoom, userInfo: [NSLocalizedDescriptionKey: NELiveRoomErrorNotInRoomDescription])
    }
    
}
