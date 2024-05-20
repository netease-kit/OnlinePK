// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Flutter
import NELivePlayerFramework
import UIKit

class FLTNELivePlayer: NSObject, FLTNeLivePlayerApi {
  private let lPGslbUrlKey = "NELPGslbUrlKey"
  private let lPGslbStatusKey = "NELPGslbStatusKey"
  private var playerEvent: FLTNELivePlayerEvent?

  func initAndroidConfig(_ config: FLTNeLiveConfig,
                         error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {}

  func createWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> String? {
    print("create is called")

    let player = NELivePlayerController()
    let hashCode = String(player.hashValue)
    NEPlayerSingleton.shared().players.setValue(player, forKey: hashCode)
    playerEvent?.playerId = hashCode
    return hashCode
  }

  func setPlayUrlPlayerId(_ playerId: String, path: String,
                          error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> NSNumber? {
    print("setPlayUrl is called")
    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return NSNumber(value: false)
    }

    if let url = URL(string: path) {
      player.setPlay(url)
      return NSNumber(value: true)
    } else {
      print("play url is nil")
      return NSNumber(value: false)
    }
  }

  func getVersionWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> String? {
    print("getVersion is called")
    return NELivePlayerController.getSDKVersion()
  }

  func addPreloadUrlsUrls(_ urls: [String],
                          error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("addPreloadUrls is called,urls = \(urls)")
    NELivePlayerController.addPreloadUrls(urls)
  }

  func removePreloadUrlsUrls(_ urls: [String],
                             error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("removePreloadUrls is called,urls = \(urls)")
    NELivePlayerController.removePreloadUrls(urls)
  }

  func queryPreloadUrlsWithError(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> [String: NSNumber]? {
    print("queryPreloadUrls is called")
    var key = ""
    var value = 0
    NELivePlayerController.queryPreloadTasks { tasks in
      tasks.forEach { task in
        if self.lPGslbUrlKey == (task.keys.first as! String) {
          key = task[self.lPGslbUrlKey] as! String
        }
        if self.lPGslbStatusKey == (task.keys.first as! String) {
          value = task[self.lPGslbStatusKey] as! Int
        }
      }
    }
    return [key: NSNumber(value: value)]
  }

  func setBufferStrategyPlayerId(_ playerId: String, bufferStrategy: NSNumber,
                                 error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("setBufferStrategy is called,bufferStrategy = \(bufferStrategy)")

    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return
    }

    if let buffer = NELPBufferStrategy(rawValue: bufferStrategy.intValue) {
      player.setBufferStrategy(buffer)
    } else {
      print("bufferStrategy is empty")
    }
  }

  func setHardwareDecoderPlayerId(_ playerId: String, isOpen: NSNumber,
                                  error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("setHardwareDecoder is called,isOpen = \(isOpen)")

    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return
    }
    player.setHardwareDecoder(isOpen.boolValue)
  }

  func setPlaybackTimeoutPlayerId(_ playerId: String, timeout: NSNumber,
                                  error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("setPlaybackTimeout is called,timeout = \(timeout)")
    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return
    }
    player.setPlaybackTimeout(timeout.intValue)
  }

  func setAutoRetryConfigPlayerId(_ playerId: String, config: FLTNEAutoRetryConfig,
                                  error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("setAutoRetryConfig is called")
    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return
    }

    let config = NELPRetryConfig()
    config.count = config.count
    config.defaultIntervalS = config.defaultIntervalS
    config.customIntervalS = config.customIntervalS
    player.setRetryConfig(config)
  }

  func setMutePlayerId(_ playerId: String, isMute: NSNumber,
                       error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("setMute is called,isMute = \(isMute)")
    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return
    }
    player.setMute(isMute.boolValue)
  }

  func setVolumePlayerId(_ playerId: String, volume: NSNumber,
                         error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("setVolumeVolume is called,volume = \(volume)")
    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return
    }
    player.setVolume(volume.floatValue)
  }

  func releasePlayerId(_ playerId: String,
                       error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("release is called")
    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return
    }
    player.shutdown()
    NEPlayerSingleton.shared().players.removeObject(forKey: playerId)
  }

  func setShouldAutoplayPlayerId(_ playerId: String, isAutoplay: NSNumber,
                                 error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("setShouldAutoplay is called,isAutoplay = \(isAutoplay)")
    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return
    }
    player.shouldAutoplay = isAutoplay.boolValue
  }

  func prepareAsyncPlayerId(_ playerId: String,
                            error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("prepareAsync is called")
    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return
    }
    player.prepareToPlay()
  }

  func startPlayerId(_ playerId: String,
                     error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("start is called")
    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return
    }
    player.play()
  }

  func stopPlayerId(_ playerId: String, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("stop is called")
    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return
    }
    player.pause()
  }

  func getCurrentPositionPlayerId(_ playerId: String,
                                  error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    -> NSNumber? {
    print("getCurrentPosition is called")
    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return NSNumber(value: 0)
    }
    return NSNumber(value: player.currentPlaybackTime())
  }

  func switchContentUrlPlayerId(_ playerId: String, url: String,
                                error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
    print("switchContentUrlUrl is called")

    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: playerId) as? NELivePlayerController else {
      print("player is nil")
      return
    }

    if let url = URL(string: url) {
      player.switchContentUrl(url)
    } else {
      print("switchUrl is nil")
    }
  }

  func setPreloadResultValidityIosValidity(_ validity: NSNumber,
                                           error: AutoreleasingUnsafeMutablePointer<
                                             FlutterError?
                                           >) {
    print("setPreloadResultValidity is called")
    NELivePlayerController.setPreloadResultValidityS(validity.intValue)
  }
}

extension FLTNELivePlayer: FLTAssociativeWrapper {
  func onAttachedToEngine(_ registrar: FlutterPluginRegistrar) {
    FLTNeLivePlayerApiSetup(registrar.messenger(), self)
    playerEvent =
      FLTNELivePlayerEvent(listener: FLTNeLivePlayerListenerApi(binaryMessenger: registrar
          .messenger()))
    playerEvent?.addObservers()
  }

  func onDetachedFromEngine(_ registrar: FlutterPluginRegistrar) {
    FLTNeLivePlayerApiSetup(registrar.messenger(), nil)
    if let _ = playerEvent {
      playerEvent?.removeObserver()
    }
    playerEvent = nil
  }
}
