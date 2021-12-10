//
//  NERoomUserDetail.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/7/2.
//

import Foundation

@objc
public enum NERoomUserRole: Int {
    case broadcaster = 1   // 主播
    case audience = 2     // 观众
}

@objc
open class NERoomUserDetail: NSObject {
    
    /// 用户唯一标识IM accid
    @objc
    public var accountId: String?
    
    /// 用户名
    @objc
    public var userName: String?
    
    /// 头像URL
    @objc
    public var avatarURL: URL?
    
    /// 音视频uid
    @objc
    public var uid: UInt64 = 0
    
    /// 音视频安全模式token
    @objc
    public var checksum: String?
    
    /// 角色
    @objc
    public var role: NERoomUserRole = .audience
    
    /// 自定义扩展字段
    @objc
    public var customInfo: String?

    @objc
    override init() {
        super.init()
    }
    
    /// 初始化方法
    init(dictionary: [AnyHashable: Any?]) {
        super.init()
        self.accountId = dictionary["accountId"] as? String
        self.userName = dictionary["nickname"] as? String
        if let avatar = dictionary["avatar"] as? String {
            self.avatarURL = URL(string: avatar)
        }
        self.customInfo = dictionary["customInfo"] as? String
        if let roomUid = dictionary["roomUid"] as? UInt64 {
            self.uid = roomUid
        }
        if let role = dictionary["role"] as? Int {
            self.role = NERoomUserRole(rawValue: role) ?? .audience
        }
        self.checksum = dictionary["avRoomCheckSum"] as? String
    }
    
}
