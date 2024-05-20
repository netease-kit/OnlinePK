// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../neliveplayer_platform_interface.dart';

abstract class NeliveplayerPlatform extends PlatformInterface {
  /// Constructs a NeliveplayerPlatform.
  NeliveplayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static NeliveplayerPlatform _instance = MethodChannelNeliveplayer();

  /// The default instance of [NeliveplayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelNeliveplayer].
  static NeliveplayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NeliveplayerPlatform] when
  /// they register themselves.
  static set instance(NeliveplayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initAndroid(NeLiveConfig config) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> release(String playerId) {
    throw UnimplementedError('release() has not been implemented.');
  }

  Future<void> setShouldAutoplay(String playerId, bool isAutoplay) {
    throw UnimplementedError('setShouldAutoplay() has not been implemented.');
  }

  Future<String> create() {
    throw UnimplementedError('create() has not been implemented.');
  }

  Future<void> setPlayerUrl(String playerId, String dataSource) {
    throw UnimplementedError('setDataSource() has not been implemented.');
  }

  Future<void> prepareAsync(String playerId) {
    throw UnimplementedError('prepareAsync() has not been implemented.');
  }

  Future<void> start(String playerId) {
    throw UnimplementedError('start() has not been implemented.');
  }

  Future<void> stop(String playerId) {
    throw UnimplementedError('stop() has not been implemented.');
  }

  Future<int> getCurrentPosition(String playerId) {
    throw UnimplementedError('getCurrentPosition() has not been implemented.');
  }

  Future<void> switchContentUrl(String playerId, String url) {
    throw UnimplementedError('switchContentUrl() has not been implemented.');
  }

  Future<String> getVersion();

  Future<void> addPreloadUrls(List<String> urls);

  Future<void> removePreloadUrls(List<String> urls);

  Future<Map<String?, PlayerPreloadState?>> queryPreloadUrls();

  Future<void> setBufferStrategy(
      String playerId, PlayerBufferStrategy bufferStrategy);

  Future<void> setHardwareDecoder(String playerId, bool isOpen);

  Future<void> setPlaybackTimeout(String playerId, int timeout);

  Future<void> setAutoRetryConfig(String playerId, NEAutoRetryConfig config);

  Future<void> setMute(String playerId, bool isMute);

  Future<void> setVolume(String playerId, double volume);

  Future<void> setPreloadResultValidityIos(int validity);

  void setOnPreparedListener(
      void Function(String playerId)? onPreparedListener);

  ///android setOnInfoListener
  void setOnLoadStateChangedListener(
      void Function(String playerId, PlayStateType type, int extra)?
          onLoadStateChangeListener);

  void setOnCompletionListener(
      void Function(String playerId)? onCompletionListener);

  ///android setOnInfoListener
  void setOnFirstVideoDisplayedListener(
      void Function(String playerId)? onFirstVideoDisplayListener);

  ///android setOnInfoListener
  void setOnFirstAudioDisplayedListener(
      void Function(String playerId)? onFirstAudioDisplayListener);

  void setOnVideoSizeChangedListener(
      void Function(String playerId, int width, int height)?
          onVideoSizeChangedListener);

  void setOnReleasedListener(
      void Function(String playerId)? onReleasedListener);

  void setOnErrorListener(
      void Function(String playerId, PlayerErrorType what, int extra)?
          onErrorListener);
}
