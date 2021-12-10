//
//  NESeatStateChangeEvent.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/26.
//

import Foundation

@objc
open class NESeatStateChangeEvent: NSObject {
    
    /// 操作者
    public var responder: NERoomUserInfo!
    
    /// 坐席信息集合
    public var seatInfos: NESeatInfo!
    
    /// 附件信息
    public var attachment: String?
    
}
