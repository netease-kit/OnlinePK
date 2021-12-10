//
//  NEChatServiceDelegate.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/15.
//

import Foundation

@objc
public protocol NEChatServiceDelegate {
    
    /// 收到聊天室消息事件
    /// @param messages 消息对象
    @objc(onReceiveRoomMessages:)
    func onReceive(roomMessages messages: [NERoomMessage])
    
}
