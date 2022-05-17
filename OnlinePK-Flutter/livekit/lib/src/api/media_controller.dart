// Copyright (c) 2022 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

part of netease_livekit;

abstract class NELiveMediaController {

  Future<NEResult<NEPreviewRoomContext>> previewRoom();

  /// switch camera
  Future<VoidResult> switchCamera();

  Future<VoidResult> enableLocalAudio();

  Future<VoidResult> disableLocalAudio();

  Future<VoidResult> enableLocalVideo();

  Future<VoidResult> disableLocalVideo();

  Future<VoidResult> enablePeerAudio();

  Future<VoidResult> disablePeerAudio();

  Future<VoidResult> playEffect(int effectId, NECreateAudioEffectOption option);

  Future<VoidResult> enableEarBack(int volume);

  Future<VoidResult> disableEarBack();

  Future<VoidResult> setEffectSendVolume(int effectId, int volume);

  Future<VoidResult> setEffectPlaybackVolume(int effectId, int volume);

  Future<VoidResult> setAudioMixingSendVolume(int volume);


  Future<VoidResult> setAudioMixingPlaybackVolume(int volume);

  Future<VoidResult> stopAllEffects();

  Future<VoidResult> startAudioMixing(NECreateAudioMixingOption option);

  Future<VoidResult> stopAudioMixing();

  Future<VoidResult> startBeauty();

  Future<VoidResult> stopBeauty();

  Future<VoidResult> enableBeauty(bool isOpenBeauty);

  Future<VoidResult> setBeautyEffect(
      NERoomBeautyEffectType beautyType, double level);

  Future<VoidResult> addBeautyFilter(String path);

  Future<VoidResult> removeBeautyFilter();

  Future<VoidResult> setBeautyFilterLevel(double level);

  Future<VoidResult> addBeautySticker(String path);

  Future<VoidResult> removeBeautySticker();
}