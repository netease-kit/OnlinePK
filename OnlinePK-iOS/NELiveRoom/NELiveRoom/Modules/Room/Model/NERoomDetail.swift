//
//  NERoomDetail.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/17.
//

import Foundation

@objc
open class NERoomDetail: NSObject {
    
    /// 房间唯一标识
    @objc
    public var roomId: String?
    
    /// 创建者Id
    @objc
    public var creatorId: String?
    
    /// 创建者头像
    @objc
    public var creatorAvatarURL: URL?
    
    /// 创建者昵称
    @objc
    public var creatorNickname: String?
    
    /// 房间标题
    @objc
    public var title: String?
    
    /// 房间封面URL
    @objc
    public var coverURL: URL?
    
    /// 音视频房间cid
    @objc
    public var cid: UInt64 = 0
    
    /// 音视频房间cname
    @objc
    public var cname: String?
    
    /// 聊天室Id
    @objc
    public var chatroomId: String?
    
    /// 房间类型
    @objc
    public var roomType: NELiveRoomType = .chatroom
    
    /// 0: 旁路推流, 1: Rtc
    @objc
    public var pushType: NELiveRoomPushType = .RTC
    
    /// http 拉流地址
    @objc
    public var httpPullURL: NSURL?
    
    /// rtmp 拉流地址
    @objc
    public var rtmpPullURL: NSURL?
    
    /// hts 拉流地址
    @objc
    public var hlsPullURL: NSURL?
    
    /// 推流地址
    @objc
    public var pushURL: NSURL?
    
    /// 自定义字段
    @objc
    public var customInfo: String?
    
    /// 创建时间
    @objc
    public var createTime: Date?
    
    //重写构造方法 pk连麦专用
    @objc
    public override init() {
        
    }
    /// 初始化
   
    public init(dictionary: [AnyHashable: Any]) {
        super.init()
        if let avRoomDic = dictionary["avRoom"] as? [AnyHashable: Any] {
            self.roomId = avRoomDic["roomId"] as? String
            self.creatorId = avRoomDic["creatorAccountId"] as? String
            self.title = avRoomDic["roomTopic"] as? String
            self.cid = avRoomDic["roomCid"] as? UInt64 ?? 0
            self.cname = avRoomDic["roomCname"] as? String
            self.chatroomId = String(avRoomDic["chatRoomId"] as? Int64 ?? 0)
            self.customInfo = avRoomDic["customInfo"] as? String
            if let createTime = avRoomDic["createTime"] as? UInt64 {
                self.createTime = Date(timeIntervalSince1970: Double(createTime)/1000.0)
            }
        }
        if let liveHostDic = dictionary["liveHostRecord"] as? [AnyHashable: Any] {
            if let pushTypeRaw = liveHostDic["pushType"] as? Int {
                self.pushType = NELiveRoomPushType(rawValue: pushTypeRaw) ?? .RTC
            }
            if let roomTypeRaw = liveHostDic["type"] as? Int {
                self.roomType = NELiveRoomType(rawValue: roomTypeRaw) ?? .chatroom
            }
            if let cover = liveHostDic["cover"] as? String {
                self.coverURL = URL(string: cover)
            }
            if let liveConfigString = liveHostDic["liveConfig"] as? String,
               let liveConfigData = liveConfigString.data(using: .utf8),
               let liveConfigDic = try? JSONSerialization.jsonObject(with: liveConfigData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [AnyHashable: Any] {
                if let httpPullUrl = liveConfigDic["httpPullUrl"] as? String {
                    self.httpPullURL = NSURL(string: httpPullUrl)
                }
                if let rtmpPullUrl = liveConfigDic["rtmpPullUrl"] as? String {
                    self.rtmpPullURL = NSURL(string: rtmpPullUrl)
                }
                if let hlsPullUrl = liveConfigDic["hlsPullUrl"] as? String {
                    self.hlsPullURL = NSURL(string: hlsPullUrl)
                }
                if let pushUrl = liveConfigDic["pushUrl"] as? String {
                    self.pushURL = NSURL(string: pushUrl)
                }
            }
            self.creatorNickname = liveHostDic["nickname"] as? String
            if let creatorAvatarURLString = liveHostDic["avatar"] as? String {
                self.creatorAvatarURL = URL(string: creatorAvatarURLString)
            }
        }
    }
    
}
