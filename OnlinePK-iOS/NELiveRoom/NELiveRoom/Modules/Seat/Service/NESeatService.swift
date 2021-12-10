//
//  NESeatService.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/26.
//

import Foundation

@objc
class NESeatService: NESeatAPIService,NESeatServiceProtocol,NIMPassThroughManagerDelegate {
    
    let engineCompat = NERtcEngineCompat()
    
    override init() {
        super.init()
        NIMSDK.shared().passThroughManager.add(self)
    }
    
    deinit {
        NIMSDK.shared().passThroughManager.remove(self)
    }
    
    fileprivate var roomId: String {
        NELiveRoom.shared.roomService.currentRoom!.roomId!
    }
    fileprivate var delegateProxy = NELiveRoomDelegateProxy() as! NESeatServiceDelegate & NELiveRoomDelegateProxy
    
    override func leaveSeat(_ params: NELeaveSeatParams, completion: NELeaveSeatCompletion?) {
        super.leaveSeat(params) { [weak self] (error) in
            guard error == nil else {
                completion?(error)
                return
            }
            
            if NELiveRoom.shared.rtcOption {
                let isCDN = NELiveRoom.shared.roomService.currentRoom?.pushType == .CDN
                if isCDN {
                    self?.engineCompat.leaveChannel { (error) in
                        completion?(nil)
                    }
                }
            }else {
                completion?(nil)
            }
        }
    }
    
