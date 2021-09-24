//
//  NESetSeatCustomInfoParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NESetSeatCustomInfoParams: NELiveBaseParams {
    
    /// 序号集合，必填
    @objc
    public var index: Int = -1
    
    /// 需要设置的自定义信息，必填
    @objc
    public var customInfo: String?
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatCustomInfoChanged()
    @objc
    public var attachment: String?
    
}
