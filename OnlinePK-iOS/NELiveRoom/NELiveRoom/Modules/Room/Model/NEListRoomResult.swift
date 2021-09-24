//
//  NEListRoomResult.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/17.
//

import Foundation

@objc
open class NEListRoomResult: NSObject {
    
    /// 列表
    @objc
    public var list: [NERoomInfo]?

    /// 是否是最后一页
    @objc
    public var isLastPage: Bool = false
    
    /// 初始化
    init(dictionary: [AnyHashable: Any]) {
        super.init()
        self.isLastPage = dictionary["isLastPage"] as? Bool ?? false
        self.list = []
        if let dicList = dictionary["list"] as? [[AnyHashable: Any]] {
            for dic in dicList {
                self.list?.append(NERoomInfo(dictionary: dic))
            }
        }
    }
}
