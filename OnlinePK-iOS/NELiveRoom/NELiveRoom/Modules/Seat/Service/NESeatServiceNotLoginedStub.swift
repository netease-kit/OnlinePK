//
//  NESeatServiceNotLoginedStub.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/7.
//

import Foundation

open class NESeatServiceNotLoginedStub: NSObject, NESeatServiceProtocol {
    
    public var seatInfos: [NESeatInfo]?
    
    fileprivate weak var client: NESeatServiceProtocol?

    internal init(client: NESeatServiceProtocol) {
        self.client = client
        super.init()
    }
    
    public func enterSeat(_ params: NEEnterSeatParams, completion: NEEnterSeatCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func fetchSeatInfos(completion: NEFetchSeatInfoCompletion?) {
        completion?(nil, NSError.notLoginedError)
    }
    
    public func leaveSeat(_ params: NELeaveSeatParams, completion: NELeaveSeatCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func kickSeat(_ params: NEKickSeatParams, completion: NEKickSeatCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func applySeat(_ params: NEApplySeatParams, completion: NEApplySeatCompletion?) {
        completion?(nil, NSError.notLoginedError)
    }
    
    public func acceptSeatApply(_ params: NEAcceptSeatApplyParams, completion: NEAcceptSeatApplyCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func rejectSeatApply(_ params: NERejectSeatApplyParams, completion: NERejectSeatApplyCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func cancelSeatApply(_ params: NECancelSeatApplyParams, completion: NECancelSeatApplyCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func pickSeat(_ params: NEPickSeatParams, completion: NEPickSeatCompletion?) {
        completion?(nil, NSError.notLoginedError)
    }
    
    public func acceptSeatPick(_ params: NEAcceptSeatPickParams, completion: NEAcceptSeatPickCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func rejectSeatPick(_ params: NERejectSeatPickParams, completion: NERejectSeatPickCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func cancelSeatPick(_ params: NECancelSeatPickParams, completion: NECancelSeatPickCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func setSeatVideoState(_ params: NESetSeatVideoStateParams, completion: NESetSeatVideoStateCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func setSeatAudioState(_ params: NESetSeatAudioStateParams, completion: NESetSeatAudioStateCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func setSeatOpenState(_ params: NESetSeatOpenStateParams, completion: NESetSeatOpenStateCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func setSeatCustomInfo(_ params: NESetSeatCustomInfoParams, completion: NESetSeatCustomInfoCompletion?) {
        completion?(NSError.notLoginedError)
    }
    
    public func add(delegate: NESeatServiceDelegate) {
        self.client?.add(delegate: delegate)
    }
    
    public func remove(delegate: NESeatServiceDelegate) {
        self.client?.remove(delegate: delegate)
    }
    
}
