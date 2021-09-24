//
//  NESeatLeaveEvent.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/26.
//

import Foundation

@objc
open class NESeatLeaveEvent: NSObject {
    
    /// 坐席信息
    @objc
    public var seatInfo: NESeatInfo!
    
    /// 责任者，主动离开等同于userInfo，被踢则为管理员
    @objc
    public var responder: NERoomUserInfo!
    
    /// 离开原因
    @objc
    public var reason: NESeatInfoChangeReason = .normal
    
    //avRoom相关信息(pk连麦)
    @objc
    public var avRoomUser:NEAvRoomUserDetail!
    
    /// 附件信息
    @objc
    public var attachment: String?
    
}
