//
//  NELeaveRoomParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NELeaveRoomParams: NELiveBaseParams {
    
    /// 附件信息，透传到 - onUserLeaveRoom
    /// @see NELeaveRoomEvent
    @objc
    public var attachment: String?
    
    /// 初始化
    @objc
    public override init() {
        super.init()
        self.version = "v2"
    }
    
}
