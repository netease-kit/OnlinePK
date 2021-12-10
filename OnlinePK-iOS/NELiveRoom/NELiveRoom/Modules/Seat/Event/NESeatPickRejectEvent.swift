//
//  NESeatPickRejectEvent.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/26.
//

import Foundation

@objc
open class NESeatPickRejectEvent: NSObject {
    
    /// 请求标识
    @objc
    public var requestId: String!
    
    /// 坐席信息
    @objc
    public var seatInfo: NESeatInfo!
    
    /// 操作者
    @objc
    public var responder: NERoomUserInfo!
    
    /// 附件信息
    @objc
    public var attachment: String?
    
}
