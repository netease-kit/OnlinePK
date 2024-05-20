// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
// import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // const MethodChannel channel = MethodChannel('beauty');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // channel.setMockMethodCallHandler((MethodCall methodCall) async {
    //   return '42';
    // });
  });

  tearDown(() {
    // channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // expect(await BeautySdkFlutter.platformVersion, '42');
  });
}
