//
//  NELiveRoomOptions.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/31.
//

import Foundation

open class NELiveRoomOptions: NSObject {
    
    /// app key，必填字段
    @objc
    public var appKey: String
    
    /// api host，必填字段
    @objc
    public var apiHost: String
    
    /// 校验字段
    @objc
    public var accessToken: String?
    
    /// 初始化方法
    @objc public init(appKey: String, apiHost: String) {
        self.appKey = appKey
        self.apiHost = apiHost
        super.init()
    }
    
}
