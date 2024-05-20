// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Flutter
import NELivePlayerFramework
import UIKit

class FLTNELivePlayerEvent: NSObject {
  private var listener: FLTNeLivePlayerListenerApi?
  public var playerId: String?

  init(listener: FLTNeLivePlayerListenerApi) {
    super.init()
    self.listener = listener
  }

  deinit {
    print("FLTNELivePlayerEvent release")
  }
}

extension FLTNELivePlayerEvent {
  func addObservers() {
    // 调用prepareToPlay后，播放器初始化视频文件完成后的消息通知
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(preparedToPlay),
      name: NSNotification.Name.NELivePlayerDidPreparedToPlay,
      object: nil
    )
    /*
     播放器播放完成或播放发生错误时的消息通知。
     携带UserInfo:{NELivePlayerPlaybackDidFinishReasonUserInfoKey : [NSNumber],
     NELivePlayerPlaybackDidFinishErrorKey : [NSNumber]}
     */
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(playbackFinished),
      name: NSNotification.Name.NELivePlayerPlaybackFinished,
      object: nil
    )

    /*
     播放器视频尺寸发生改变时的消息通知
     携带UserInfo:{
     NELivePlayerVideoWidthKey : @(width),
     NELivePlayerVideoHeightKey: @(height)
     }
     */
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(videoSizeChanged),
      name: NSNotification.Name.NELivePlayerVideoSizeChanged,
      object: nil
    )
    // 播放器资源释放完成时的消息通知
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(playerReleaseSueecss),
      name: NSNotification.Name.NELivePlayerReleaseSueecss,
      object: nil
    )
    // 播放器第一帧视频显示时的消息通知
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(playerFirstVideoDisplayed),
      name: NSNotification.Name.NELivePlayerFirstVideoDisplayed,
      object: nil
    )
    // 播放器第一帧音频播放时的消息通知
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(playerFirstAudioDisplayed),
      name: NSNotification.Name.NELivePlayerFirstAudioDisplayed,
      object: nil
    )
    // 播放器加载状态发生改变时的消息通知
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(playerLoadStateChanged),
      name: NSNotification.Name.NELivePlayerLoadStateChanged,
      object: nil
    )
  }

  func removeObserver() {
    NotificationCenter.default.removeObserver(self)
    listener = nil
  }

  @objc func preparedToPlay(notify: Notification) {
    print("preparedToPlay be called")
    guard let pid = playerId else {
      print("playerId is nil")
      return
    }
    listener?.onPreparedPlayerId(pid, completion: { _ in })
  }

  @objc func playbackFinished(notify: Notification) {
    print("playbackFinished be called")
    guard let pid = playerId else {
      print("playerId is nil")
      return
    }

    let userInfo = notify.userInfo as! [String: AnyObject]
    let errorCode = userInfo[NELivePlayerPlaybackDidFinishErrorKey] as? NSNumber

    if let finishReason = userInfo[NELivePlayerPlaybackDidFinishReasonUserInfoKey] as? NSNumber {
      switch finishReason.intValue {
      case NELPMovieFinishReason.playbackEnded.rawValue:
        listener?.onCompletionPlayerId(pid, completion: { _ in })

      case NELPMovieFinishReason.playbackError.rawValue:
        if let code = errorCode {
          print("playbackError errorCode = \(code)")
          listener?.onErrorPlayerId(pid, what: code, extra: 0, completion: { _ in })
        }

      default:
        print("NELPMovieFinishReasonUserExited")
      }
    }
  }

  @objc func videoSizeChanged(notify: Notification) {
    print("videoSizeChanged be called")
    guard let pid = playerId else {
      print("playerId is nil")
      return
    }

    let userInfo = notify.userInfo as! [String: AnyObject]
    if let widthValue = (userInfo[NELivePlayerVideoWidthKey] as? NSNumber),
       let heightValue = userInfo[NELivePlayerVideoHeightKey] as? NSNumber {
      listener?.onVideoSizeChangedPlayerId(
        pid,
        width: widthValue,
        height: heightValue,
        completion: { _ in }
      )

    } else {
      print("widthValue or heightValue is nil")
      listener?.onVideoSizeChangedPlayerId(
        pid,
        width: NSNumber(value: 0),
        height: NSNumber(value: 0),
        completion: { _ in }
      )
    }
  }

  @objc func playerReleaseSueecss(notify: Notification) {
    print("playerReleaseSueecss be called")
    guard let pid = playerId else {
      print("playerId is nil")
      return
    }
    listener?.onReleasedPlayerId(pid, completion: { _ in })
  }

  @objc func playerFirstVideoDisplayed(notify: Notification) {
    print("playerFirstVideoDisplayed be called")
    guard let pid = playerId else {
      print("playerId is nil")
      return
    }
    listener?.onFirstVideoDisplayPlayerId(pid, completion: { _ in })
  }

  @objc func playerFirstAudioDisplayed(notify: Notification) {
    print("playerFirstAudioDisplayed be called")
    guard let pid = playerId else {
      print("playerId is nil")
      return
    }
    listener?.onFirstAudioDisplayPlayerId(pid, completion: { _ in })
  }

  @objc func playerLoadStateChanged(notify: Notification) {
    print("playerLoadStateChanged be called")
    guard let pid = playerId else {
      print("playerId is nil")
      return
    }

    guard let player = NEPlayerSingleton.shared().players
      .value(forKey: pid) as? NELivePlayerController else {
      print("player is nil")
      return
    }

    let state = player.loadState
    listener?.onLoadStateChangePlayerId(
      pid,
      state: NSNumber(value: state.rawValue),
      extra: 0,
      completion: { _ in }
    )
  }
}
