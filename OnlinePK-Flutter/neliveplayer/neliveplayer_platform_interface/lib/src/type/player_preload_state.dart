// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

enum PlayerPreloadState {
  ///已经完成预调度
  ///Preloading is complete
  complete,

  ///正在预调度
  ///Preloading is running
  running,

  /// 等待预调度
  /// Waiting for preloading
  wait
}

PlayerPreloadState? getPreloadState(int? state) {
  switch (state) {
    case 2:
      return PlayerPreloadState.complete;
    case 1:
      return PlayerPreloadState.running;
    case 0:
      return PlayerPreloadState.wait;
  }
  return null;
}
