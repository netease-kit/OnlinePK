//
//  NEPkConfigModel.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/11/19.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEPkConfigModel : NSObject
//同意后倒计时3S任务
@property(nonatomic, assign) NSInteger agreeTaskTime;
//邀请后倒计时20S
@property(nonatomic, assign) NSInteger inviteTaskTime;
@end

NS_ASSUME_NONNULL_END
