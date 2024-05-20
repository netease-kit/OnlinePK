// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

enum PlayerBufferStrategy {
  /// 直播极速模式 该模式延时最小,但是网络抖动时容易发生卡顿,不能用于点播
  /// Live streaming in top speed mode transmits data with the minimum delay. However, video frames freeze when the network jitters. The mode is not suitable for VOD.
  nelpTopSpeed,

  /// 直播低延时模式 该模式延时较小,流畅性比极速模式好,但是网络差时偶尔会发生卡顿,不能用于点播
  /// Live streaming in low-latency mode delivers data with a low latency and is better than the top-speed mode in fluency. However, occasional video freezes may occur when the network becomes unstable. The mode is not suitable for VOD.
  nelpLowDelay,

  /// 直播流畅模式 该模式流畅性最好,但是延时比直播低延时模式稍大一些,不能用于点播
  ///Live streaming in fluency mode has the best fluency, but the delay is slightly greater than the low-latency mode and the mode is not suitable for VOD.
  nelpFluent,

  /// 点播抗抖动模式 该模式缓冲区比较大，抗抖动性强，适合在在线点播和本地视频播放场景使用
  /// VOD streaming in anti-jitter mode has a larger buffer and stronger anti-jitter performance. The mode is suitable for online VOD and local video playback.
  nelpAntiJitter,

  /// 直播延时追赶模式 在需要回调时间戳时建议使用该模式不会丢帧
  /// Live streaming in pull up mode. We recommend you use this mode when the timestamp is required without dropping frames.
  nelpDelayPullUp,

  /// 网络直播, 延时追赶策略，策略更激进
  /// Live streaming in the delay pull up ultra mode.
  nelpDelayPullUpUltra
}

int bufferStrategy2Int(PlayerBufferStrategy type) {
  switch (type) {
    case PlayerBufferStrategy.nelpAntiJitter:
      return 3;
    case PlayerBufferStrategy.nelpDelayPullUp:
      return 4;
    case PlayerBufferStrategy.nelpFluent:
      return 2;
    case PlayerBufferStrategy.nelpLowDelay:
      return 1;
    case PlayerBufferStrategy.nelpTopSpeed:
      return 0;
    case PlayerBufferStrategy.nelpDelayPullUpUltra:
      return 5;
  }
}
