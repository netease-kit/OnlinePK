//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<nertc_core/NERtcCorePlugin.h>)
#import <nertc_core/NERtcCorePlugin.h>
#else
@import nertc_core;
#endif

#if __has_include(<nertc_faceunity/NERtcFaceUnityFlutterPlugin.h>)
#import <nertc_faceunity/NERtcFaceUnityFlutterPlugin.h>
#else
@import nertc_faceunity;
#endif

#if __has_include(<package_info/FLTPackageInfoPlugin.h>)
#import <package_info/FLTPackageInfoPlugin.h>
#else
@import package_info;
#endif

#if __has_include(<path_provider_foundation/PathProviderPlugin.h>)
#import <path_provider_foundation/PathProviderPlugin.h>
#else
@import path_provider_foundation;
#endif

#if __has_include(<permission_handler/PermissionHandlerPlugin.h>)
#import <permission_handler/PermissionHandlerPlugin.h>
#else
@import permission_handler;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

#if __has_include(<yunxin_alog/FlutterAlogPlugin.h>)
#import <yunxin_alog/FlutterAlogPlugin.h>
#else
@import yunxin_alog;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [NERtcCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"NERtcCorePlugin"]];
  [NERtcFaceUnityFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"NERtcFaceUnityFlutterPlugin"]];
  [FLTPackageInfoPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPackageInfoPlugin"]];
  [PathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"PathProviderPlugin"]];
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
  [FlutterAlogPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterAlogPlugin"]];
}

@end
