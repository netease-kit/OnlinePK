//
//  NERoomDestroyEvent.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NERoomDestroyEvent: NSObject {
    
    /// 房间信息
    @objc
    public var roomInfo: NERoomInfo?
    
}
