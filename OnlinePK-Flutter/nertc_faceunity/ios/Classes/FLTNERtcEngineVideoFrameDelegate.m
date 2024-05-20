// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FLTNERtcEngineVideoFrameDelegate.h"

@interface FLTNERtcEngineVideoFrameDelegate ()

@end

@implementation FLTNERtcEngineVideoFrameDelegate
+ (instancetype)sharedCenter {
  static FLTNERtcEngineVideoFrameDelegate *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[FLTNERtcEngineVideoFrameDelegate alloc] init];
  });
  return instance;
}
- (void)onNERtcEngineVideoFrameCaptured:(CVPixelBufferRef)bufferRef
                               rotation:(NERtcVideoRotationType)rotation {
  if (self.observer &&
      [self.observer respondsToSelector:@selector(onNERtcEngineVideoFrameCaptured:rotation:)]) {
    [self.observer onNERtcEngineVideoFrameCaptured:bufferRef
                                          rotation:(NERtcVideoRotationType)rotation];
  }
}
@end
