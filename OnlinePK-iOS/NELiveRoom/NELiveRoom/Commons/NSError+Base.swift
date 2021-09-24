//
//  NELiveRoomErrors.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/15.
//

import Foundation

extension NSError {
    
    static var notLoginedError: NSError {
        NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorNotLogined, userInfo: [NSLocalizedDescriptionKey: NELiveRoomErrorNotLoginedDescription])
    }
    
}
