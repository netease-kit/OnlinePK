//
//  NETSConnectStatusViewController.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/4/21.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NETSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NTESAudienceConnectStatusDelegate <NSObject>

/**
 设置麦克风开关
 @param micOn   - 麦克风开关状态
 */
- (void)didSetMicOn:(BOOL)micOn;
/**
 设置摄像头开关
 @param videoOn   - 摄像头开关状态
 */
- (void)didSetVideoOn:(BOOL)videoOn;


/// 下麦操作
- (void)didResignSeats;

@end
@interface NETSConnectStatusViewController : NETSBaseViewController

@property(nonatomic, weak) id<NTESAudienceConnectStatusDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
