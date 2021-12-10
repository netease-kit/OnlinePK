//
//  NEAcceptSeatApplyParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NEAcceptSeatApplyParams: NELiveBaseParams {
    
    /// 请求唯一标识
    @objc
    public var requestId: String?
    
    /// 对应坐席序号，必填
    @objc
    public var seatIndex: Int = -1
    
    /// 需要同意上麦的用户id，必填
    @objc
    public var userId: String?
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatApplyAccepted()
    @objc
    public var attachment: String?
    
}
