//
//  NESetSeatOpenStateParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NESetSeatOpenStateParams: NELiveBaseParams {
    
    /// 序号集合，必填
    @objc
    public var index: Int = -1
    
    /// 需要设置的状态，必填
    @objc
    public var `open`: Bool = false
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatOpenStateChanged()
    @objc
    public var attachment: String?
    
}
