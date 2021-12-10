//
//  NEPickSeatParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NEPickSeatParams: NELiveBaseParams {
    
    /// 序号，不传代表由Server分配
    @objc
    public var seatIndex: Int = -1
    
    /// 需要抱上的用户，必填
    @objc
    public var userId: String?
    
    /// 附件信息NESeatServiceDelegate#onSeatPickRequest()
    @objc
    public var attachment: String?
    
}
