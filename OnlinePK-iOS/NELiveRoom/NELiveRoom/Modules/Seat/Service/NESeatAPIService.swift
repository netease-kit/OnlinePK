//
//  NESeatApiService.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/9.
//

import Foundation

@objc
class NESeatAPIService: NSObject,NESeatAPIServiceProtocol,URLSessionDelegate {
        
    var seatInfos: [NESeatInfo]?
    
    fileprivate var roomId: String {
        NELiveRoom.shared.roomService.currentRoom!.roomId!
    }
    fileprivate var session: URLSession!
    fileprivate var delegateQueue: OperationQueue!
    fileprivate var delegateProxy = NELiveRoomDelegateProxy() as! NESeatServiceDelegate & NELiveRoomDelegateProxy

    public override init() {
        super.init()
        self.delegateQueue = OperationQueue()
        self.delegateQueue.maxConcurrentOperationCount = 1
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: self.delegateQueue)
    }
    
    public func enterSeat(_ params: NEEnterSeatParams, completion: NEEnterSeatCompletion?) {
        /// 保留
    }
    
    func fetchSeatInfos(completion: NEFetchSeatInfoCompletion?) {
        let url = URL(string: "/seat/v1/\(self.roomId)/seatInfo", relativeTo: NELiveRoom.shared.baseURL)!
 
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        self.session.nl_dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion?(nil, error)
                return
            }
            guard let array = data?["data"] as? [[AnyHashable: Any]] else {
                completion?(nil, NSError(domain: NELiveRoomErrorDomain, code: NSURLErrorCannotDecodeContentData, userInfo: [NSLocalizedDescriptionKey: "Invalid data: \(String(describing: data))"]))
                return
            }
            var seatInfos = [NESeatInfo]()
            for dic: [AnyHashable: Any] in array {
                let newInfo = NESeatInfo(dictionary: dic)
                seatInfos.append(newInfo)
            }
            self.seatInfos = seatInfos;
            completion?(seatInfos, nil)
        }.resume()
    }
    
    public func leaveSeat(_ params: NELeaveSeatParams, completion: NELeaveSeatCompletion?) {
        let url = URL(string: "/seat/\(params.version)/seatAction", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "action": NESeatAction.leave.rawValue,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "roomId": self.roomId,
            "attachment": params.attachment
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            completion?(error)
        }.resume()
    }
    
    public func kickSeat(_ params: NEKickSeatParams, completion: NEKickSeatCompletion?) {
        let url = URL(string: "/seat/\(params.version)/seatAction", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "action": NESeatAction.kick.rawValue,
            "seatIndex": params.index,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "roomId": self.roomId,
            "attachment": params.attachment,
            "toAccountId" : params.userId
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            completion?(error)
        }.resume()
    }
    
    public func applySeat(_ params: NEApplySeatParams, completion: NEApplySeatCompletion?) {
        let url = URL(string: "/seat/\(params.version)/seatAction", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "action": NESeatAction.apply.rawValue,
            "seatIndex": params.index >= 0 ? params.index : nil,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "roomId": self.roomId,
            "attachment": params.attachment
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion?(nil, error)
                return
            }
            let resp = NESeatApplyResponse()
            resp.requestId = data!["requestId"] as? String
            completion?(resp, error)
        }.resume()
    }
    
    public func acceptSeatApply(_ params: NEAcceptSeatApplyParams, completion: NEAcceptSeatApplyCompletion?) {
        let url = URL(string: "/seat/\(params.version)/seatAction", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "action": NESeatAction.acceptApply.rawValue,
            "requestId": params.requestId,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "seatIndex" : params.seatIndex >= 0 ? params.seatIndex : nil,
            "roomId": self.roomId,
            "attachment": params.attachment,
            "toAccountId" : params.userId
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            completion?(error)
        }.resume()
    }
    
    public func rejectSeatApply(_ params: NERejectSeatApplyParams, completion: NERejectSeatApplyCompletion?) {
        let url = URL(string: "/seat/\(params.version)/seatAction", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "action": NESeatAction.rejectApply.rawValue,
            "requestId": params.requestId,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "seatIndex" : params.seatIndex >= 0 ? params.seatIndex : nil,
            "roomId": self.roomId,
            "attachment": params.attachment,
            "toAccountId" : params.userId
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            completion?(error)
        }.resume()
    }
    
    public func cancelSeatApply(_ params: NECancelSeatApplyParams, completion: NECancelSeatApplyCompletion?) {
        let url = URL(string: "/seat/\(params.version)/seatAction", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "action": NESeatAction.cancelApply.rawValue,
            "seatIndex": params.index >= 0 ? params.index : nil,
            "requestId": params.requestId,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "roomId": self.roomId,
            "attachment": params.attachment
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            completion?(error)
        }.resume()
    }
    
    public func pickSeat(_ params: NEPickSeatParams, completion: NEPickSeatCompletion?) {
        let url = URL(string: "/seat/\(params.version)/seatAction", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "action": NESeatAction.pick.rawValue,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "seatIndex" : params.seatIndex >= 0 ? params.seatIndex : nil,
            "roomId": self.roomId,
            "attachment": params.attachment,
            "toAccountId" : params.userId
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion?(nil, error)
                return
            }
            let resp = NESeatPickResponse()
            resp.requestId = data!["requestId"] as? String
            completion?(resp, error)
        }.resume()
    }
    
    public func acceptSeatPick(_ params: NEAcceptSeatPickParams, completion: NEAcceptSeatPickCompletion?) {
        let url = URL(string: "/seat/\(params.version)/seatAction", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "action": NESeatAction.acceptPick.rawValue,
            "requestId": params.requestId,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "seatIndex" : params.seatIndex >= 0 ? params.seatIndex : nil,
            "roomId": self.roomId,
            "attachment": params.attachment,
            "enterAttachment" : params.enterAttachment
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            completion?(error)
        }.resume()
    }
    
    public func rejectSeatPick(_ params: NERejectSeatPickParams, completion: NERejectSeatPickCompletion?) {
        let url = URL(string: "/seat/\(params.version)/seatAction", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "action": NESeatAction.rejectPick.rawValue,
            "requestId": params.requestId,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "seatIndex" : params.seatIndex >= 0 ? params.seatIndex : nil,
            "roomId": self.roomId,
            "attachment": params.attachment
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            completion?(error)
        }.resume()
    }
    
    public func cancelSeatPick(_ params: NECancelSeatPickParams, completion: NECancelSeatPickCompletion?) {
        let url = URL(string: "/seat/\(params.version)/seatAction", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "action": NESeatAction.cancelPick.rawValue,
            "requestId": params.requestId,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "seatIndex" : params.seatIndex >= 0 ? params.seatIndex : nil,
            "roomId": self.roomId,
            "attachment": params.attachment
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            completion?(error)
        }.resume()
    }
    
    public func setSeatVideoState(_ params: NESetSeatVideoStateParams, completion: NESetSeatVideoStateCompletion?) {
        let state = params.state
        let index = params.index
        let url = URL(string: "/seat/\(params.version)/avChange", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "videoState": state.rawValue,
            "seatIndex": index,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "roomId": self.roomId,
            "attachment": params.attachment,
            "toAccountId":params.userId
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion?(error)
                return
            }
            if let seatInfos = self.seatInfos {
                seatInfos[index].videoState = state
            }
            completion?(nil)
        }.resume()
    }
    
    public func setSeatAudioState(_ params: NESetSeatAudioStateParams, completion: NESetSeatAudioStateCompletion?) {
        let state = params.state
        let index = params.index
        let url = URL(string: "/seat/\(params.version)/avChange", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "audioState": state.rawValue,
            "seatIndex": index,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "roomId": self.roomId,
            "attachment": params.attachment,
            "toAccountId":params.userId
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion?(error)
                return
            }
            if let seatInfos = self.seatInfos {
                seatInfos[index].audioState = state
            }
            completion?(nil)
        }.resume()
    }
    
    public func setSeatOpenState(_ params: NESetSeatOpenStateParams, completion: NESetSeatOpenStateCompletion?) {
        let index = params.index
        let open = params.open
        let state = open ? 1 : 0
        let url = URL(string: "/seat/\(params.version)/seatChange", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "state": state,
            "seatIndex": index,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "roomId": self.roomId,
            "attachment": params.attachment,
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion?(error)
                return
            }
            if let seatInfos = self.seatInfos {
                seatInfos[index].state = .idle
            }
            completion?(nil)
        }.resume()
    }
    
    public func setSeatCustomInfo(_ params: NESetSeatCustomInfoParams, completion: NESetSeatCustomInfoCompletion?) {
        guard let customInfo = params.customInfo, params.index > 0 else {
            completion?(NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorInvalidParams, userInfo: [NSLocalizedDescriptionKey: "index，customInfo为必填字段!"]))
            return
        }
        let index = params.index
        let url = URL(string: "/seat/\(params.version)/customInfoChange", relativeTo: NELiveRoom.shared.baseURL)!
        let body: [String: Any?] = [
            "customInfo": customInfo,
            "seatIndex": index,
            "accountId" : NIMSDK.shared().loginManager.currentAccount(),
            "roomId" : self.roomId,
            "attachment": params.attachment,
        ]
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion?(error)
                return
            }
            if let seatInfos = self.seatInfos {
                seatInfos[index].customInfo = customInfo
            }
            completion?(nil)
        }.resume()
    }
        
}

