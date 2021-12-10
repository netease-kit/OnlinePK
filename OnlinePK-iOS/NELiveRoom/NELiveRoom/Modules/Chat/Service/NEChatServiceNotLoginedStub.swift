//
//  NEChatServiceNotLoginedStub.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/15.
//

import Foundation

class NEChatServiceNotLoginedStub: NSObject, NEChatServiceProtocol {

    fileprivate weak var client: NEChatServiceProtocol?
    
    internal init(client: NEChatServiceProtocol) {
        self.client = client
        super.init()
    }
    
    func send(roomTextMessage text: String, attachment: [AnyHashable : Any]?, completion: NESendTextMessageCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    func add(delegate: NEChatServiceDelegate) {
        self.client?.add(delegate: delegate)
    }
    
    func remove(delegate: NEChatServiceDelegate) {
        self.client?.remove(delegate: delegate)
    }
    
}