    override func acceptSeatPick(_ params: NEAcceptSeatPickParams, completion: NEAcceptSeatPickCompletion?) {
        super.acceptSeatPick(params) { (error) in
            guard error == nil else {
                completion?(error)
                return
            }
            
            if !NELiveRoom.shared.rtcOption {
                completion?(nil)
                return
            }
            
            let isCDN = NELiveRoom.shared.roomService.currentRoom?.pushType == .CDN
            if !isCDN {
                completion?(nil)
                return
            }
            guard let cname = NELiveRoom.shared.roomService.currentRoom?.cname else {
                completion?(NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorInvalidResponse, userInfo: [NSLocalizedDescriptionKey: "cname不能为空!"]))
                return
            }
            guard let uid = NELiveRoom.shared.roomService.currentUser?.uid else {
                completion?(NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorInvalidResponse, userInfo: [NSLocalizedDescriptionKey: "uid不能为空!"]))
                return
            }
            NERtcEngine.shared().joinChannel(withToken: NELiveRoom.shared.roomService.currentUser?.checksum ?? "", channelName: cname, myUid: uid ) { (error, cid, elapsed,uid) in
                completion?(error)
            }
        }
    }
    
    func add(delegate: NESeatServiceDelegate) {
        self.delegateProxy.add(delegate: delegate)
    }
    
    func remove(delegate: NESeatServiceDelegate) {
        self.delegateProxy.remove(delegate: delegate)
    }
    
    func didReceivedPassThroughMsg(_ recvData: NIMPassThroughMsgData?) {
        guard let data = recvData?.body.data(using: .utf8), let dic:[String: Any] = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any] else {
            return
        }
        guard let sid = dic["sid"] as? Int, sid == 10 else {
            return // 不接收不属于这个服务的透传消息
        }
        guard let eventRaw = dic["type"] as? Int, let action = NESeatEvent(rawValue: eventRaw) else {
            print("Invalid type: \(dic["type"] ?? "null")")
            return
        }
        guard let seatInfoDic = dic["seatInfo"] as? [String: Any] else {
            print("No seat info exists!!") // 没有seatInfo，理论上不存在
            return
        }
        guard let roomId = seatInfoDic["roomId"] as? String, roomId == self.roomId else {
            print("Invalid roomId: \(seatInfoDic["roomId"] ?? "null")") // 不接收不属于这个房间的消息
            return
        }
        if let currentUserDic = dic["avRoomUser"] as? [AnyHashable: Any] {
            NELiveRoom.shared.roomService.currentUser?.checksum = currentUserDic["avRoomCheckSum"] as? String
        }
        
        
        let seatInfo = NESeatInfo(dictionary: seatInfoDic)
        let attachment = seatInfoDic["attachment"] as? String
        print("eventCode=\(eventRaw) seatInfochange =  \(seatInfoDic.description)")

        switch action {
        case .acceptApply:
            let event = NESeatApplyAcceptEvent()
            event.seatInfo = seatInfo
            event.attachment = attachment
            event.avRoomUser = NEAvRoomUserDetail(dictionary:dic["avRoomUser"] as! [AnyHashable : Any?])
            event.requestId = seatInfoDic["requestId"] as? String
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.respondor = NERoomUserInfo(dictionary: fromUserDic)
            }
            
            if NELiveRoom.shared.rtcOption {
                joinRtcRoomIfCDN { (error) in
                    guard error == nil else {
                        print("NESeatService: join rtc error: \(error!.localizedDescription)")
                        return
                    }
                    self.delegateProxy.onSeatApplyAccepted(event)
                }
            }else {
                self.delegateProxy.onSeatApplyAccepted(event)
            }
         
            break
        case .pick:
            let event = NESeatPickRequestEvent()
            event.seatInfo = seatInfo
            event.avRoomUser = NEAvRoomUserDetail(dictionary:dic["avRoomUser"] as! [AnyHashable : Any?])
            event.attachment = attachment
            event.requestId = seatInfoDic["requestId"] as? String
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.applicant = NERoomUserInfo(dictionary: fromUserDic)
            }
            self.delegateProxy.onSeatPickRequest(event)
            break
        case .leave:
            let event = NESeatLeaveEvent()
            event.seatInfo = seatInfo
            event.avRoomUser = NEAvRoomUserDetail(dictionary:dic["avRoomUser"] as! [AnyHashable : Any?])
            event.attachment = attachment
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.responder = NERoomUserInfo(dictionary: fromUserDic)
            }
            if let reasonRaw = dic["reason"] as? Int {
                event.reason = NESeatInfoChangeReason(rawValue: reasonRaw) ?? .normal
            }
            self.delegateProxy.onSeatLeft(event)
            break
        case .apply:
            let event = NESeatApplyRequestEvent()
            event.seatInfo = seatInfo
            event.attachment = attachment
            event.requestId = seatInfoDic["requestId"] as? String
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.applicant = NERoomUserInfo(dictionary: fromUserDic)
            }
            self.delegateProxy.onSeatApplyRequest(event)
            break
        case .cancelApply:
            let event = NESeatApplyRequestCancelEvent()
            event.seatInfo = seatInfo
            event.attachment = attachment
            event.requestId = seatInfoDic["requestId"] as? String
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.applicant = NERoomUserInfo(dictionary: fromUserDic)
            }
            self.delegateProxy.onSeatApplyRequestCanceled(event)
            break
        case .rejectApply:
            let event = NESeatApplyRejectEvent()
            event.seatInfo = seatInfo
            event.attachment = attachment
            event.requestId = seatInfoDic["requestId"] as? String
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.respondor = NERoomUserInfo(dictionary: fromUserDic)
            }
            self.delegateProxy.onSeatApplyRejected(event)
            break
        case .rejectPick:
            let event = NESeatPickRejectEvent()
            event.seatInfo = seatInfo
            event.attachment = attachment
            event.requestId = seatInfoDic["requestId"] as? String
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.responder = NERoomUserInfo(dictionary: fromUserDic)
            }
            self.delegateProxy.onSeatPickRejected(event)
            break
        case .cancelPick:
            let event = NESeatPickRequestCancelEvent()
            event.seatInfo = seatInfo
            event.attachment = attachment
            event.requestId = seatInfoDic["requestId"] as? String
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.applicant = NERoomUserInfo(dictionary: fromUserDic)
            }
            self.delegateProxy.onSeatPickRequestCanceled(event)
            break
        case .acceptPick:
            let event = NESeatPickAcceptEvent()
            event.seatInfo = seatInfo
            event.attachment = attachment
            event.requestId = seatInfoDic["requestId"] as? String
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.responder = NERoomUserInfo(dictionary: fromUserDic)
            }
            self.delegateProxy.onSeatPickAccepted(event)
            break
        case .audioChange:
            let event = NESeatAudioStateChangeEvent()
            event.seatInfo = seatInfo
            event.attachment = attachment
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.responder = NERoomUserInfo(dictionary: fromUserDic)
            }
            self.delegateProxy.onSeatAudioStateChanged(event)
            break
        case .videoChange:
            let event = NESeatVideoStateChangeEvent()
            event.seatInfo = seatInfo
            event.attachment = attachment
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.responder = NERoomUserInfo(dictionary: fromUserDic)
            }
            self.delegateProxy.onSeatVideoStateChanged(event)
            break
        case .stateChange:
            let event = NESeatStateChangeEvent()
            event.seatInfo = seatInfo
            event.attachment = attachment
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.responder = NERoomUserInfo(dictionary: fromUserDic)
            }
            if let reasonRaw = dic["reason"] as? Int {
                event.reason = NESeatInfoChangeReason(rawValue: reasonRaw) ?? .normal
            }
            self.delegateProxy.onSeatStateChanged(event)
            break
        case .enter:
            let event = NESeatEnterEvent()
            event.seatInfo = seatInfo
            event.avRoomUser = NEAvRoomUserDetail(dictionary:dic["avRoomUser"] as! [AnyHashable : Any?])
            event.attachment = attachment
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.responder = NERoomUserInfo(dictionary: fromUserDic)
            }
            self.delegateProxy.onSeatEntered(event)
            break
        case .customInfoChange:
            let event = NESeatCustomInfoChangeEvent()
            event.seatInfo = seatInfo
            event.attachment = attachment
            if let fromUserDic = dic["fromUser"] as? [AnyHashable: Any] {
                event.responder = NERoomUserInfo(dictionary: fromUserDic)
            }
            self.delegateProxy.onSeatCustomInfoChanged(event)
            break
        default:
            print("NESeatService: invalid event: \(action)")
            break
        }
    }
    
    private func joinRtcRoomIfCDN(completion: ((Error?) -> Void)?) {
        let isCDN = NELiveRoom.shared.roomService.currentRoom?.pushType == .CDN
        if isCDN {
            let cname = NELiveRoom.shared.roomService.currentRoom?.cname ?? ""
            let myUid = NELiveRoom.shared.roomService.currentUser?.uid ?? 0
            let checksum = NELiveRoom.shared.roomService.currentUser?.checksum ?? ""
            NERtcEngine.shared().joinChannel(withToken: checksum, channelName: cname, myUid: myUid) { (error, cid, elapsed,uid) in
                completion?(error)
            }
        } else {
            completion?(nil)
        }
    }
    
}
