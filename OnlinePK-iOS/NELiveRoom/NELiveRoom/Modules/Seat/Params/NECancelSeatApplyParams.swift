//
//  NECancelSeatApplyParams.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
open class NECancelSeatApplyParams: NELiveBaseParams {
    
    /// 需要取消的请求标识，必填
    @objc
    public var requestId: String?
    
    @objc
    public var index: Int = -1
    
    /// 附件信息，透传到NESeatServiceDelegate#onSeatApplyRequestCanceled()
    @objc
    public var attachment: String?
    
}
