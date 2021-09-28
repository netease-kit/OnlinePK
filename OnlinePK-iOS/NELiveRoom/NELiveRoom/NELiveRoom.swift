//
//  NELiveRoom.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/27.
//

import Foundation

@objc
open class NELiveRoom: NSObject {
    
    /// 获取实例
    /// @return 实例
    @objc(sharedInstance)
    static public let shared = NELiveRoom()
    
    @objc
    public var options: NELiveRoomOptions!
    
    
    @objc//joinchannel配置，默认不操作rtc的加入和离开
    public var rtcOption = false
    
    @nonobjc
    private var services: [String: Any] = [:]
    
    /// 初始化方法，必须调用
    /// @param options 初始化参数
    @objc(setupWithOptions:)
    public func setup(_ options: NELiveRoomOptions) {
        assert(!options.appKey.isEmpty, "app key为必填字段")
        assert(!options.apiHost.isEmpty, "api host为必填字段")
        NELiveRoom.shared.options = options
        
        // Setup NIM
        NIMSDK.shared().register(with: NIMSDKOption(appKey: options.appKey))
        
        // Setup RTC
        let coreEngine = NERtcEngine.shared()
        let context = NERtcEngineContext()
        context.appKey = options.appKey
        context.engineDelegate = NELiveRoomDelegateProxy.shared() as? NERtcEngineDelegateEx
        coreEngine.setupEngine(with: context)
        coreEngine.enableLocalVideo(true)
        coreEngine.enableLocalAudio(true)
        coreEngine.setAudioProfile(.highQuality, scenario: .chatRoom)
        coreEngine.enableAudioVolumeIndication(true, interval: 1000)
        
    }
    
    @objc(serviceForProtocol:)
    public func service(for proto: Protocol) -> Any? {
        let name = String(cString:protocol_getName(proto))
        return self.services[name]
    }
    
}

public extension NELiveRoom {
    
    @objc
    var baseURL: URL {
        return URL(string: NELiveRoom.shared.options.apiHost)!
    }
    
    @nonobjc
    func register(_ service: Any?, for proto: Protocol) {
        let name = String(cString:protocol_getName(proto))
        self.services[name] = service
    }
    
}

// Rtc
public extension NELiveRoom {
    
    /// 开启/关闭音频硬件
    /// @return 操作返回值，0代表成功
    func enableLocalAudio(_ enabled: Bool) -> Int32 {
        return NERtcEngine.shared().enableLocalAudio(enabled)
    }
    
    /// 开启/关闭音频，但不会操作硬件
    /// @return 操作返回值，0代表成功
    func mutableLocalAudio(_ muted: Bool) -> Int32 {
        return NERtcEngine.shared().muteLocalAudio(muted)
    }
    
    /// 开启/关闭扬声器
    /// @return 操作返回值，0代表成功
    func setSpeakerOn(_ on: Bool) -> Int32 {
        return NERtcEngine.shared().setLoudspeakerMode(on)
    }
    
}
