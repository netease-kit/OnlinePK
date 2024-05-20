// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NERtcFaceUnityFlutterPlugin.h"
#import <NERtcSDK/NERtcSDK.h>
#import "FLTNERtcEngineVideoFrameDelegate.h"
#import "FaceUnity/FUManager.h"
#import "messages.h"

@interface NERtcFaceUnityFlutterPlugin () <NEFTFaceUnityEngineApi,
                                           FLTNERtcEngineVideoFrameObserver,
                                           NERtcEngineVideoFrameObserver>
@property(nonatomic, assign) BOOL enableBeauty;  // 是否开启美颜
@end

@implementation NERtcFaceUnityFlutterPlugin {
  id _registry;
  id _messenger;
  id _textures;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  NERtcFaceUnityFlutterPlugin *instance =
      [[NERtcFaceUnityFlutterPlugin alloc] initWithRegistrar:registrar];
  [registrar publish:instance];

  NEFTFaceUnityEngineApiSetup(registrar.messenger, instance);
}
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  _registry = [registrar textures];
  _messenger = [registrar messenger];
  _textures = [registrar textures];
  return self;
}

- (nullable NEFUInt *)create:(NECreateFaceUnityRequest *)input
                       error:(FlutterError *_Nullable *_Nonnull)error {
#ifdef DEBUG
  NSLog(@"FlutterCalled:NEFLTFaceUnityEngineApi#create");
#endif

  [FLTNERtcEngineVideoFrameDelegate sharedCenter].observer = self;
  NEFUInt *result = [[NEFUInt alloc] init];

  if (input.beautyKey != nil) {
    [[FUManager shareManager] setupWithKey:input.beautyKey];
    _enableBeauty = [[FUManager shareManager] isInitBeauty];
    [[NERtcEngine sharedEngine] setParameters:@{kNERtcKeyVideoCaptureObserverEnabled : @(YES)}];
    [[NERtcEngine sharedEngine] setVideoFrameObserver:self];
    result.value = @(0);
  } else {
    _enableBeauty = NO;
    result.value = @(-1);
  }
  return result;
}

- (nullable NEFUInt *)setFilterLevel:(nonnull NEFUDouble *)input
                               error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NEFUInt *result = [[NEFUInt alloc] init];
  result.value = @([[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty
                                                              name:@"filter_level"
                                                             value:input.value]);
  return result;
}

- (nullable NEFUInt *)setFilterName:(nonnull NEFUDouble *)input
                              error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NEFUInt *result = [[NEFUInt alloc] init];
  result.value = @([[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty
                                                              name:@"filter_name"
                                                             value:input.value]);
  return result;
}

- (nullable NEFUInt *)setColorLevel:(NEFUDouble *)input
                              error:(FlutterError *_Nullable *_Nonnull)error {
  NEFUInt *result = [[NEFUInt alloc] init];
  result.value = @([[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty
                                                              name:@"color_level"
                                                             value:input.value]);
  return result;
}

- (nullable NEFUInt *)setRedLevel:(NEFUDouble *)input
                            error:(FlutterError *_Nullable *_Nonnull)error {
  NEFUInt *result = [[NEFUInt alloc] init];
  result.value = @([[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty
                                                              name:@"red_level"
                                                             value:input.value]);
  return result;
}

- (nullable NEFUInt *)setBlurLevel:(NEFUDouble *)input
                             error:(FlutterError *_Nullable *_Nonnull)error {
  NEFUInt *result = [[NEFUInt alloc] init];
  result.value = @([[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty
                                                              name:@"blur_level"
                                                             value:input.value]);
  return result;
}
- (nullable NEFUInt *)setEyeEnlarging:(NEFUDouble *)input
                                error:(FlutterError *_Nullable *_Nonnull)error {
  NEFUInt *result = [[NEFUInt alloc] init];
  result.value = @([[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty
                                                              name:@"eye_enlarging"
                                                             value:input.value]);
  return result;
}
- (nullable NEFUInt *)setCheekThinning:(NEFUDouble *)input
                                 error:(FlutterError *_Nullable *_Nonnull)error {
  NEFUInt *result = [[NEFUInt alloc] init];
  result.value = @([[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty
                                                              name:@"cheek_thinning"
                                                             value:input.value]);
  return result;
}
- (nullable NEFUInt *)setEyeBright:(NEFUDouble *)input
                             error:(FlutterError *_Nullable *_Nonnull)error {
  NEFUInt *result = [[NEFUInt alloc] init];
  result.value = @([[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty
                                                              name:@"eye_bright"
                                                             value:input.value]);
  return result;
}

// 在代理方法中对视频数据进行处理
- (void)onNERtcEngineVideoFrameCaptured:(CVPixelBufferRef)bufferRef
                               rotation:(NERtcVideoRotationType)rotation {
#ifdef DEBUG
//    NSLog(@"FlutterCalled:FLTBeautyEngineApi#onNERtcEngineVideoFrameCaptured");
#endif
  if (_enableBeauty) {
    [[FUManager shareManager] renderItemsToPixelBuffer:bufferRef];
  }
}

- (nullable NEFUInt *)setMultiFUParams:(SetFaceUnityParamsRequest *)input
                                 error:(FlutterError *_Nullable *_Nonnull)error {
#ifdef DEBUG
  NSLog(@"FlutterCalled:FLTBeautyEngineApi#setBeautyParams");
#endif
  NEFUInt *result = [[NEFUInt alloc] init];
  NSMutableDictionary *fliterParams = [NSMutableDictionary dictionary];
  // 解包
  if (_enableBeauty) {
    if (input.filterLevel != nil) {
      [fliterParams setObject:input.filterLevel forKey:@"filterLevel"];
    }
    if (input.colorLevel != nil) {
      [fliterParams setObject:input.colorLevel forKey:@"colorLevel"];
    }
    if (input.redLevel != nil) {
      [fliterParams setObject:input.redLevel forKey:@"redLevel"];
    }
    if (input.blurLevel != nil) {
      [fliterParams setObject:input.blurLevel forKey:@"blurLevel"];
    }
    if (input.eyeBright != nil) {
      [fliterParams setObject:input.eyeBright forKey:@"eyeBright"];
    }
    if (input.eyeEnlarging != nil) {
      [fliterParams setObject:input.eyeEnlarging forKey:@"eyeEnlarging"];
    }
    if (input.cheekThinning != nil) {
      [fliterParams setObject:input.cheekThinning forKey:@"cheekThinning"];
    }
  }

  [[FUManager shareManager] loadFilter:fliterParams];

  int ret = _enableBeauty ? 0 : -1;
  result.value = @(ret);
  return result;
}

- (nullable NEFUInt *)release:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NEFUInt *result = [[NEFUInt alloc] init];
  //    int ret =  [[FUManager shareManager] isInitBeauty] ? 0 : -1;
  result.value = @(0);
  return result;
}

@end
