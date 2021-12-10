//
//  NEListRoomParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/17.
//

import Foundation

@objc
open class NEListRoomParams: NELiveBaseParams {
    
    /// 房间类型
    @objc
    public var roomType: NELiveRoomType = .chatroom
    
    /// 第几页
    @objc
    public var pageNumber: Int = 1
    
    /// 每页大小
    @objc
    public var pageSize: Int = 20
    
    /// 初始化
    @objc
    public override init() {
        super.init()
        self.version = "v2"
    }
    
}
