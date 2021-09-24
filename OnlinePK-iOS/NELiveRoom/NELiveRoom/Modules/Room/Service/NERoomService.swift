//
//  NERoomService.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/27.
//

import Foundation

/// 退出SDK房间回调
fileprivate typealias NEExitSDKRoomCompletion = (Error?) -> Void

@objc
class NERoomService: NERoomAPIService,NERoomServiceProtocol,NIMChatManagerDelegate,NIMChatroomManagerDelegate {
    
    private var liveStreamTask: NERtcLiveStreamTaskInfo?
    
    fileprivate var roomId: String {
        return self.currentRoom!.roomId!
    }
    
    fileprivate var isCreator: Bool {
        guard let currentUser = self.currentUser, let currentRoom = self.currentRoom else { return false }
        return currentRoom.creatorId == currentUser.accountId
    }
    
    override init() {
        super.init()
        NIMSDK.shared().chatManager.add(self)
        NIMSDK.shared().chatroomManager.add(self)
        NELiveRoomDelegateProxy.shared().add(delegate: self.engineCompat)
    }
    
    deinit {
        NIMSDK.shared().chatroomManager.remove(self)
        NIMSDK.shared().chatManager.remove(self)
        NELiveRoomDelegateProxy.shared().remove(delegate: self.engineCompat)
    }
    
    fileprivate var delegateProxy = NELiveRoomDelegateProxy() as! NERoomServiceDelegate & NELiveRoomDelegateProxy
    fileprivate let completionQueue = DispatchQueue.main
    fileprivate let engineCompat = NERtcEngineCompat()
    
    override func createRoom(_ params: NECreateRoomParams, completion: NECreateRoomCompletion?) {
        super.createRoom(params) { (roomInfo, userInfo, error) in
            if let error = error {
                completion?(nil, nil, error)
                return
            }
            self.joinSDKRoom(roomInfo, userInfo, nil, true) {[weak self] (roomInfo, userInfo, error) in
                let isCDN = self?.currentRoom?.pushType == .CDN
                if isCDN {
                    let task = NERtcLiveStreamTaskInfo()
                    task.serverRecordEnabled = false
                    task.streamURL = self?.currentRoom?.pushURL?.absoluteString ?? ""
                    task.lsMode = .lsModeAudio
                    task.taskID = String(arc4random()/100)
                    let layout = NERtcLiveStreamLayout()
                    layout.backgroundColor = 0
                    layout.width = 720
                    layout.height = 1280
                    let myTranscoding = NERtcLiveStreamUserTranscoding()
                    myTranscoding.videoPush = false
                    myTranscoding.audioPush = true
                    myTranscoding.uid = self?.currentUser?.uid ?? 0
                    layout.users = [myTranscoding]
                    task.layout = layout
                    let ret = NERtcEngine.shared().addLiveStreamTask(task) { (taskId, errorCode) in
                        let error = errorCode.rawValue == 0 ? nil : NSError(domain: NELiveRoomErrorDomain, code: Int(errorCode.rawValue), userInfo: [NSLocalizedDescriptionKey: "推流失败：\(errorCode)"])
                        completion?(roomInfo, userInfo, error)
                    }
                    if ret != 0 {
                        print("NERoomService: create add live stream with error \(NERtcErrorDescription(ret))")
                    }
                    self?.liveStreamTask = task
                } else {
                    completion?(roomInfo, userInfo, nil)
                }
            }
        }
    }
    
    override func enterRoom(_ params: NEEnterRoomParams, completion: NEEnterRoomCompletion?) {
        super.enterRoom(params) { (roomInfo, userInfo, error) in
            if let error = error {
                completion?(nil, nil, error)
                return
            }
            self.joinSDKRoom(roomInfo, userInfo, params.attachment, false) {[weak self] (roomInfo, userInfo, error) in
                if let chatroomId = roomInfo?.chatroomId {
                    NIMSDK.shared().chatroomManager.fetchChatroomInfo(chatroomId) { (error, chatroom) in
                        if let chatroom = chatroom {
                            self?.delegateProxy.onUserCountChange(chatroom.onlineUserCount)
                        }
                        completion?(self?.currentRoom, self?.currentUser, nil)
                    }
                } else {
                    completion?(self?.currentRoom, self?.currentUser, nil)
                }
            }
        }
    }
    
