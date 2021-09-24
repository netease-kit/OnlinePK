//
//  NEChatServiceProtocol.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/15.
//

import Foundation

@objc
public protocol NEChatServiceProtocol: NSObjectProtocol {
    
    /// 发送消息
    /// @param text 文本内容
    /// @param 扩展信息
    @objc(sendRoomTextMessage:attachment:completion:)
    func send(roomTextMessage text: String, attachment: [AnyHashable: Any]?, completion: NESendTextMessageCompletion?)
    
    /// 添加事件代理
    /// @param delegate 需要添加的代理对象
    @objc(addDelegate:)
    func add(delegate: NEChatServiceDelegate)

    /// 移除事件回调
    /// @param delegate 需要移除的代理对象
    @objc(removeDelegate:)
    func remove(delegate: NEChatServiceDelegate)
    
}
