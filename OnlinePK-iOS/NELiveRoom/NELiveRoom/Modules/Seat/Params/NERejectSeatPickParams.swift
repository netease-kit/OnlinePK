//
//  NERejectSeatPickParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NERejectSeatPickParams: NELiveBaseParams {
    
    /// 请求标识，必填
    @objc
    public var requestId: String?
    
    /// 坐席序号
    @objc
    public var seatIndex: Int = -1
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatPickRejected()
    @objc
    public var attachment: String?
    
}
