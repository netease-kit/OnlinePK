//
//  NELiveRoomConsts.h
//  NELiveRoomSDK
//
//  Created by Wenchao Ding on 2021/6/2.
//

#import <Foundation/Foundation.h>

extern NSString * const NELiveRoomErrorDomain;
extern NSString * const NELiveRoomErrorNotLoginedDescription;
extern NSString * const NELiveRoomErrorNotInRoomDescription;

// NELiveRoomErrorCode
static NSInteger const NELiveRoomErrorNotInRoom = 30000;            ///< 未加入房间
static NSInteger const NELiveRoomErrorNotLogined = 30001;           ///< IM没有登录
static NSInteger const NELiveRoomErrorInvalidParams = 30101;        ///< 参数错误
static NSInteger const NELiveRoomErrorInvalidResponse = 30102;        ///< 返回值错误


