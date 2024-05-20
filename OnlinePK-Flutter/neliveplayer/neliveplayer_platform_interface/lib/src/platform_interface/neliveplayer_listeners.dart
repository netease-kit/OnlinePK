// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:neliveplayer_platform_interface/neliveplayer_platform_interface.dart';

class NeLivePlayerListener extends NeLivePlayerListenerApi {
  void Function(String playerId)? onPreparedListener;

  void Function(String playerId)? onCompletionListener;

  void Function(String playerId, PlayerErrorType what, int extra)?
      onErrorListener;

  void Function(String playerId, int width, int height)?
      onVideoSizeChangedListener;

  void Function(String playerId)? onReleasedListener;

  void Function(String playerId, PlayStateType type, int extra)?
      onLoadStateChangeListener;

  void Function(String playerId)? onFirstVideoDisplayListener;

  void Function(String playerId)? onFirstAudioDisplayListener;

  @override
  void onPrepared(String playerId) {
    if (onPreparedListener != null) {
      onPreparedListener!(playerId);
    }
  }

  @override
  void onCompletion(String playerId) {
    if (onCompletionListener != null) {
      onCompletionListener!(playerId);
    }
  }

  @override
  void onError(String playerId, int what, int extra) {
    if (onErrorListener != null) {
      onErrorListener!(playerId, getErrorType(what), extra);
    }
  }

  @override
  void onReleased(String playerId) {
    if (onReleasedListener != null) {
      onReleasedListener!(playerId);
    }
  }

  @override
  void onVideoSizeChanged(String playerId, int width, int height) {
    if (onVideoSizeChangedListener != null) {
      onVideoSizeChangedListener!(playerId, width, height);
    }
  }

  @override
  void onFirstAudioDisplay(String playerId) {
    if (onFirstAudioDisplayListener != null) {
      onFirstAudioDisplayListener!(playerId);
    }
  }

  @override
  void onFirstVideoDisplay(String playerId) {
    if (onFirstVideoDisplayListener != null) {
      onFirstVideoDisplayListener!(playerId);
    }
  }

  @override
  void onLoadStateChange(String playerId, int state, int extra) {
    if (onLoadStateChangeListener != null) {
      onLoadStateChangeListener!(playerId, covertPlayStateType(state), extra);
    }
  }
}
