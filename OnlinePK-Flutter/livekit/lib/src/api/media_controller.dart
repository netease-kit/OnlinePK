// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_livekit;

abstract class NELiveMediaController {
  Future<NEResult<NEPreviewRoomContext>> previewRoom();

  /// switch camera
  Future<VoidResult> switchCamera();

  Future<VoidResult> enableLocalAudio();

  Future<VoidResult> disableLocalAudio();

  Future<VoidResult> enableLocalVideo();

  Future<VoidResult> disableLocalVideo();

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

  ///
  ///    开始通话前网络质量探测。 启用该方法后，SDK 会通过回调方式反馈上下行网络的质量状态与质量探测报告，包括带宽、丢包率、网络抖动和往返时延等数据。一般用于通话前的网络质量探测场景，用户加入房间之前可以通过该方法预估音视频通话中本地用户的主观体验和客观网络状态。 相关回调如下：
  ///    NERoomRtcNetworkStatusType：网络质量状态回调，以打分形式描述上下行网络质量的主观体验。该回调视网络情况在约 5 秒内返回。
  ///    NERoomRtcLastmileProbeTest：网络质量探测报告回调，报告中通过客观数据反馈上下行网络质量。该回调视网络情况在约 30 秒内返回。
  ///    注解
  ///    请在加入房间（joinChannel）前调用此方法。
  ///
  Future<VoidResult> startLastmileProbeTest(
      NERoomRtcLastmileProbeConfig config);

  ///
  /// 停止通话前网络质量探测。
  ///
  Future<VoidResult> stopLastmileProbeTest();
}
