// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

// **************************************************************************

class NeLiveConfig {
  /// 是否对预处理和缓冲进行超时保护 默认false开启对预处理和缓冲进行超时保护，
  /// 如果应用层需要自己处理预处理和缓冲的超时逻辑可以设置为true关掉该功能。
  /// Whether timeout protection is applied for preload and buffering. The default value false enables timeout protection for preload and buffering
  /// If you want the application layer to handle the timeout logic for preload and buffering, set the value to true to disable the option.
  final bool? isCloseTimeOutProtect;

  /// 预调度刷新间隔 单位：ms，默认30分钟（30 * 60 * 1000）
  /// The interval for refreshing preload in milliseconds. The default value is 30 minutes(30 * 60 * 1000)
  final int? refreshPreLoadDuration;

  /// 应用层传入到SDK中的能区分设备的id值，方便用户通过该值查询到对应播放数据和日志
  /// The ID taken from the application layer and used to identify end-user devices. Users can query playback data and logs using this ID.
  final String? thirdUserId;

  NeLiveConfig(
      {this.isCloseTimeOutProtect,
      this.refreshPreLoadDuration,
      this.thirdUserId});
}

class NEAutoRetryConfig {
  /// 自动重试次数，-1代表无限重试，0代表不重试，默认值是0
  /// The number of retry attempts. -1: infinite retry attempts; 0: no retry attempts. The default value is 0.
  final int? count;

  /// 自动重试的默认时间间隔，以ms为单位，必须大于0，小于0时按0处理；
  /// 是指播放器内部在检测到错误时等待重试的时间间隔
  /// The default duration between automatic retries in milliseconds. The interval value must be greater than 0. If a value less than 0 is specified, the value 0 is applied.
  /// The interval indicates the time from an error occurrence to starting a retry.
  final int? delayDefault;

  /// 自动重试时间间隔的分次配置数组 数组可以为空，如果数组元素个数大于重试次数，取前面的重试次数个值；
  /// 如果小于，后面未配置的值使用默认时间间隔。
  /// An array that contains the number of retry attempts and respective duration for each retry. The array can be empty. If the number of elements in the array is greater than the number of retry attempts, use the number of retry attempts.
  /// If the number of elements in the array is less than the number of retry attempts, use the default retry duration for unspecified values.
  final List<int?>? delayArray;

  NEAutoRetryConfig({this.count, this.delayDefault, this.delayArray});
}

// **************************************************************************
@HostApi()
abstract class NeLivePlayerApi {
  void initAndroid(NeLiveConfig config);

  String create();

  void release(String playerId);

  void setShouldAutoplay(String playerId, bool isAutoplay);

  bool setPlayUrl(String playerId, String path);

  void prepareAsync(String playerId);

  void start(String playerId);

  void stop(String playerId);

  int getCurrentPosition(String playerId);

  void switchContentUrl(String playerId, String url);

  String getVersion();

  void addPreloadUrls(List<String> urls);

  void removePreloadUrls(List<String> urls);

  Map<String, int> queryPreloadUrls();

  void setBufferStrategy(String playerId, int bufferStrategy);

  void setHardwareDecoder(String playerId, bool isOpen);

  void setPlaybackTimeout(String playerId, int timeout);

  void setAutoRetryConfig(String playerId, NEAutoRetryConfig config);

  void setMute(String playerId, bool isMute);

  void setVolume(String playerId, double volume);

  void setPreloadResultValidityIos(int validity);
}

@FlutterApi()
abstract class NeLivePlayerListenerApi {
  void onPrepared(String playerId);

  void onCompletion(String playerId);

  void onError(String playerId, int what, int extra);

  void onVideoSizeChanged(String playerId, int width, int height);

  void onReleased(String playerId);

  void onFirstVideoDisplay(String playerId);

  void onFirstAudioDisplay(String playerId);

  void onLoadStateChange(String playerId, int state, int extra);
}
