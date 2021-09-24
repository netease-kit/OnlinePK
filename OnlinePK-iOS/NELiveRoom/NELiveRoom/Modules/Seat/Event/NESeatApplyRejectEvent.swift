//
//  NESeatApplyRejectEvent.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/26.
//

import Foundation

@objc
open class NESeatApplyRejectEvent: NSObject {
    
    /// 请求标识
    @objc
    public var requestId: String!
    
    /// 回应者
    @objc
    public var respondor: NERoomUserInfo!
    
    /// 对应坐席
    @objc
    public var seatInfo: NESeatInfo!
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatApplyRejected()
    @objc
    public var attachment: String?
    
}
