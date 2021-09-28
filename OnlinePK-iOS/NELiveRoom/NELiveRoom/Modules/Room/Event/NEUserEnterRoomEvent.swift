//
//  NEUserEnterRoomEvent.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NEUserEnterRoomEvent: NSObject {
    
    /// 房间信息
    @objc
    public var roomInfo: NERoomInfo?

    /// 加入房间的人，可能是多个
    @objc
    public var users: [NERoomUserInfo]?
    
    /// 附件信息
    @objc
    public var attachment: String?

}
