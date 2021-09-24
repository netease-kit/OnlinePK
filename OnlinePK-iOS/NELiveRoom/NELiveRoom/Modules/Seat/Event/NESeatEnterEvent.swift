//
//  NESeatEnterEvent.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/26.
//

import Foundation

@objc
open class NESeatEnterEvent: NSObject {
    
    /// 坐席信息
    @objc
    public var seatInfo: NESeatInfo!
    
    /// 加入者
    @objc
    public var responder: NERoomUserInfo!
    
    //avRoom相关信息(pk连麦)
    @objc
    public var avRoomUser:NEAvRoomUserDetail!
    
    /// 附件信息
    @objc
    public var attachment: String?
    
}
