//
//  NEEnterRoomParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NEEnterRoomParams: NELiveBaseParams {
    
    /// 房间Id，必填
    @objc
    public var roomId: String?
    
    /// 用户名
    @objc
    public var userName: String?
    
    /// 用户头像URL
    @objc
    public var avatarURL: URL?
    
    /// 用户自定义扩展字段
    @objc
    public var customInfo: String?
    
    /// 附件信息，透传到 - onUserEnterRoom
    /// @see NEEnterRoomEvent
    @objc
    public var attachment: String?
    
    /// 初始化
    @objc
    public override init() {
        super.init()
        self.version = "v2"
    }
    
}
