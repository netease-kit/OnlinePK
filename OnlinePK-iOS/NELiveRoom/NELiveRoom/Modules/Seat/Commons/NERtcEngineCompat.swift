//
//  NERtcEngineCompat.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/11.
//

import Foundation

class NERtcEngineCompat: NSObject, NERtcEngineDelegate {
    
    var completion: ( (_ error: NERtcError)->() )?
    
    func leaveChannel(_ completion: ((_ error: NERtcError)->())? ) {
        switch NERtcEngine.shared().connectionState() {
        case .connected,.connecting,.reconnecting:
            NERtcEngine.shared().leaveChannel()
            self.completion = completion
            break
        default:
            completion?(.kNERtcErrChannelNotJoined)
            break
        }
    }
    
    func onNERtcEngineDidLeaveChannel(withResult result: NERtcError) {
        self.completion?(result)
        self.completion = nil
    }
    
}
