//
//  NEEnterSeatParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NEEnterSeatParams: NELiveBaseParams {
    
    /// 序号，不传代表由server分配
    @objc
    public var index: Int = -1
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatEntered()
    /// @see NESeatEnterEvent
    @objc
    public var attachment: String?
    
}
