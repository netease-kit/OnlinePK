//
//  NEPkPassthroughInviteModel.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/18.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEPassthroughPkInviteModel.h"

@implementation NEPassthroughPkInviteModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
  return @{
      @"actionAnchor"  : [NEPkInviteActionAnchorModel class],
      @"targetAnchor" : [NEPkInviteTargetAnchorModel class],
  };
}
@end

@implementation NEPkInviteActionAnchorModel


@end

@implementation NEPkInviteTargetAnchorModel

@end
