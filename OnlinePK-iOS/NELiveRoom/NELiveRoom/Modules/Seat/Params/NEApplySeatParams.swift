//
//  NEApplySeatParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NEApplySeatParams: NELiveBaseParams {
    
    /// 坐席序号，-1代表server分配
    @objc
    public var index: Int = -1
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatApplyRequest()
    /// @see NESeatApplyRequestEvent
    @objc
    public var attachment: String?
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatEntered()
    /// @see NESeatEnterEvent
    @objc
    public var enterAttachment: String?
    
}
