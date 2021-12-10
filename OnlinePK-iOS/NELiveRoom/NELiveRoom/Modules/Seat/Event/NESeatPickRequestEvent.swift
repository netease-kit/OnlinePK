//
//  NESeatPickRequestEvent.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/26.
//

import Foundation

@objc
open class NESeatPickRequestEvent: NSObject {
    
    /// 请求唯一标识
    @objc
    public var requestId: String!
    
    /// 坐席信息
    @objc
    public var seatInfo: NESeatInfo!
    
    /// 发起者，如房主
    @objc
    public var applicant: NERoomUserInfo!
    
    //room相关信息
    @objc
    public var avRoomUser:NEAvRoomUserDetail!
    /// 附件信息
    @objc
    public var attachment: String?
    
}
