//
//  NECreateRoomParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NECreateRoomParams: NELiveBaseParams {
    
    /// 标题，必填字段
    @objc
    public var title: String?
    
    /// 封面URL
    @objc
    public var coverURL: URL?
    
    /// 0: 旁路推流， 1：Rtc
    @objc
    public var pushType: NELiveRoomPushType = .RTC
    
    /// 自定义扩展
    @objc
    public var customInfo: String?
    
    /// 房间类型
    @objc
    public var roomType: NELiveRoomType = .chatroom
    
    /// 坐席限制，-1代表不传
    @objc
    public var seatLimit: Int = -1
    
    /// 用户限制，-1代表不传
    @objc
    public var userLimit: Int = -1
    
    /// 初始化
    @objc
    public override init() {
        super.init()
        self.version = "v2"
    }
    
}
