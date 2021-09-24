//
//  NELeaveSeatParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NELeaveSeatParams: NELiveBaseParams {
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatLeft()
    /// @see NESeatLeaveEvent
    @objc
    public var attachment: String?
    
}
