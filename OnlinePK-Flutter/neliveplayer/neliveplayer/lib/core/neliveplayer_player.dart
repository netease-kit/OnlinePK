// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:neliveplayer_platform_interface/neliveplayer_platform_interface.dart';

class NELivePlayer {
  NELivePlayer._(this._playerId,
      {this.textureIdAndroid,
      this.onPreparedListener,
      this.onCompletionListener,
      this.onErrorListener,
      this.onVideoSizeChangedListener,
      this.onReleasedListener,
      this.onLoadStateChangeListener,
      this.onFirstVideoDisplayListener,
      this.onFirstAudioDisplayListener}) {
    _initListener();
  }

  String _playerId;

  String? textureIdAndroid;

  String get playerId => _playerId;

  ///注册一个回调函数，在视频预处理完成后调用
  /// Register a callback that is called when the video pre-processing is complete
  void Function()? onPreparedListener;

  ///注册一个回调函数，在视频播放完成后调用
  /// Register a callback that is called when the video playback is complete
  void Function()? onCompletionListener;

  ///注册一个回调函数，监听错误状态
  /// Register a callback that is called when an error occurs
  void Function(PlayerErrorType what, int extra)? onErrorListener;

  ///注册一个回调函数，在视频大小发生变化时调用
  /// Register a callback that is called when the video size changes
  void Function(int width, int height)? onVideoSizeChangedListener;

  ///注册一个回调函数，在release操作完成时调用
  ///Register a callback that is called when the release operation is complete
  void Function()? onReleasedListener;

  ///视频加载状态变化时回调
  ///Called when the video loading state changes
  void Function(PlayStateType type, int extra)? onLoadStateChangeListener;

  ///注册一个回调函数，在第一帧视频显示时回调
  ///Register a callback that is called when the first video frame is loaded
  void Function()? onFirstVideoDisplayListener;

  ///注册一个回调函数，在第一帧音频完成时回调
  ///Register a callback that is called when the first audio frame plays
  void Function()? onFirstAudioDisplayListener;

  void _initListener() {
    NeliveplayerPlatform.instance.setOnFirstVideoDisplayedListener((id) {
      if (playerId == id && onFirstVideoDisplayListener != null) {
        onFirstVideoDisplayListener!();
      }
    });

    NeliveplayerPlatform.instance.setOnFirstAudioDisplayedListener((id) {
      if (playerId == id && onFirstAudioDisplayListener != null) {
        onFirstAudioDisplayListener!();
      }
    });

    NeliveplayerPlatform.instance
        .setOnLoadStateChangedListener((id, type, extra) {
      if (playerId == id && onLoadStateChangeListener != null) {
        onLoadStateChangeListener!(type, extra);
      }
    });

    NeliveplayerPlatform.instance.setOnReleasedListener((id) {
      if (playerId == id && onReleasedListener != null) {
        onReleasedListener!();
      }
    });

    NeliveplayerPlatform.instance.setOnErrorListener((id, what, extra) {
      if (playerId == id && onErrorListener != null) {
        onErrorListener!(what, extra);
      }
    });

    NeliveplayerPlatform.instance.setOnCompletionListener((id) {
      if (playerId == id && onCompletionListener != null) {
        onCompletionListener!();
      }
    });

    NeliveplayerPlatform.instance.setOnPreparedListener((id) {
      if (playerId == id && onPreparedListener != null) {
        onPreparedListener!();
      }
    });

    NeliveplayerPlatform.instance
        .setOnVideoSizeChangedListener((id, width, height) {
      if (playerId == id && onVideoSizeChangedListener != null) {
        onVideoSizeChangedListener!(width, height);
      }
    });
  }

  ///Android初始化SDK,使用播放器时必须先进行初始化才能进行后续操作。
  ///Initialize SDK for Android. To run the player, initialize the SDK first.
  static Future<void> initAndroid(NeLiveConfig config) async {
    return NeliveplayerPlatform.instance.initAndroid(config);
  }

  ///创建播放器实例
  ///Create a player instance
  static Future<NELivePlayer> create({
    void Function()? onPreparedListener,
    void Function()? onCompletionListener,
    void Function(PlayerErrorType what, int extra)? onErrorListener,
    void Function(int width, int height)? onVideoSizeChangedListener,
    void Function()? onReleasedListener,
    void Function(PlayStateType type, int extra)? onLoadStateChangeListener,
    void Function()? onFirstVideoDisplayListener,
    void Function()? onFirstAudioDisplayListener,
  }) {
    return NeliveplayerPlatform.instance.create().then((value) {
      String playerId;
      String? textureId;
      if (Platform.isIOS) {
        playerId = value;
      } else if (Platform.isAndroid) {
        List<String> ids = value.split('+');
        playerId = ids.first;
        textureId = ids.last;
      } else {
        playerId = '';
      }

      return NELivePlayer._(playerId,
          textureIdAndroid: textureId,
          onPreparedListener: onPreparedListener,
          onCompletionListener: onCompletionListener,
          onErrorListener: onErrorListener,
          onVideoSizeChangedListener: onVideoSizeChangedListener,
          onReleasedListener: onReleasedListener,
          onLoadStateChangeListener: onLoadStateChangeListener,
          onFirstAudioDisplayListener: onFirstAudioDisplayListener,
          onFirstVideoDisplayListener: onFirstVideoDisplayListener);
    });
  }

  ///获取SDK版本号
  /// Get the SDK version
  static Future<String> getVersion() {
    return NeliveplayerPlatform.instance.getVersion();
  }

  ///添加预调度拉流链接地址
  ///Add preload URLs
  static Future<void> addPreloadUrls(List<String> urls) {
    return NeliveplayerPlatform.instance.addPreloadUrls(urls);
  }

