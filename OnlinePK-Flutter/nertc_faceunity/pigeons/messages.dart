// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class NECreateFaceUnityRequest {
  Uint8List? beautyKey;
  String? logDir;
  int? logLevel;
}

class NEFUInt {
  int? value;
}

class NEFUDouble {
  double? value;
}

class NEFUString {
  String? value;
}

class SetFaceUnityParamsRequest {
  double? filterLevel;
  double? colorLevel;
  double? redLevel;
  double? blurLevel;
  double? eyeBright;
  double? eyeEnlarging;
  double? cheekThinning;
  String? filterName;
}

@HostApi()
abstract class NEFTFaceUnityEngineApi {
  NEFUInt create(NECreateFaceUnityRequest request);

  NEFUInt setFilterLevel(NEFUDouble filterLevel);

  NEFUInt setFilterName(NEFUString filterName);

  NEFUInt setColorLevel(NEFUDouble colorLevel);

  NEFUInt setRedLevel(NEFUDouble redLevel);

  NEFUInt setBlurLevel(NEFUDouble blurLevel);

  NEFUInt setEyeEnlarging(NEFUDouble eyeEnlarging);

  NEFUInt setCheekThinning(NEFUDouble cheekThinning);

  NEFUInt setEyeBright(NEFUDouble eyeBright);

  NEFUInt setMultiFUParams(SetFaceUnityParamsRequest request);

  NEFUInt release();
}
