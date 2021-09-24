//
//  NESeatInfo.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/5/25.
//

import Foundation

@objc
public enum NESeatState: Int {
    case idle = 0       ///< 闲置
    case applying = 1   ///< 正在申请上麦
    case picking = 2    ///< 正在申请报麦
    case waiting = 3    ///< 已同意，但正在加入音视频
    case entered = 4    ///< 已经占用
    case closed = 5     ///< 关闭
}

@objc
public enum NESeatVideoState: Int {
    case disabled = -1
    case closed = 0
    case open = 1
}

@objc
public enum NESeatAudioState: Int {
    case disabled = -1
    case closed = 0
    case open = 1
}

@objc
open class NESeatInfo: NSObject {
    
    /// 序号
    @objc
    public var index: Int = 0
    
    /// 视频状态
    @objc
    public var videoState: NESeatVideoState = .open
    
    /// 音频状态
    @objc
    public var audioState: NESeatAudioState = .open
    
    /// 开关状态
    @objc
    public var state: NESeatState = .idle
    
    /// 自定义扩展信息
    @objc
    public var customInfo: String?
    
    /// 当前在麦位上的用户
    @objc
    public var userInfo: NERoomUserInfo?
    
    //设置远端视图所需uid
    @objc
    public var avRoomUid:Double = 0
    
    public override init() {
        super.init()
    }
    
    init(dictionary: [AnyHashable: Any]) {
        self.index = dictionary["seatIndex"] as? Int ?? 0
        if let videoStateRaw = dictionary["videoState"] as? Int {
            self.videoState = NESeatVideoState(rawValue: videoStateRaw) ?? .closed
        }
        if let audioStateRaw = dictionary["audioState"] as? Int {
            self.audioState = NESeatAudioState(rawValue: audioStateRaw) ?? .closed
        }
        self.avRoomUid = dictionary["avRoomUid"] as? Double ?? 0
        if let stateRaw = dictionary["status"] as? Int {
            self.state = NESeatState(rawValue: stateRaw) ?? .idle
        }
        self.customInfo = dictionary["customInfo"] as? String
        if let accountId = dictionary["accountId"] as? String {
            self.userInfo = NERoomUserInfo()
            self.userInfo?.accountId = accountId
            if let avatar = dictionary["avatar"] as? String {
                self.userInfo?.avatarURL = URL(string: avatar)
            }
            self.userInfo?.userName = dictionary["nickName"] as? String
            // TODO 用户自己的customInfo
        }
        super.init()
    }
    
}
