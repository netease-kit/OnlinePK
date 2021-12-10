//
//  NEPKInviteConfigModel.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/11/19.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NEPKInviteConfigModel.h"
#import "NEPkConfigModel.h"

@implementation NEPKInviteConfigModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
  return @{@"pkConfig" : [NEPkConfigModel class]};
}

@end
