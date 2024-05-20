// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

enum PlayStateType {
  /// 标识音视频不同步 可以在此在UI提示用户切换其他清晰度观看 该消息会在高清晰度时
  /// （如：1080p）设备性能较差导致音视频不同步的情况下回调给用户
  /// Constant for the playback state of audio and video out of sync. Users are prompted to switch to other resolutions in the UI.
  /// The message will be returned to users when the player play a high-resolution video (for example, 1080p) and audio and video are out of sync.
  nelpAudioVideoUnSync,

  ///  标识缓冲结束
  ///  Buffering ends
  nelpBufferingEnd,

  ///  标识缓冲开始
  ///  Buffering starts
  nelpBufferingStart,

  ///  解密成功
  ///  Decryption success
  nelpDecryptionSuccess,

  ///标识解码卡顿, 在解码时间过长时通知； 可以在此在UI上提示用户解码时间过长造成卡顿
  ///Video frames freeze during decoding. Users are prompted that the decoding time is too long on the UI.
  nelpNetDecodeBad,

  /// 标识网络状态比较差, 如果有多种清晰度，在没有开启自动切换清晰度时，建议在此切换到低清晰度；
  /// 可以在此在UI上提示用户网络状态较差
  /// Bad network state.  If multiple resolutions are available, we recommend you switch to a low resolution when automatic resolution switching is disabled;
  /// Users are prompted that the network status is poor on the UI.
  nelpNetStateBad,

  /// 标识视频解码开启情况，在开启视频软解或者硬解时通知 附件信息'extra'字段表示是否开启硬件解码，
  /// 'extra'是1时开启了硬件解码，其他值时开启了软解解码
  /// Video decoding state. Users are prompted that the video decoding state with software or hardware decoding enabled. The extra field of the additional information indicates whether hardware decoding or software decoding is enabled.
  /// If extra is set to 1, hardware decoding is enabled. If other values are used, software decoding is enabled.
  nelpVideoDecoderOpen,

  /// 在该状态下，播放器初始化完成，可以播放，若shouldAutoplay 设置成YES，播放器初始化完成后会自动播放
  /// iOS状态码，安卓不会返回。
  /// The player is initialized in this state and ready to play the video file. If shouldAutoplay is set to YES, automatic playback starts after the player is initialized.
  /// Status code on iOS. No return code on Android.
  nelpVideoPlayable,

  ///未知
  /// Unknown state
  nelpUnknownState
}

PlayStateType covertPlayStateType(int state) {
  if (Platform.isAndroid) {
    switch (state) {
      case 900:
        return PlayStateType.nelpAudioVideoUnSync;
      case 702:
        return PlayStateType.nelpBufferingEnd;
      case 701:
        return PlayStateType.nelpBufferingStart;
      case 1101:
        return PlayStateType.nelpDecryptionSuccess;
      case 901:
        return PlayStateType.nelpNetDecodeBad;
      case 801:
        return PlayStateType.nelpNetStateBad;
      case 1001:
        return PlayStateType.nelpVideoDecoderOpen;
      default:
        return PlayStateType.nelpUnknownState;
    }
  } else if (Platform.isIOS) {
    switch (state) {
      case 0:
        return PlayStateType.nelpVideoPlayable;
      case 1:
        return PlayStateType.nelpBufferingEnd;
      case 2:
        return PlayStateType.nelpBufferingStart;
      default:
        return PlayStateType.nelpUnknownState;
    }
  }
  return PlayStateType.nelpUnknownState;
}
