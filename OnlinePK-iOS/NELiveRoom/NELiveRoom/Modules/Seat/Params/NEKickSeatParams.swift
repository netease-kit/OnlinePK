//
//  NEKickSeatParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NEKickSeatParams: NELiveBaseParams {
    
    /// 要踢的坐席序号，必填
    @objc
    public var index: Int = -1
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatLeft()
    /// @see NESeatLeaveEvent
    
    /// 需要操作的用户id，必填
    @objc
    public var userId: String?
    
    
    @objc
    public var attachment: String?
    
}
