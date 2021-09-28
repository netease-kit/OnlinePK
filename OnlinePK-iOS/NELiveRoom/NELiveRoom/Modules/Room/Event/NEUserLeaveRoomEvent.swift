//
//  NEUserLeaveRoomEvent.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
public enum NEUserLeaveRoomReason: Int {
    case normal = 0
    case kickout = 1
}

@objc
open class NEUserLeaveRoomEvent: NSObject {
    
    /// 房间信息
    @objc
    public var roomInfo: NERoomInfo?

    /// 退出房间的人，可能是多个
    @objc
    public var users: [NERoomUserInfo]?
    
    /// 原因
    @objc
    public var reason: NEUserLeaveRoomReason = .normal
    
    /// 附件信息
    @objc
    public var attachment: String?

}
