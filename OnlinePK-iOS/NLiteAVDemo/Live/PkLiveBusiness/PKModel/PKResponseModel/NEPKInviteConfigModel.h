//
//  NEPKInviteConfigModel.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/11/19.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NEPkConfigModel;
@interface NEPKInviteConfigModel : NSObject
//新增pk 配置。
@property(nonatomic, strong) NEPkConfigModel *pkConfig;
//pk id
@property(nonatomic, strong) NSString *pkId;
@end

NS_ASSUME_NONNULL_END
