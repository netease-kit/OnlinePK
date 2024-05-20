# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

flutter pub run pigeon \
  --input pigeon/message.dart \
  --dart_out lib/src/pigeon.dart \
  --objc_header_out ../neliveplayer/ios/Classes/pigeon/Pigeon.h \
  --objc_source_out ../neliveplayer/ios/Classes/pigeon/Pigeon.m \
  --objc_prefix FLT \
  --java_out ../neliveplayer/android/src/main/kotlin/com/netease/yunxin/flutter/plugins/neliveplayer/pigeon/Pigeon.java \
  --java_package "com.netease.yunxin.flutter.plugins.neliveplayer.pigeon"