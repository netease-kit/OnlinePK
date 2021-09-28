//
//  NERoomUserInfo.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NERoomUserInfo: NSObject {
    
    /// 用户唯一标识IM accid
    @objc
    public var accountId: String?
    
    /// 用户名
    @objc
    public var userName: String?
    
    /// 头像URL
    @objc
    public var avatarURL: URL?
    
    /// 自定义扩展字段
    @objc
    public var customInfo: String?

    @objc
    public override init() {
        super.init()
    }

    /// 初始化方法
    init(dictionary: [AnyHashable: Any?]) {
        super.init()
        self.accountId = dictionary["accountId"] as? String
        self.userName = dictionary["userName"] as? String
        if let avatar = dictionary["avatar"] as? String {
            self.avatarURL = URL(string: avatar)
        }
        self.customInfo = dictionary["customInfo"] as? String
    }
    
}
