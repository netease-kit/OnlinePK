// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

class _NELiveMediaControllerImpl extends NELiveMediaController
    with _AloggerMixin {
  _NELivePushService get pushService => NELiveKit.instance._pushService;

  @override
  Future<VoidResult> disableLocalAudio() {
    commonLogger.i('disableLocalAudio');
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.muteMyAudio();
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> disableLocalVideo() {
    commonLogger.i('disableLocalVideo');
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.muteMyVideo();
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> disablePeerAudio() {
    commonLogger.i('disablePeerAudio');
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    var peerUuid = NELiveKit.instance._anchorLiveInfo.peer?.userUuid;
    if (context != null && TextUtils.isNotEmpty(peerUuid)) {
      context.rtcController.adjustUserPlaybackSignalVolume(peerUuid!, 0);
      return pushService.mutePeerAudio(context);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> enablePeerAudio() {
    commonLogger.i('enablePeerAudio');
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    var peerUuid = NELiveKit.instance._anchorLiveInfo.peer?.userUuid;
    if (context != null && TextUtils.isNotEmpty(peerUuid)) {
      context.rtcController.adjustUserPlaybackSignalVolume(peerUuid!, 100);
      return pushService.unmutePeerAudio(context);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> enableEarBack(int volume) {
    commonLogger.i('enableEarBack');
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      if (NELiveKit.instance.audioOutputDevice ==
              NEAudioOutputDevice.kBluetoothHeadset ||
          NELiveKit.instance.audioOutputDevice ==
              NEAudioOutputDevice.kWiredHeadset) {
        return context.rtcController.enableEarBack(volume);
      } else {
        return Future.value(const NEResult(
            code: -1,
            msg: 'only bluetooth headset or wired headset can use ear back'));
      }
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> disableEarBack() {
    commonLogger.i('enableLocalAudio');
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.disableEarBack();
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> enableLocalAudio() {
    commonLogger.i('enableLocalAudio');
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.unmuteMyAudio();
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> enableLocalVideo() {
    commonLogger.i('enableLocalAudio');
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.unmuteMyVideo();
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<NEResult<NEPreviewRoomContext>> previewRoom() {
    return NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions());
  }

  @override
  Future<VoidResult> playEffect(
      int effectId, NECreateAudioEffectOption option) {
    commonLogger.i('playEffect');
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.playEffect(effectId, option);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> stopAllEffects() {
    commonLogger.i('stopAllEffects');
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.stopAllEffects();
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> startAudioMixing(NECreateAudioMixingOption option) {
    commonLogger.i('startAudioMixing');
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.startAudioMixing(option);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> stopAudioMixing() {
    commonLogger.i('stopAudioMixing');
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.stopAudioMixing();
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> switchCamera() async {
    commonLogger.i('switchCamera');
    var context = await NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions());
    if (context.data != null) {
      return context.data!.previewController.switchCamera();
    }
    return const NEResult(code: -1, msg: 'context not exist');
  }

  @override
  Future<VoidResult> setAudioMixingPlaybackVolume(int volume) {
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.setAudioMixingPlaybackVolume(volume);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> setAudioMixingSendVolume(int volume) {
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.setAudioMixingSendVolume(volume);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> setEffectPlaybackVolume(int effectId, int volume) {
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.setEffectPlaybackVolume(effectId, volume);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> setEffectSendVolume(int effectId, int volume) {
    var context = NELiveKit.instance._anchorLiveInfo.liveRoom;
    if (context != null) {
      return context.rtcController.setEffectSendVolume(effectId, volume);
    } else {
      return Future.value(const NEResult(code: -1, msg: 'not in room'));
    }
  }

  @override
  Future<VoidResult> addBeautyFilter(String path) async {
    commonLogger.i('addBeautyFilter path:$path');
    var ret = await NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions());
    return ret.nonNullData.previewController.addBeautyFilter(path);
  }

  @override
  Future<VoidResult> addBeautySticker(String path) async {
    commonLogger.i('addBeautySticker path:$path');
    var ret = await NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions());
    return ret.nonNullData.previewController.addBeautySticker(path);
  }

  @override
  Future<VoidResult> enableBeauty(bool isOpenBeauty) async {
    commonLogger.i('enableBeauty isOpenBeauty:$isOpenBeauty');
    var ret = await NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions());
    return ret.nonNullData.previewController.enableBeauty(isOpenBeauty);
  }

  @override
  Future<VoidResult> removeBeautyFilter() async {
    commonLogger.i('removeBeautyFilter');
    var ret = await NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions());
    return ret.nonNullData.previewController.removeBeautyFilter();
  }

  @override
  Future<VoidResult> removeBeautySticker() async {
    commonLogger.i('removeBeautySticker');
    var ret = await NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions());
    return ret.nonNullData.previewController.removeBeautySticker();
  }

  @override
  Future<VoidResult> setBeautyEffect(
      NERoomBeautyEffectType beautyType, double level) async {
    var ret = await NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions());
    return ret.nonNullData.previewController.setBeautyEffect(beautyType, level);
  }

  @override
  Future<VoidResult> setBeautyFilterLevel(double level) async {
    var ret = await NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions());
    return ret.nonNullData.previewController.setBeautyFilterLevel(level);
  }

  @override
  Future<VoidResult> startBeauty() async {
    commonLogger.i('startBeauty');
    var ret = await NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions());
    return ret.nonNullData.previewController.startBeauty();
  }

  @override
  Future<VoidResult> stopBeauty() async {
    commonLogger.i('stopBeauty');
    var ret = await NERoomKit.instance.roomService
        .previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions());
    return ret.nonNullData.previewController.stopBeauty();
  }
}