    override func leaveRoom(_ params: NELeaveRoomParams, completion: NELeaveRoomCompletion?) {
        let chatroomId = self.currentRoom?.chatroomId
        super.leaveRoom(params) { (error) in
            if let error = error {
                completion?(error)
                return
            }
            self.exitSDKRoom(chatroomId) { (error) in
                completion?(error)
            }
        }
    }
    
    override func destroyRoom(_ params: NEDestroyRoomParams, completion: NEDestroyRoomCompletion?) {
        super.destroyRoom(params) {[weak self] (error) in
            if let error = error {
                completion?(error)
                return
            }
            self?.exitSDKRoom(nil) { (error) in
                completion?(error)
            }
        }
    }
    
    fileprivate func joinSDKRoom(_ roomInfo: NERoomDetail?,
                                 _ userInfo: NERoomUserDetail?,
                                 _ attachment: String?,
                                 _ isCreator: Bool,
                                 _ completion: NEEnterRoomCompletion?) {
        guard let chatroomId = roomInfo?.chatroomId else {
            completion?(nil, nil, NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorInvalidParams, userInfo: [NSLocalizedDescriptionKey: "chatroomId不合法！！"]))
            return
        }
        guard let cname = roomInfo?.cname else {
            completion?(nil, nil, NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorInvalidParams, userInfo: [NSLocalizedDescriptionKey: "cname不合法！！"]))
            return
        }
        
        var outError: NSError?
        var chatroomError: NSError?
        var rtcError: NSError?
        
        let dispatchGroup = DispatchGroup()
        let request = NIMChatroomEnterRequest()
        request.roomId = chatroomId
        request.roomNickname = userInfo?.userName
        request.roomAvatar = userInfo?.avatarURL?.absoluteString
        request.roomExt = userInfo?.customInfo
        request.roomNotifyExt = attachment
        dispatchGroup.enter()
        NIMSDK.shared().chatroomManager.enterChatroom(request) { (error, room, me) in
            dispatchGroup.leave()
            chatroomError = error as NSError?
        }
        let shouldJoinRtc = roomInfo!.pushType == .RTC || isCreator
        if shouldJoinRtc {
            guard let myUid = self.currentUser?.uid else {
                NIMSDK.shared().chatroomManager.exitChatroom(chatroomId, completion: nil)
                completion?(nil, nil, NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorInvalidParams, userInfo: [NSLocalizedDescriptionKey: "uid不合法！！"]))
                return
            }
            let ret = NERtcEngine.shared().joinChannel(withToken: self.currentUser?.checksum ?? "", channelName: cname, myUid: myUid) { (error, cid, elapesd) in
                dispatchGroup.leave()
                rtcError = error as NSError?
            }
            if ret == 0 {
                dispatchGroup.enter()
            } else {
                rtcError = NSError(domain: NELiveRoomErrorDomain, code: Int(ret), userInfo: [NSLocalizedDescriptionKey: NERtcErrorDescription(ret)])
            }
            
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            if chatroomError != nil || rtcError != nil {
                outError = chatroomError ?? rtcError
                if chatroomError == nil {
                    NIMSDK.shared().chatroomManager.exitChatroom(chatroomId, completion: nil)
                }
                if rtcError == nil {
                    self.engineCompat.leaveChannel(nil)
                }
            }
            completion?(roomInfo, userInfo, outError)
        }
    }
    
    private func exitSDKRoom(_ chatroomId: String?, completion: (NEExitSDKRoomCompletion)?) {
        var chatroomError: NSError?
        var rtcError: NSError?
        
        let dispatchGroup = DispatchGroup()
        if let chatroomId = chatroomId {
            dispatchGroup.enter()
            NIMSDK.shared().chatroomManager.exitChatroom(chatroomId) { (error) in
                chatroomError = error as NSError?
                dispatchGroup.leave()
            }
        }
        dispatchGroup.enter()
        if let liveStreamTaskID = self.liveStreamTask?.taskID {
            NERtcEngine.shared().removeLiveStreamTask(liveStreamTaskID) { (taskID, errorCode) in
                self.engineCompat.leaveChannel { (error) in
                    if error != .kNERtcNoError {
                        rtcError = NSError(domain: NERtcRemoteErrorDomain, code: Int(error.rawValue), userInfo: [NSLocalizedDescriptionKey: NERtcErrorDescription(error.rawValue)])
                    }
                    dispatchGroup.leave()
                }
            }
        } else {
            self.engineCompat.leaveChannel { (error) in
                if error != .kNERtcNoError && error != .kNERtcErrChannelNotJoined {
                    rtcError = NSError(domain: NERtcRemoteErrorDomain, code: Int(error.rawValue), userInfo: [NSLocalizedDescriptionKey: NERtcErrorDescription(error.rawValue)])
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: self.completionQueue) {
            completion?(chatroomError ?? rtcError)
        }
    }
    
    func add(delegate: NERoomServiceDelegate) {
        self.delegateProxy.add(delegate: delegate)
    }
    
    func remove(delegate: NERoomServiceDelegate) {
        self.delegateProxy.remove(delegate: delegate)
    }
    
    func onRecvMessages(_ messages: [NIMMessage]) {
        guard let roomId = self.currentRoom?.chatroomId else {
            return
        }
        for msg in messages {
            guard msg.session?.sessionType == NIMSessionType.chatroom && msg.session?.sessionId == roomId && msg.messageType == .notification else {
                continue // 忽略非本房间的消息
            }
            self.handle(notificationMessage: msg)
        }
    }
    
    fileprivate func handle(notificationMessage message: NIMMessage) {
        guard let object = message.messageObject as? NIMNotificationObject, object.notificationType == .chatroom, let content = object.content as? NIMChatroomNotificationContent else {
            return
        }
        switch content.eventType {
        case .enter:
            let event = NEUserEnterRoomEvent()
            event.users = content.targets?.map{m in
                let userInfo = NERoomUserInfo()
                userInfo.accountId = m.userId
                userInfo.userName = m.nick
                return userInfo
            }
            if let chatroomId = self.currentRoom?.chatroomId {
                NIMSDK.shared().chatroomManager.fetchChatroomInfo(chatroomId) { (error, chatroom) in
                    self.delegateProxy.onUserEntered(event)
                    if let chatroom = chatroom {
                        self.delegateProxy.onUserCountChange(chatroom.onlineUserCount)
                    }
                }
            } else {
                self.delegateProxy.onUserEntered(event)
            }
            break
        case .exit, .kicked:
            let event = NEUserLeaveRoomEvent()
            event.users = content.targets?.map{m in
                let userInfo = NERoomUserInfo()
                userInfo.accountId = m.userId
                userInfo.userName = m.nick
                return userInfo
            }
            event.reason = content.eventType == .enter ? .normal : .kickout
            if let chatroomId = self.currentRoom?.chatroomId {
                NIMSDK.shared().chatroomManager.fetchChatroomInfo(chatroomId) { (error, chatroom) in
                    self.delegateProxy.onUserLeft(event)
                    if let chatroom = chatroom {
                        self.delegateProxy.onUserCountChange(chatroom.onlineUserCount)
                    }
                }
            } else {
                self.delegateProxy.onUserLeft(event)
            }
            break
        case .addMute, .removeMute:
            // TODO 这个有啥用
            break
        case .closed:
            // TODO 这个NM为什么没用
            break
        default:
            break
        }
    }
    
    func chatroomBeKicked(_ result: NIMChatroomBeKickedResult) {
        if result.reason == .invalidRoom && !self.isCreator {
            self.currentRoom?.chatroomId = nil
            let event = NERoomDestroyEvent()
            self.delegateProxy.onRoomDestroyed(event)
        }
    }
}
