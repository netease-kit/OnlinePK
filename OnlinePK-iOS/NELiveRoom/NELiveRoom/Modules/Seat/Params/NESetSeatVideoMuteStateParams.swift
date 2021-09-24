//
//  NESetSeatVideoStateParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NESetSeatVideoStateParams: NELiveBaseParams {
    
    /// 序号集合，必填
    @objc
    public var index: Int = -1
    
    /// 需要设置的状态，必填
    public var state: Int?
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatVideoMuteStateChanged()
    public var attachment: String?
    
}