  ///查询预调度拉流链接地址的结果信息
  ///Query preloaded URLs
  static Future<Map<String?, PlayerPreloadState?>> queryPreloadUrls() {
    return NeliveplayerPlatform.instance.queryPreloadUrls();
  }

  ///移除预调度拉流链接地址
  ///Remove preloaded URLs
  static Future<void> removePreloadUrls(List<String> urls) {
    return NeliveplayerPlatform.instance.removePreloadUrls(urls);
  }

  ///设置预调度结果有效期
  ///validity 有效期(单位秒)。默认：30*60 最小取值：60
  ///Android 可以设置initAndroid 中的Config：refreshPreLoadDuration
  ///Set the validity period for preload results for iOS
  ///validity Validity period in seconds. Default value: 30*60. Minimal value: 60.
  ///Android Set initAndroid in Config: refreshPreLoadDuration
  static Future<void> setPreloadResultValidityIos(int validity) {
    return NeliveplayerPlatform.instance.setPreloadResultValidityIos(validity);
  }

  ///释放播放器所有资源
  /// Release all resources consumed by the player
  Future<void> release() {
    return NeliveplayerPlatform.instance.release(_playerId);
  }

  ///设置prepareAsync完成后是否自动播放，若设置成false，需要手动调用start()进行播放, 在prepareAsync前调用
  /// Enable or disable autoPlay after prepareAsync is complete.
  /// If the value is set to false, you must manually play by calling the start() method before prepareAsync is called.
  Future<void> setShouldAutoplay(bool isAutoplay) {
    return NeliveplayerPlatform.instance
        .setShouldAutoplay(_playerId, isAutoplay);
  }

  ///设置播放地址，在prepareAsync前调用
  /// Set playback URLs before calling prepareAsync.
  Future<void> setPlayerUrl(String dataSource) {
    return NeliveplayerPlatform.instance.setPlayerUrl(_playerId, dataSource);
  }

  ///预处理播放器，为播放做准备
  ///Get prepared for playback
  Future<void> prepareAsync() {
    return NeliveplayerPlatform.instance.prepareAsync(_playerId);
  }

  ///开始播放
  ///Start playback
  Future<void> start() {
    return NeliveplayerPlatform.instance.start(_playerId);
  }

  ///停止播放
  ///Stop playback
  Future<void> stop() {
    return NeliveplayerPlatform.instance.stop(_playerId);
  }

  /// 获取当前播放位置的时间点 单位: ms, 需要在收到onPrepare的通知后调用
  /// 返回:
  /// 当前播放位置的时间点 -1: 失败
  /// Get the timestamp of the current playback position. Unit: milliseconds.
  /// The method is called after receiving the notification sent by onPrepare.
  /// Return:
  /// The current playback position. -1: failure
  Future<int> getCurrentPosition() {
    return NeliveplayerPlatform.instance.getCurrentPosition(_playerId);
  }

  ///播放过程中切换播放地址，第一次播放不能调用该接口，仅支持当前播放结束切换到下一个视频，或者播放过程中切换下一个视频
  /// 参数:
  /// url - 播放地址
  /// You can change the playback URL during playback. You cannot call the API for the first playback.
  /// However, you can change the URL for the following video file or switch to the next video file during playback.
  /// Parameter:
  /// url - playback URL
  Future<void> switchContentUrl(String url) {
    return NeliveplayerPlatform.instance.switchContentUrl(_playerId, url);
  }

  ///配置自动重试信息
  /// Configure auto retry settings
  Future<void> setAutoRetryConfig(NEAutoRetryConfig config) {
    return NeliveplayerPlatform.instance.setAutoRetryConfig(_playerId, config);
  }

  ///设置缓冲策略, 在prepaerAsync前调用 默认使用nelpLowDelay为直播低延时模式。
  /// Set a buffer strategy before calling prepareAsync. By default, use nelpLowDelay for low latency mode.
  Future<void> setBufferStrategy(PlayerBufferStrategy bufferStrategy) {
    return NeliveplayerPlatform.instance
        .setBufferStrategy(_playerId, bufferStrategy);
  }

  ///设置是否开启硬件解码, 在prepareAsync前调用 默认使用软件解码
  /// Enable or disable hardware decoding before calling prepareAsync. By default, the software decoding mode is used.
  Future<void> setHardwareDecoder(bool isOpen) {
    return NeliveplayerPlatform.instance.setHardwareDecoder(_playerId, isOpen);
  }

  ///设置静音
  /// Mute the volume
  Future<void> setMute(bool isMute) {
    return NeliveplayerPlatform.instance.setMute(_playerId, isMute);
  }

  ///设置拉流超时时间, 需要在设置播放路径接口后调用(范围: 0 ~ 10秒,不包括0,默认是10秒，设置的值超过10秒使用默认值)
  /// Set the playback timeout. Call the API after you configure the playback path. Timeout range: 0 ~ 10 seconds.
  /// The value 0 is excluded. The default value is 10. If a value is set to a number greater than 10, the default value is applied.
  Future<void> setPlaybackTimeout(int timeout) {
    return NeliveplayerPlatform.instance.setPlaybackTimeout(_playerId, timeout);
  }

  ///设置音量(0.0 ~ 1.0, 0.0为静音，1.0为最大)
  /// Set the volume. Volume range: 0.0 ~ 1.0. A value of 0.0 indicates the muted state and 1.0 indicates the maximum volume.
  Future<void> setVolume(double volume) {
    return NeliveplayerPlatform.instance.setVolume(_playerId, volume);
  }
}
