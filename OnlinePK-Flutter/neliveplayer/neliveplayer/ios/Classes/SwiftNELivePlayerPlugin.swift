// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Flutter
import UIKit

public class SwiftNELivePlayerPlugin: NSObject, FlutterPlugin {
  private var linker: FLTLinker?

  public static func register(with registrar: FlutterPluginRegistrar) {
    //        let channel = FlutterMethodChannel(name: "neliveplayer", binaryMessenger:
    //        registrar.messenger())
    //        let instance = SwiftNELivePlayerPlugin()
    //        registrar.addMethodCallDelegate(instance, channel: channel)

    let instance = SwiftNELivePlayerPlugin()
    instance.linker = FLTLinker()
    instance.linker?.onAttachedToEngine(registrar)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    linker?.onDetachedToEngine(registrar)
    linker = nil
  }
}
