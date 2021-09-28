//
//  NESeatPickRequestCancelEvent.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/26.
//

import Foundation

@objc
open class NESeatPickRequestCancelEvent: NSObject {
    
    /// 请求标识
    @objc
    public var requestId: String!
    
    /// 序号
    @objc
    public var seatInfo: NESeatInfo!
    
    /// 申请者
    @objc
    public var applicant: NERoomUserInfo!
    
    /// 附件信息
    @objc
    public var attachment: String?
    
}
