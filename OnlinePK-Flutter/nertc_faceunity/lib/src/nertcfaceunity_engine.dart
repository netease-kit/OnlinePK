// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of nertc_faceunity;

class NEFaceUnityParams {
  /// 滤镜
  double filterLevel;

  /// 滤镜
  String filterName;

  /// 美白
  double colorLevel;

  /// 红润
  double redLevel;

  /// 磨皮程度
  double blurLevel;

  /// 亮眼
  double eyeBright;

  /// 大眼
  double eyeEnlarging;

  /// 瘦脸
  double cheekThinning;

  NEFaceUnityParams({
    this.filterLevel = 0,
    this.filterName = origin,
    this.colorLevel = 0,
    this.redLevel = 0,
    this.blurLevel = 0,
    this.eyeBright = 0,
    this.eyeEnlarging = 0,
    this.cheekThinning = 0,
  });
}

const filterNames = [
  origin,
  bailiang1,
  bailiang2,
  bailiang3,
  bailiang4,
  bailiang5,
  bailiang6,
  bailiang7,
  fennen1,
  fennen2,
  fennen3,
  fennen4,
  fennen5,
  fennen6,
  fennen7,
  fennen8,
  gexing1,
  gexing2,
  gexing3,
  gexing4,
  gexing5,
  gexing6,
  gexing7,
  gexing8,
  gexing9,
  gexing10,
  heibai1,
  heibai2,
  heibai3,
  heibai5,
  lengsediao1,
  lengsediao2,
  lengsediao3,
  lengsediao4,
  lengsediao5,
  lengsediao6,
  lengsediao7,
  lengsediao8,
  lengsediao9,
  lengsediao10,
  lengsediao11,
  nuansediao1,
  nuansediao2,
  nuansediao3,
  gexing11,
];

/// 滤镜使用的 key
const origin = 'origin';
const fennen1 = 'fennen1';
const fennen2 = 'fennen2';
const fennen3 = 'fennen3';
const fennen4 = 'fennen4';
const fennen5 = 'fennen5';
const fennen6 = 'fennen6';
const fennen7 = 'fennen7';
const fennen8 = 'fennen8';
const xiaoqingxin1 = 'xiaoqingxin1';
const xiaoqingxin2 = 'xiaoqingxin2';
const xiaoqingxin3 = 'xiaoqingxin3';
const xiaoqingxin4 = 'xiaoqingxin4';
const xiaoqingxin5 = 'xiaoqingxin5';
const xiaoqingxin6 = 'xiaoqingxin6';
const bailiang1 = 'bailiang1';
const bailiang2 = 'bailiang2';
const bailiang3 = 'bailiang3';
const bailiang4 = 'bailiang4';
const bailiang5 = 'bailiang5';
const bailiang6 = 'bailiang6';
const bailiang7 = 'bailiang7';
const lengsediao1 = 'lengsediao1';
const lengsediao2 = 'lengsediao2';
const lengsediao3 = 'lengsediao3';
const lengsediao4 = 'lengsediao4';
const lengsediao5 = 'lengsediao5';
const lengsediao6 = 'lengsediao6';
const lengsediao7 = 'lengsediao7';
const lengsediao8 = 'lengsediao8';
const lengsediao9 = 'lengsediao9';
const lengsediao10 = 'lengsediao10';
const lengsediao11 = 'lengsediao11';
const nuansediao1 = 'nuansediao1';
const nuansediao2 = 'nuansediao2';
const nuansediao3 = 'nuansediao3';
const heibai1 = 'heibai1';
const heibai2 = 'heibai2';
const heibai3 = 'heibai3';
const heibai4 = 'heibai4';
const heibai5 = 'heibai5';
const gexing1 = 'gexing1';
const gexing2 = 'gexing2';
const gexing3 = 'gexing3';
const gexing4 = 'gexing4';
const gexing5 = 'gexing5';
const gexing6 = 'gexing6';
const gexing7 = 'gexing7';
const gexing8 = 'gexing8';
const gexing9 = 'gexing9';
const gexing10 = 'gexing10';
const gexing11 = 'gexing11';
const ziran1 = 'ziran1';
const ziran2 = 'ziran2';
const ziran3 = 'ziran3';
const ziran4 = 'ziran4';
const ziran5 = 'ziran5';
const ziran6 = 'ziran6';
const ziran7 = 'ziran7';
const ziran8 = 'ziran8';
const zhiganhui1 = 'zhiganhui1';
const zhiganhui2 = 'zhiganhui2';
const zhiganhui3 = 'zhiganhui3';
const zhiganhui4 = 'zhiganhui4';
const zhiganhui5 = 'zhiganhui5';
const zhiganhui6 = 'zhiganhui6';
const zhiganhui7 = 'zhiganhui7';
const zhiganhui8 = 'zhiganhui8';
const mitao1 = 'mitao1';
const mitao2 = 'mitao2';
const mitao3 = 'mitao3';
const mitao4 = 'mitao4';
const mitao5 = 'mitao5';
const mitao6 = 'mitao6';
const mitao7 = 'mitao7';
const mitao8 = 'mitao8';

