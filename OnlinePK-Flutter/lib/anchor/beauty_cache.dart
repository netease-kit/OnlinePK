// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:netease_livekit/netease_livekit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:netease_roomkit/netease_roomkit.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

class FilterModel {
  String name;
  String icon;
  String path;

  bool _isSelected = false;

  bool get isSelected {
    return _isSelected;
  }

  set isSelected(bool value) {
    if (value != _isSelected) {
      _isSelected = value;
      if (value) {
        NELiveKit.instance.mediaController.addBeautyFilter(path);
      } else {
        NELiveKit.instance.mediaController.removeBeautyFilter();
      }
    }
  }

  FilterModel({
    required this.name,
    required this.icon,
    required this.path,
  });
}

class BeautyCache {
  BeautyCache._internal();

  static final BeautyCache _singleton = BeautyCache._internal();

  factory BeautyCache() => _singleton;

  init() async {
    Directory? cache;
    if (Platform.isAndroid) {
      cache = await getExternalStorageDirectory();
    } else {
      cache = await getApplicationDocumentsDirectory();
    }
    // Read the Zip file from disk.
    final value = await rootBundle.load('assets/beauty_resources/beauty.zip');
    // Decode the Zip file
    Uint8List bytes =
        value.buffer.asUint8List(value.offsetInBytes, value.lengthInBytes);
    final archive = ZipDecoder().decodeBytes(bytes);

    // Extract the contents of the Zip archive to disk.
    for (final file in archive) {
      final filename = file.name;
      if (!filename.contains('.DS_Store')) {
        if (file.isFile) {
          final data = file.content as List<int>;
          File('${cache!.path}/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('${cache!.path}/' + filename).create(recursive: true);
        }
      }
    }
    defaultFilters().then((value) => _filters = value);
  }

  final _defaultWhiteningValue = 40;
  final _defaultPeelingValue = 50;
  final _defaultThinFaceValue = 10;
  final _defaultBigEyeValue = 20;

  var _whiteningValue = 40;
  var _peelingValue = 50;
  var _thinFaceValue = 10;
  var _bigEyeValue = 20;

  set whiteningValue(int value) {
    _whiteningValue = value;
    NELiveKit.instance.mediaController
        .setBeautyEffect(NERoomBeautyEffectType.kWhiten, value / 100);
  }

  int get whiteningValue => _whiteningValue;

  set peelingValue(int value) {
    _peelingValue = value;
    NELiveKit.instance.mediaController
        .setBeautyEffect(NERoomBeautyEffectType.kSmooth, value / 100);
  }

  int get peelingValue => _peelingValue;

  set thinFaceValue(int value) {
    _thinFaceValue = value;
    NELiveKit.instance.mediaController
        .setBeautyEffect(NERoomBeautyEffectType.kThinFace, value / 100);
  }

  int get thinFaceValue => _thinFaceValue;

  set bigEyeValue(int value) {
    _bigEyeValue = value;
    NELiveKit.instance.mediaController
        .setBeautyEffect(NERoomBeautyEffectType.kBigEye, value / 100);
  }

  int get bigEyeValue => _bigEyeValue;

  resetBeauty() {
    whiteningValue = _defaultWhiteningValue;
    peelingValue = _defaultPeelingValue;
    thinFaceValue = _defaultThinFaceValue;
    bigEyeValue = _defaultBigEyeValue;
  }

  late List<FilterModel> _filters;

  List<FilterModel> get filters => _filters;

  var _filterValue = 50;
  final _defaultFilterValue = 50;

  int get filterValue => _filterValue;

  set filterValue(int value) {
    _filterValue = value;
    NELiveKit.instance.mediaController.setBeautyFilterLevel(value / 100);
  }

  Future<List<FilterModel>> defaultFilters() async {
    Directory? cache;
    if (Platform.isAndroid) {
      cache = await getExternalStorageDirectory();
    } else {
      cache = await getApplicationDocumentsDirectory();
    }
    var path = '${cache!.path}/filters';
    List<FilterModel> filters = List.empty(growable: true);
    // 白皙
    for (int i = 1; i < 7; i++) {
      FilterModel model = FilterModel(
          name: 'white $i',
          icon: 'assets/images/filter_style_白皙$i.png',
          path: '$path/filter_style_白皙$i/');
      filters.add(model);
    }
    // 个性
    for (int i = 1; i < 7; i++) {
      FilterModel model = FilterModel(
          name: 'personality $i',
          icon: 'assets/images/filter_style_个性$i.png',
          path: '$path/filter_style_个性$i/');
      filters.add(model);
    }
    // 清新
    for (int i = 1; i < 7; i++) {
      FilterModel model = FilterModel(
          name: 'fresh $i',
          icon: 'assets/images/filter_style_清新$i.png',
          path: '$path/filter_style_清新$i/');
      filters.add(model);
    }
    // 质感
    for (int i = 1; i < 7; i++) {
      FilterModel model = FilterModel(
          name: 'sense $i',
          icon: 'assets/images/filter_style_质感$i.png',
          path: '$path/filter_style_质感$i/');
      filters.add(model);
    }
    // 质感
    for (int i = 1; i < 7; i++) {
      FilterModel model = FilterModel(
          name: 'natural $i',
          icon: 'assets/images/filter_style_自然$i.png',
          path: '$path/filter_style_自然$i/');
      filters.add(model);
    }
    return filters;
  }

  resetFilter() {
    filterValue = _defaultFilterValue;
    removeBeautyFilter();
  }

  removeBeautyFilter() {
    NELiveKit.instance.mediaController.removeBeautyFilter();
    for (var model in _filters) {
      if (model.isSelected) {
        model.isSelected = false;
      }
    }
  }
}
