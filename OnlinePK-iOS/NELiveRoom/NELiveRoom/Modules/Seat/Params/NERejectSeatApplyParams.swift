//
//  NERejectSeatApplyParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NERejectSeatApplyParams: NELiveBaseParams {
    
    /// 请求标识
    @objc
    public var requestId: String?
    
    /// 坐席序号
    @objc
    public var seatIndex: Int = -1
    
    /// 需要拒绝上麦的用户id，必填
    @objc
    public var userId: String?
    
    /// JSON扩展，透传到NESeatServiceDelegate#onSeatApplyRejected()
    @objc
    public var attachment: String?
    
}
