// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FLTNativeViewFactory.h"
#import <NELivePlayerFramework/NELivePlayerFramework.h>
#import "NEPlayerSingleton.h"

@interface FLTNativeViewFactory ()
@property(nonatomic, strong) NSObject<FlutterBinaryMessenger> *messenger;
@end

@implementation FLTNativeViewFactory
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  if (self) {
    _messenger = messenger;
  }
  return self;
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(id)args {
  return [[NEVideoView alloc] initWithFrame:frame
                             viewIdentifier:viewId
                                  arguments:args
                            binaryMessenger:self.messenger];
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

@end

@implementation NEVideoView {
  UIView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  if (self = [super init]) {
    NSString *playerId = (NSString *)args[@"playerId"];
    NELivePlayerController *player = [[NEPlayerSingleton shared].players valueForKey:playerId];
    _view = player.view;
  }
  return self;
}

- (UIView *)view {
  return _view;
}

@end
