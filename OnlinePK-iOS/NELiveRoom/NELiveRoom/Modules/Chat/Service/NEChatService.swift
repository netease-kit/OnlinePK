//
//  NEChatService.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/15.
//

import Foundation

class NEChatService: NSObject,NEChatServiceProtocol,NIMChatManagerDelegate {
    
    fileprivate var roomId: String {
        NELiveRoom.shared.roomService.currentRoom!.roomId!
    }
    
    override init() {
        super.init()
        NIMSDK.shared().chatManager.add(self)
    }
    
    deinit {
        NIMSDK.shared().chatManager.remove(self)
    }
    
    fileprivate var delegateProxy = NELiveRoomDelegateProxy() as! NEChatServiceDelegate & NELiveRoomDelegateProxy
    
    func send(roomTextMessage text: String, attachment: [AnyHashable : Any]?, completion: NESendTextMessageCompletion?) {
        let message = NIMMessage()
        message.text = text
        message.remoteExt = attachment
        let session = NIMSession(self.roomId, type: .chatroom)
        NIMSDK.shared().chatManager.send(message, to: session) { (error) in
            completion?(error as NSError?)
        }
    }
    
    func onRecvMessages(_ messages: [NIMMessage]) {
        
        var roomMsgs = [NERoomMessage]()
        
        for msg in messages {
            guard msg.session?.sessionType == NIMSessionType.chatroom && msg.session?.sessionId == roomId && msg.messageType == .text else {
                continue // 忽略非本房间的消息
            }
            
            guard let text = msg.text else {
                print("NERoomService: text is nil for message: \(msg.messageId)")
                continue
            }
            
            guard let messageExt = msg.messageExt as? NIMMessageChatroomExtension else {
                print("NERoomService: messageExt -> \(msg.messageExt ?? "") is not NIMMessageChatroomExtension")
                continue
            }
            
            let sender = NERoomUserInfo()
            sender.accountId = msg.from
            sender.avatarURL = (messageExt.roomAvatar != nil) ? URL(string: messageExt.roomAvatar!) : nil
            sender.userName = messageExt.roomNickname
            sender.customInfo = messageExt.roomExt
            
            let roomMsg = NERoomMessage()
            roomMsg.text = text
            roomMsg.sender = sender
            roomMsgs.append(roomMsg)
        }
        
        self.delegateProxy.onReceive(roomMessages: roomMsgs)

    }
    
    func add(delegate: NEChatServiceDelegate) {
        self.delegateProxy.add(delegate: delegate)
    }
    
    func remove(delegate: NEChatServiceDelegate) {
        self.delegateProxy.remove(delegate: delegate)
    }
    
}
