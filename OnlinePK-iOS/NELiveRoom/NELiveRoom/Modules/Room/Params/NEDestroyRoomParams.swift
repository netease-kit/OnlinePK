//
//  NEDestroyRoomParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
public class NEDestroyRoomParams: NELiveBaseParams {
    
    /// 房间Id，必填
    @objc
    public var roomId: String!
    
    /// 暂时无效
    /// @see NERoomDestroyEvent
    @objc
    public var attachment: String?
 
    /// 初始化方法
    public override init() {
        super.init()
        self.version = "v2"
    }
    
}
