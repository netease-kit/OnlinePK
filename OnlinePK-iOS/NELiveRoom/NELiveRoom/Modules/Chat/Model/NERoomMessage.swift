//
//  NERoomMessage.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/16.
//

import Foundation

@objc
open class NERoomMessage: NSObject {
    
    /// 文本内容
    @objc
    public var text: String!
    
    /// 发送者
    @objc
    public var sender: NERoomUserInfo!
    
    /// 扩展信息
    @objc
    public var customInfo: [AnyHashable: Any]?
    
}
