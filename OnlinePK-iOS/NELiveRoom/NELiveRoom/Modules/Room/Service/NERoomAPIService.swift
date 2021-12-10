//
//  NERoomAPIService.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/10.
//

import Foundation

class NERoomAPIService: NSObject,NERoomAPIServiceProtocol,URLSessionDelegate {
    
    var currentUser: NERoomUserDetail?
    var currentRoom: NERoomDetail?
    
    fileprivate var delegateQueue: OperationQueue!
    fileprivate var session: URLSession!
    
    override init() {
        super.init()
        self.delegateQueue = OperationQueue()
        self.delegateQueue.maxConcurrentOperationCount = 1
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: self.delegateQueue)
    }
    
    func createRoom(_ params: NECreateRoomParams, completion: NECreateRoomCompletion?) {
        
        let url = URL(string: "/voiceChat/room/\(params.version)/create", relativeTo: NELiveRoom.shared.baseURL)!
        var body = [String: Any?]()
        body["accountId"] = NIMSDK.shared().loginManager.currentAccount()
        body["roomTopic"] = params.title
        body["cover"] = params.coverURL?.absoluteString
        body["pushType"] = params.pushType.rawValue
        body["roomType"] = params.roomType.rawValue
        body["customInfo"] = params.customInfo
        if params.seatLimit >= 0 {
            body["seatLimit"] = params.seatLimit
        }
        if params.userLimit >= 0 {
            body["userLimit"] = params.userLimit
        }
        
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error as NSError? {
                completion?(nil, nil, error)
                return
            }
            guard (data!["avRoom"] as? [AnyHashable: Any]) != nil else {
                completion?(nil, nil, NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorInvalidResponse, userInfo: [NSLocalizedDescriptionKey: "avRoom不合法!"]))
                return
            }
            guard let avRoomUser = data!["avRoomUser"] as? [AnyHashable: Any] else {
                completion?(nil, nil, NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorInvalidResponse, userInfo: [NSLocalizedDescriptionKey: "avRoomUser不合法!"]))
                return
            }
            self?.currentRoom = NERoomDetail(dictionary: data!)
            self?.currentUser = NERoomUserDetail(dictionary: avRoomUser)
            if let liveHostRecordDic = data!["liveHostRecord"] as? [AnyHashable: Any], let avatarString = liveHostRecordDic["avatar"] as? String, let avatarURL = URL(string: avatarString) {
                self?.currentUser?.avatarURL = avatarURL
            }
            completion?(self?.currentRoom, self?.currentUser, nil)
        }.resume()
    }
    
    func destroyRoom(_ params: NEDestroyRoomParams, completion: NEDestroyRoomCompletion?) {
        let roomId = params.roomId ?? self.currentRoom?.roomId ?? ""
        let url = URL(string: "/voiceChat/room/\(params.version)/\(roomId)/destroy", relativeTo: NELiveRoom.shared.baseURL)!
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        self.session.nl_dataTask(with: request) {[weak self] (data, response, error) in
            if let error = error as NSError? {
                completion?(error)
                return
            }
            self?.currentRoom = nil
            completion?(nil)
        }.resume()
    }
    
    func enterRoom(_ params: NEEnterRoomParams, completion: NEEnterRoomCompletion?) {
        let url = URL(string: "/voiceChat/room/\(params.version)/enter", relativeTo: NELiveRoom.shared.baseURL)!
   
        let body = [
            "roomId": params.roomId,
            "accountId": NIMSDK.shared().loginManager.currentAccount(),
            "nickname": params.userName,
            "customInfo": params.customInfo,
            "clientType": 2, // iOS
            "attachment": params.attachment
        ] as [String : Any?]
        
        debugPrint("NERoomService: start request with url \(url.absoluteString)")
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) {[weak self] (data, response, error) in
            if let error = error as NSError? {
                completion?(nil, nil, error)
                return
            }
            guard (data!["avRoom"] as? [AnyHashable: Any]) != nil else {
                completion?(nil, nil, NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorInvalidResponse, userInfo: [NSLocalizedDescriptionKey: "avRoom不合法!"]))
                return
            }
            guard let avRoomUser = data!["avRoomUser"] as? [AnyHashable: Any] else {
                completion?(nil, nil, NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorInvalidResponse, userInfo: [NSLocalizedDescriptionKey: "avRoomUser不合法!"]))
                return
            }
            self?.currentRoom = NERoomDetail(dictionary: data!)
            self?.currentUser = NERoomUserDetail(dictionary: avRoomUser)
            completion?(self?.currentRoom, self?.currentUser, nil)
        }.resume()
    }
    
    func leaveRoom(_ params: NELeaveRoomParams, completion: NELeaveRoomCompletion?) {
        guard let roomId = self.currentRoom?.roomId else {
            completion?(NSError(domain: NELiveRoomErrorDomain, code: NELiveRoomErrorNotInRoom, userInfo: nil))
            return
        }
        let url = URL(string: "/voiceChat/room/\(params.version)/\(roomId)/exit", relativeTo: NELiveRoom.shared.baseURL)!

        let body = [
            "attachment": params.attachment
        ]

        debugPrint("NERoomService: start request with url \(url.absoluteString)")

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        self.session.nl_dataTask(with: request) {[weak self] (data, response, error) in
            if let error = error as NSError? {
                completion?(error)
                return
            }
            self?.currentRoom = nil
            self?.currentUser = nil
            completion?(nil)
        }.resume()
    }
    
    func listRooms(_ params: NEListRoomParams, completion: NEListRoomCompletion?) {
        
        var comp = URLComponents()
        comp.scheme = NELiveRoom.shared.baseURL.scheme
        comp.host = NELiveRoom.shared.baseURL.host
        comp.path = "/voiceChat/room/\(params.version)/list"
        comp.queryItems = [
            URLQueryItem(name: "roomType", value: String(params.roomType.rawValue)),
            URLQueryItem(name: "pageNumber", value: String(params.pageNumber)),
            URLQueryItem(name: "pageSize", value: String(params.pageSize))
        ]
        
        let url = comp.url!

        debugPrint("NERoomService: start request with url \(url.absoluteString)")

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        self.session.nl_dataTask(with: request) { (data, response, error) in
            if let error = error as NSError? {
                completion?(nil, error)
                return
            }
            let result = NEListRoomResult(dictionary: data!)
            completion?(result, nil)
        }.resume()
    }

}
