// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEPlayerSingleton.h"

@implementation NEPlayerSingleton

+ (instancetype)shared {
  static dispatch_once_t onceToken;
  static NEPlayerSingleton *_Manager;
  dispatch_once(&onceToken, ^{
    _Manager = [[NEPlayerSingleton alloc] init];
  });
  return _Manager;
}

- (NSMutableDictionary<NSString *, NELivePlayerController *> *)players {
  if (!_players) {
    _players = [[NSMutableDictionary alloc] init];
  }
  return _players;
}

@end
