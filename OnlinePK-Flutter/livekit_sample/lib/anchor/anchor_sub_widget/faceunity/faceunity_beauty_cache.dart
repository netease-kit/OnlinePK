// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:nertc_faceunity/nertc_faceunity.dart';

import '../../../utils/live_log.dart';
import 'faceunity_config.dart';

class FaceUnityBeautyCache {
  FaceUnityBeautyCache._internal();

  static final FaceUnityBeautyCache _singleton =
      FaceUnityBeautyCache._internal();

  factory FaceUnityBeautyCache() => _singleton;
  late NERtcFaceUnityEngine _beautyEngine;
  late NEFaceUnityParams _faceUnityParams;

  /// 滤镜列表选中的index
  var _currentFilterNameKeyIndex = 0;
  var _currentFilterLevel = 0.00;
  var _whiteningValue = 0.00;
  var _peelingValue = 0.00;
  var _thinFaceValue = 0.00;
  var _bigEyeValue = 0.00;
  final String tag = "FaceUnityBeautyCache";
  var hasInit = false;

  init() {
    LiveLog.i(tag, "init");
    if (!hasInit) {
      _beautyEngine = NERtcFaceUnityEngine();
      _faceUnityParams = NEFaceUnityParams();
      _beautyEngine.create(beautyKey: Uint8List.fromList(FaceUnityConfig.auth));
      hasInit = true;
      LiveLog.i(tag, "init success");
    } else {
      LiveLog.i(tag, "already init");
    }
  }

  set currentFilterValue(int value) {
    LiveLog.i(tag,
        "set currentFilterValue hasInit:$hasInit,value:$value,filterName:${filterNames[value]}");
    if (!hasInit) {
      return;
    }
    _currentFilterNameKeyIndex = value;
    _faceUnityParams.filterName = filterNames[value];
    _beautyEngine.setMultiFUParams(_faceUnityParams);
  }

  int get currentFilterValue => _currentFilterNameKeyIndex;

  set currentFilterLevel(double value) {
    LiveLog.i(tag, "set currentFilterLevel hasInit:$hasInit,value:$value");
    if (!hasInit) {
      return;
    }
    _currentFilterLevel = value;
    _faceUnityParams.filterLevel = value;
    _beautyEngine.setMultiFUParams(_faceUnityParams);
  }

  double get currentFilterLevel => _currentFilterLevel;

  set whiteningValue(double value) {
    LiveLog.i(tag, "set whiteningValue hasInit:$hasInit,value:$value");
    if (!hasInit) {
      return;
    }
    _whiteningValue = value;
    _faceUnityParams.colorLevel = value;
    _beautyEngine.setMultiFUParams(_faceUnityParams);
  }

  double get whiteningValue => _whiteningValue;

  set peelingValue(double value) {
    LiveLog.i(tag, "set peelingValue hasInit:$hasInit,value:$value");
    if (!hasInit) {
      return;
    }
    _peelingValue = value;
    _faceUnityParams.blurLevel = value;
    _beautyEngine.setMultiFUParams(_faceUnityParams);
  }

  double get peelingValue => _peelingValue;

  set thinFaceValue(double value) {
    LiveLog.i(tag, "set thinFaceValue hasInit:$hasInit,value:$value");
    if (!hasInit) {
      return;
    }
    _thinFaceValue = value;
    _faceUnityParams.cheekThinning = value;
    _beautyEngine.setMultiFUParams(_faceUnityParams);
  }

  double get thinFaceValue => _thinFaceValue;

  set bigEyeValue(double value) {
    LiveLog.i(tag, "set bigEyeValue hasInit:$hasInit,value:$value");
    if (!hasInit) {
      return;
    }
    _bigEyeValue = value;
    _faceUnityParams.eyeEnlarging = value;
    _beautyEngine.setMultiFUParams(_faceUnityParams);
  }

  double get bigEyeValue => _bigEyeValue;

  resetBeauty() {
    LiveLog.i(tag, "resetBeauty,hasInit:$hasInit");
    if (!hasInit) {
      return;
    }
    _whiteningValue = 0.00;
    _peelingValue = 0.00;
    _thinFaceValue = 0.00;
    _bigEyeValue = 0.00;
    _faceUnityParams.colorLevel = _whiteningValue;
    _faceUnityParams.cheekThinning = _thinFaceValue;
    _faceUnityParams.blurLevel = _peelingValue;
    _faceUnityParams.eyeBright = _bigEyeValue;
    _beautyEngine.setMultiFUParams(_faceUnityParams);
  }

  resetFilter() {
    LiveLog.i(tag, "resetFilter,hasInit:$hasInit");
    if (!hasInit) {
      return;
    }
    _currentFilterNameKeyIndex = 0;
    _currentFilterLevel = 0.00;
    _faceUnityParams.filterLevel = _currentFilterLevel;
    _faceUnityParams.filterName = origin;
    _beautyEngine.setMultiFUParams(_faceUnityParams);
  }

  void destroy() {
    LiveLog.i(tag, "destroy,hasInit:$hasInit");
    if (hasInit) {
      _beautyEngine.release();
    }
    hasInit = false;
  }
}
