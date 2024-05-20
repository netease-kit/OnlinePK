// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

// class MockNeliveplayerPlatform
//     with MockPlatformInterfaceMixin
//     implements NeliveplayerPlatform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
//
//   @override
//   Future<void> init() {
//     // TODO: implement init
//     throw UnimplementedError();
//   }
// }
//
// void main() {
//   final NeliveplayerPlatform initialPlatform = NeliveplayerPlatform.instance;
//
//   test('$MethodChannelNeliveplayer is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelNeliveplayer>());
//   });
//
//   test('getPlatformVersion', () async {
//     NeLivePlayer neliveplayerPlugin = NeLivePlayer();
//     MockNeliveplayerPlatform fakePlatform = MockNeliveplayerPlatform();
//     NeliveplayerPlatform.instance = fakePlatform;
//
//     expect(await neliveplayerPlugin.getPlatformVersion(), '42');
//   });
// }
