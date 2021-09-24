//
//  NESetSeatAudioStateParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NESetSeatAudioStateParams: NELiveBaseParams {
    
    /// 序号集合，必填
    @objc
    public var index: Int = -1
    
    /// 需要设置的状态，必填
    @objc
    public var state: NESeatAudioState = .closed
    
    /// 操作的用户id
    @objc
    public var userId: String?
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatAudioMuteStateChanged()
    @objc
    public var attachment: String?
    
}
