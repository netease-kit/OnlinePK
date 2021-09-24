//
//  NESeatApplyAcceptEvent.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/26.
//

import Foundation

@objc
open class NESeatApplyAcceptEvent: NSObject {
    
    /// 请求标识
    @objc
    public var requestId: String!
    
    /// 对应坐席
    @objc
    public var seatInfo: NESeatInfo!
    
    /// 回应者
    @objc
    public var respondor: NERoomUserInfo!
    
    
    //avRoom相关信息(pk连麦)
    @objc
    public var avRoomUser:NEAvRoomUserDetail!
    
    /// 附件信息，acceptSeatApply时传入的JSON扩展
    @objc
    public var attachment: String?
    
}
