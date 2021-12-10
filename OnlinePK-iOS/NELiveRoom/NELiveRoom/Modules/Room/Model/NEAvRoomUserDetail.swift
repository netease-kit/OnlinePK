//
//  NEAvRoomUserDetail.swift
//  NELiveRoom
//
//  Created by vvj on 2021/8/31.
//

import Foundation

@objc
open class NEAvRoomUserDetail: NSObject {
    
    
    @objc
    public var avRoomCName: String?
    
    /// 音视频房间ID
    @objc
    public var avRoomUid: String?
    
    /// joinrtc所需token
    @objc
    public var avRoomCheckSum: String?
    
    /// 账号id
    @objc
    public var accountId: String?
    
    @objc
    public var channelId: String?
    
    /// 昵称
    @objc
    public var nickName: String?

    @objc
    override init() {
        super.init()
    }
    
    /// 初始化方法
    init(dictionary: [AnyHashable: Any?]) {
        super.init()
        self.avRoomCName = dictionary["avRoomCName"] as? String
        self.avRoomUid = dictionary["avRoomUid"] as? String
        self.avRoomCheckSum = dictionary["avRoomCheckSum"] as? String
        self.accountId = dictionary["accountId"] as? String
        self.channelId = dictionary["channelId"] as? String
        self.nickName = dictionary["nickName"] as? String
    }
    
}
