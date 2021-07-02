//
//  NETSConnectMicService.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/5/18.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NETSConnectMicServiceDelegate <NSObject>

//主播同意了观众的连麦申请
- (void)adminAcceptJoinSeats;
//主播拒绝观众的连麦申请
- (void)adminRefuseAudienceApplyJoinSeats;

@end

@class NETSLiveRoomModel;
@interface NETSConnectMicService : NSObject<NIMPassThroughManagerDelegate>

@property (nonatomic, weak,nullable) id<NETSConnectMicServiceDelegate> delegate;


//房间模型
@property(nonatomic, strong) NETSLiveRoomModel *roomModel;
@end

NS_ASSUME_NONNULL_END
