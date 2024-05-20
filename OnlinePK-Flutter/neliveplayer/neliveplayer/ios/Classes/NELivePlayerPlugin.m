// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NELivePlayerPlugin.h"
#import "FLTNativeViewFactory.h"

#if __has_include(<neliveplayer_core/neliveplayer_core-Swift.h>)
#import <neliveplayer_core/neliveplayer_core-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "neliveplayer_core-Swift.h"

#endif

@implementation NELivePlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  // 添加注册我们创建的 view ，注意这里的 withId 需要和 flutter 侧的值相同
  [registrar
      registerViewFactory:[[FLTNativeViewFactory alloc] initWithMessenger:registrar.messenger]
                   withId:@"platform_video_view"];

  [SwiftNELivePlayerPlugin registerWithRegistrar:registrar];
}
@end
