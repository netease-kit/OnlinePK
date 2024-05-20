// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

enum PlayerErrorType {
  /// 音频解码失败
  /// Audio decoding error
  nelpEnAudioDecodeError,

  /// 音频相关操作初始化失败
  /// Audio initialization error
  nelpEnAudioOpenError,

  /// 音频播放失败
  /// Audio playback error
  nelpEnAudioRenderError,

  /// 缓冲失败
  /// Buffering error
  nelpEnBufferingError,

  /// Datasource连接失败
  /// Data source connection error
  nelpEnDatasourceConnectError,

  /// 解密失败
  /// Decryption error
  nelpEnDecryptionError,

  /// HTTP连接失败
  /// HTTP connection error
  nelpEnHttpConnectError,

  /// 预处理超时错误 该错误在NESDKConfig#isCloseTimeOutProtect配置,
  /// 该错误是在播放器引擎在超过用户设置的超时时间仍然没有报错时进行的二次超时保护，
  /// 避免极端情况下缓冲很久没有错误上报的情况 如果false开启对预处理和缓冲进行超时保护，
  /// 在超时的时候会回调nelpEnPrepareTimeoutError错误 如果为true关掉该功能，
  /// 那么在超时的时候不会回调nelpEnPrepareTimeoutError错误，应用层需要自己处理预处理和缓冲的超时逻辑。
  /// Preprocessing timeout error. This error is configured in NESDKConfig#isCloseTimeOutProtect,
  /// This error is a secondary timeout protection performed by the player engine when no error is reported after the specified timeout period.
  /// This error avoids the extreme case of buffering for a long time without error reporting. If false, timeout protection for preprocessing and buffering is enabled,
  /// The nelpEnPrepareTimeoutError error will be returned upon timeout. If true, the functionality is disabled.
  /// Then the nelpEnPrepareTimeoutError will not be returned when timeout occurs, and the application layer must handle the timeout logic of preprocessing and buffering.
  nelpEnPrepareTimeoutError,

  /// RTMP连接失败
  /// RTMP connection error
  nelpEnRtmpConnectError,

  /// 没有音视频流
  /// No audio and video stream found
  nelpEnStreamIsNull,

  ///  解析失败
  ///  Stream parsing error
  nelpEnStreamParseError,

  ///  未知错误
  ///  Unknown error
  nelpEnUnknownError,

  ///  视频解码失败
  ///  Video decoding error
  nelpEnVideoDecodeError,

  /// 视频相关操作初始化失败
  /// Video initialization error
  nelpEnVideoOpenError,

  ///  视频播放失败
  ///  Video playback error
  nelpEnVideoRenderError,

  ///  初始化的URL格式错误 iOS
  ///  Invalid URL format (iOS)
  nelpEnFormatError,

  /// 初始化的URL是推流地址
  /// Push URL error
  nelpEnIsPushError,

  ///初始化的URL解析错误
  ///Parsing URL error
  nelpEnParseError,

  ///解密视频，解密参数错误
  ///Invalid parameters for decrypting videos
  nelpEnVideoParmasError,

  ///解密视频，密钥错误
  ///Key error while decrypting videos
  nelpEnVideoKeyCheckError,

  ///解密视频，获取密钥服务端请求过程中错误
  ///An error occurs when getting decryption keys from server
  nelpEnVideoGetKeyRemoteError,

  ///解密视频，未知错误
  ///an unknown error during decryption
  nelpEnVideoUnknownError,

  ///播放过程中，LLS连接失败
  ///LLS connection error during playback
  nelpEnLLSConnectError,
}

PlayerErrorType getErrorType(int what) {
  if (Platform.isAndroid) {
    switch (what) {
      case -4001:
        return PlayerErrorType.nelpEnAudioDecodeError;
      case -2001:
        return PlayerErrorType.nelpEnAudioOpenError;
      case -5001:
        return PlayerErrorType.nelpEnAudioRenderError;
      case -1004:
        return PlayerErrorType.nelpEnBufferingError;
      case -6001:
        return PlayerErrorType.nelpEnDatasourceConnectError;
      case -7001:
        return PlayerErrorType.nelpEnDecryptionError;
      case -1001:
        return PlayerErrorType.nelpEnHttpConnectError;
      case -1005:
        return PlayerErrorType.nelpEnPrepareTimeoutError;
      case -1002:
        return PlayerErrorType.nelpEnRtmpConnectError;
      case -3001:
        return PlayerErrorType.nelpEnStreamIsNull;
      case -1003:
        return PlayerErrorType.nelpEnStreamParseError;
      case -4002:
        return PlayerErrorType.nelpEnVideoDecodeError;
      case -2002:
        return PlayerErrorType.nelpEnVideoOpenError;
      case -5002:
        return PlayerErrorType.nelpEnVideoRenderError;
      default:
        return PlayerErrorType.nelpEnUnknownError;
    }
  } else if (Platform.isIOS) {
    switch (what) {
      case 1000:
        return PlayerErrorType.nelpEnFormatError;
      case 1001:
        return PlayerErrorType.nelpEnIsPushError;
      case 1002:
        return PlayerErrorType.nelpEnParseError;
      case 2000:
        return PlayerErrorType.nelpEnVideoParmasError;
      case 2001:
        return PlayerErrorType.nelpEnVideoKeyCheckError;
      case 2003:
        return PlayerErrorType.nelpEnVideoGetKeyRemoteError;
      case 2004:
        return PlayerErrorType.nelpEnVideoUnknownError;
      case -1001:
        return PlayerErrorType.nelpEnHttpConnectError;
      case -1002:
        return PlayerErrorType.nelpEnRtmpConnectError;
      case -1003:
        return PlayerErrorType.nelpEnStreamParseError;
      case -1004:
        return PlayerErrorType.nelpEnBufferingError;
      case -1010:
        return PlayerErrorType.nelpEnLLSConnectError;
      case -2001:
        return PlayerErrorType.nelpEnAudioOpenError;
      case -2002:
        return PlayerErrorType.nelpEnVideoOpenError;
      case -3001:
        return PlayerErrorType.nelpEnStreamIsNull;
      case -4001:
        return PlayerErrorType.nelpEnAudioDecodeError;
      case -4002:
        return PlayerErrorType.nelpEnVideoDecodeError;
      case -5001:
        return PlayerErrorType.nelpEnAudioRenderError;
      case -5002:
        return PlayerErrorType.nelpEnVideoRenderError;
      case -10000:
        return PlayerErrorType.nelpEnUnknownError;
      default:
        return PlayerErrorType.nelpEnUnknownError;
    }
  }
  return PlayerErrorType.nelpEnUnknownError;
}
