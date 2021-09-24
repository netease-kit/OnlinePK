//
//  NESeatServiceNotInRoomStub.swift
//  NELiveRoom
//
//  Created by Wenchao Ding on 2021/6/7.
//

import Foundation

open class NESeatServiceNotInRoomStub: NSObject, NESeatServiceProtocol {
    
    public var seatInfos: [NESeatInfo]?
    
    fileprivate weak var client: NESeatServiceProtocol?

    internal init(client: NESeatServiceProtocol) {
        self.client = client
        super.init()
    }
    
    public func enterSeat(_ params: NEEnterSeatParams, completion: NEEnterSeatCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func fetchSeatInfos(completion: NEFetchSeatInfoCompletion?) {
        completion?(nil, NSError.notInRoomError)
    }
    
    public func leaveSeat(_ params: NELeaveSeatParams, completion: NELeaveSeatCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func kickSeat(_ params: NEKickSeatParams, completion: NEKickSeatCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func applySeat(_ params: NEApplySeatParams, completion: NEApplySeatCompletion?) {
        completion?(nil, NSError.notInRoomError)
    }
    
    public func acceptSeatApply(_ params: NEAcceptSeatApplyParams, completion: NEAcceptSeatApplyCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func rejectSeatApply(_ params: NERejectSeatApplyParams, completion: NERejectSeatApplyCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func cancelSeatApply(_ params: NECancelSeatApplyParams, completion: NECancelSeatApplyCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func pickSeat(_ params: NEPickSeatParams, completion: NEPickSeatCompletion?) {
        completion?(nil, NSError.notInRoomError)
    }
    
    public func acceptSeatPick(_ params: NEAcceptSeatPickParams, completion: NEAcceptSeatPickCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func rejectSeatPick(_ params: NERejectSeatPickParams, completion: NERejectSeatPickCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func cancelSeatPick(_ params: NECancelSeatPickParams, completion: NECancelSeatPickCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func setSeatVideoState(_ params: NESetSeatVideoStateParams, completion: NESetSeatVideoStateCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func setSeatAudioState(_ params: NESetSeatAudioStateParams, completion: NESetSeatAudioStateCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func setSeatOpenState(_ params: NESetSeatOpenStateParams, completion: NESetSeatOpenStateCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func setSeatCustomInfo(_ params: NESetSeatCustomInfoParams, completion: NESetSeatCustomInfoCompletion?) {
        completion?(NSError.notInRoomError)
    }
    
    public func add(delegate: NESeatServiceDelegate) {
        guard let service = self.client else {
            return
        }
        service.add(delegate: delegate)
    }
    
    public func remove(delegate: NESeatServiceDelegate) {
        guard let service = self.client else {
            return
        }
        service.remove(delegate: delegate)
    }
    
}
