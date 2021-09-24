//
//  NSURLSession+LiveRoom.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/30.
//

import Foundation

extension URLSession {
    
    open func nl_dataTask(with request: URLRequest, completionHandler: @escaping ([String: Any]?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        var request = request
        request.setValue(NELiveRoom.shared.options.appKey, forHTTPHeaderField: "appKey")
        request.setValue(NELiveRoom.shared.options.accessToken, forHTTPHeaderField: "accessToken")
        request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(Locale.current.identifier == "zh_CN" ? "zh" : "en", forHTTPHeaderField: "lang")
        return self.dataTask(with: request) { (data, resp, error) in
            guard data != nil, data!.count > 0 else {
                completionHandler(nil, nil, NSError(domain: NELiveRoomErrorDomain, code: NSURLErrorCannotDecodeContentData, userInfo: nil))
                return
            }
            guard error == nil else {
                completionHandler(nil, nil, error)
                return
            }
            guard let httpResp = resp as? HTTPURLResponse else {
                completionHandler(nil, nil, NSError(domain: NSCocoaErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey:"Response is not http response: \(String(describing: resp.self))"]))
                return
            }
            guard httpResp.statusCode == 200 else {
                completionHandler(nil, nil, NSError(domain: NSCocoaErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey:"Http error with status: \(httpResp.statusCode)"]))
                return
            }
            guard let response = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as? [String: Any]   else {
                completionHandler(nil, nil, NSError(domain: NELiveRoomErrorDomain, code: NSURLErrorCannotDecodeContentData, userInfo: nil))
                return
            }
            guard let code = response["code"] as? Int else {
                completionHandler(nil, nil, NSError(domain: NELiveRoomErrorDomain, code: NSURLErrorCannotDecodeContentData, userInfo: [NSLocalizedDescriptionKey: "Empty code in response body!"]))
                return
            }
            guard code == 200 else {
                let message = response["msg"] as? String ?? "Empty message in response body!"
                completionHandler(nil, nil, NSError(domain: NELiveRoomErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: message]))
                return
            }
            debugPrint("NELiveRoom: request \(String(describing: response["requestId"])) cost time \(String(describing: response["costTime"]))");
            
            guard let data = response["data"] else {
                completionHandler(nil, resp, nil)
                return
            }
            let dic = data as? [String: Any] ?? ["data" : data]
            completionHandler(dic, resp, nil)
            
        }
    }
    
}
