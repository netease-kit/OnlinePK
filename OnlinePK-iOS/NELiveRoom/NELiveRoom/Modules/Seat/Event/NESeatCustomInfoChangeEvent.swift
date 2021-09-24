//
//  NESeatCustomInfoChangeEvent.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/26.
//

import Foundation

@objc
open class NESeatCustomInfoChangeEvent: NSObject {
    
    /// 操作者
    @objc
    public var responder: NERoomUserInfo!
    
    /// 坐席信息集合
    @objc
    public var seatInfo: NESeatInfo!
    
    /// 附件信息
    @objc
    public var attachment: String?
    
}
