// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import '../../neliveplayer_platform_interface.dart';

/// An implementation of [NeliveplayerPlatform] that uses method channels.
class MethodChannelNeliveplayer extends NeliveplayerPlatform {
  final NeLivePlayerApi _api = NeLivePlayerApi();

  final NeLivePlayerListener _neLivePlayerListener = NeLivePlayerListener();

  MethodChannelNeliveplayer() {
    NeLivePlayerListenerApi.setup(_neLivePlayerListener);
  }

  @override
  Future<void> initAndroid(NeLiveConfig config) {
    return _api.initAndroid(config);
  }

  @override
  Future<void> release(String playerId) {
    return _api.release(playerId);
  }

  @override
  Future<void> setShouldAutoplay(String playerId, bool isAutoplay) {
    return _api.setShouldAutoplay(playerId, isAutoplay);
  }

  @override
  Future<String> create() {
    return _api.create();
  }

  @override
  Future<void> setPlayerUrl(String playerId, String dataSource) {
    return _api.setPlayUrl(playerId, dataSource);
  }

  @override
  Future<void> prepareAsync(String playerId) {
    return _api.prepareAsync(playerId);
  }

  @override
  Future<void> start(String playerId) {
    return _api.start(playerId);
  }

  @override
  Future<void> stop(String playerId) {
    return _api.stop(playerId);
  }

  @override
  Future<int> getCurrentPosition(String playerId) {
    return _api.getCurrentPosition(playerId);
  }

  @override
  Future<void> switchContentUrl(String playerId, String url) {
    return _api.switchContentUrl(playerId, url);
  }

  @override
  Future<void> addPreloadUrls(List<String> urls) {
    return _api.addPreloadUrls(urls);
  }

  @override
  Future<String> getVersion() {
    return _api.getVersion();
  }

  @override
  Future<Map<String?, PlayerPreloadState?>> queryPreloadUrls() {
    return _api.queryPreloadUrls().then((value) =>
        value.map((key, value) => MapEntry(key, getPreloadState(value))));
  }

  @override
  Future<void> removePreloadUrls(List<String> urls) {
    return _api.removePreloadUrls(urls);
  }

  @override
  Future<void> setAutoRetryConfig(String playerId, NEAutoRetryConfig config) {
    return _api.setAutoRetryConfig(playerId, config);
  }

  @override
  Future<void> setBufferStrategy(
      String playerId, PlayerBufferStrategy bufferStrategy) {
    return _api.setBufferStrategy(playerId, bufferStrategy2Int(bufferStrategy));
  }

  @override
  Future<void> setHardwareDecoder(String playerId, bool isOpen) {
    return _api.setHardwareDecoder(playerId, isOpen);
  }

  @override
  Future<void> setMute(String playerId, bool isMute) {
    return _api.setMute(playerId, isMute);
  }

  @override
  Future<void> setPlaybackTimeout(String playerId, int timeout) {
    return _api.setPlaybackTimeout(playerId, timeout);
  }

  @override
  Future<void> setVolume(String playerId, double volume) {
    return _api.setVolume(playerId, volume);
  }

  @override
  Future<void> setPreloadResultValidityIos(int validity) {
    return _api.setPreloadResultValidityIos(validity);
  }

  @override
  void setOnCompletionListener(
      void Function(String playerId)? onCompletionListener) {
    _neLivePlayerListener.onCompletionListener = onCompletionListener;
  }

  @override
  void setOnErrorListener(
      void Function(String playerId, PlayerErrorType what, int extra)?
          onErrorListener) {
    _neLivePlayerListener.onErrorListener = onErrorListener;
  }

  @override
  void setOnFirstAudioDisplayedListener(
      void Function(String playerId)? onFirstAudioDisplayListener) {
    _neLivePlayerListener.onFirstAudioDisplayListener =
        onFirstAudioDisplayListener;
  }

  @override
  void setOnFirstVideoDisplayedListener(
      void Function(String playerId)? onFirstVideoDisplayListener) {
    _neLivePlayerListener.onFirstVideoDisplayListener =
        onFirstVideoDisplayListener;
  }

  @override
  void setOnLoadStateChangedListener(
      void Function(String playerId, PlayStateType type, int extra)?
          onLoadStateChangeListener) {
    _neLivePlayerListener.onLoadStateChangeListener = onLoadStateChangeListener;
  }

  @override
  void setOnPreparedListener(
      void Function(String playerId)? onPreparedListener) {
    _neLivePlayerListener.onPreparedListener = onPreparedListener;
  }

  @override
  void setOnReleasedListener(
      void Function(String playerId)? onReleasedListener) {
    _neLivePlayerListener.onReleasedListener = onReleasedListener;
  }

  @override
  void setOnVideoSizeChangedListener(
      void Function(String playerId, int width, int height)?
          onVideoSizeChangedListener) {
    _neLivePlayerListener.onVideoSizeChangedListener =
        onVideoSizeChangedListener;
  }
}