class NERtcFaceUnityEngine {
  factory NERtcFaceUnityEngine() => _instance;

  NERtcFaceUnityEngine._();

  static final NERtcFaceUnityEngine _instance = NERtcFaceUnityEngine._();

  NEFTFaceUnityEngineApi _api = NEFTFaceUnityEngineApi();

  /// Configure
  Future<void> create({
    required Uint8List beautyKey,
  }) {
    return _api.create(NECreateFaceUnityRequest()..beautyKey = beautyKey);
  }

  /// Release beauty engine
  Future<int> release() async {
    NEFUInt reply = await _api.release();
    return reply.value ?? -1;
  }

  /// 滤镜，范围 [0-1]，默认 0
  Future<int> setFilterLevel(double filterLevel) async {
    NEFUInt reply =
        await _api.setFilterLevel(NEFUDouble()..value = filterLevel);
    return reply.value ?? -1;
  }

  /// 滤镜，范围 [filterNames]，默认 origin
  Future<int> setFilterName(String filterName) async {
    NEFUInt reply = await _api.setFilterName(NEFUString()..value = filterName);
    return reply.value ?? -1;
  }

  /// 美白程度，范围 [0-2]，默认 0.2
  Future<int> setColorLevel(double colorLevel) async {
    NEFUInt reply = await _api.setColorLevel(NEFUDouble()..value = colorLevel);
    return reply.value ?? -1;
  }

  Future<int> setRedLevel(double redLevel) async {
    NEFUInt reply = await _api.setRedLevel(NEFUDouble()..value = redLevel);
    return reply.value ?? -1;
  }

  /// 磨皮程度，范围 [0-6]，默认 6
  Future<int> setBlurLevel(double blurLevel) async {
    NEFUInt reply = await _api.setBlurLevel(NEFUDouble()..value = blurLevel);
    return reply.value ?? -1;
  }

  /// 大眼程度，范围 [0-1]，默认 0.5
  Future<int> setEyeEnlarging(double eyeEnlarging) async {
    NEFUInt reply =
        await _api.setEyeEnlarging(NEFUDouble()..value = eyeEnlarging);
    return reply.value ?? -1;
  }

  ///  瘦脸程度，范围 [0-1]，默认 0
  Future<int> setCheekThinning(double cheekThinning) async {
    NEFUInt reply =
        await _api.setCheekThinning(NEFUDouble()..value = cheekThinning);
    return reply.value ?? -1;
  }

  Future<int> setEyeBright(double eyeBright) async {
    NEFUInt reply = await _api.setEyeBright(NEFUDouble()..value = eyeBright);
    return reply.value ?? -1;
  }

  ///设置美颜参数
  ///
  /// [beautyParams] 指定美颜参数
  /// [int] -1 为接口调用初始化失败
  Future<int> setMultiFUParams(NEFaceUnityParams beautyParams) async {
    // NEFUInt reply = await _api.setMultiFUParams(SetFaceUnityParamsRequest()
    //   ..filterLevel = beautyParams.filterLevel
    //   ..colorLevel = beautyParams.colorLevel
    //   ..redLevel = beautyParams.redLevel
    //
    //   ///blurLevel 磨皮程度，取值范围0.0-6.0，默认6.0
    //   ..blurLevel = beautyParams.blurLevel
    //   ..eyeBright = beautyParams.eyeBright);

    await _api.setFilterName(NEFUString()..value = beautyParams.filterName);
    await _api.setFilterLevel(NEFUDouble()..value = beautyParams.filterLevel);
    await _api.setColorLevel(NEFUDouble()..value = beautyParams.colorLevel);
    await _api.setRedLevel(NEFUDouble()..value = beautyParams.redLevel);
    await _api.setBlurLevel(NEFUDouble()..value = beautyParams.blurLevel);
    await _api.setEyeBright(NEFUDouble()..value = beautyParams.eyeBright);

    await _api
        .setCheekThinning(NEFUDouble()..value = beautyParams.cheekThinning);
    NEFUInt reply = await _api
        .setEyeEnlarging(NEFUDouble()..value = beautyParams.eyeEnlarging);
    return reply.value ?? -1;
  }
}
