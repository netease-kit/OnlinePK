//
//  NEAudioOption.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/16.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEAudioOption : NSObject

/// 开启/关闭本地语音
/// @param enabled 开/关
- (void)enableLocalAudio:(BOOL)enabled;

/// 设置是否静音音频采集设备
/// @param muted 是/否
- (void)muteLocalAudio:(BOOL)muted;

/// 设置采集音量
/// @param volume 音量
- (void)setAudioCaptureVolume:(uint32_t)volume;

/// 打开/关闭耳返
/// @param enabled 开/关
- (void)enableEarBack:(BOOL)enabled;

/// 开始混音
/// @param opt 混音选项
- (void)startAudioMixing:(NERtcCreateAudioMixingOption *)opt;

/// 结束混音
- (void)stopAudioMixing;

/// 开始伴音
/// @param effectId 音效id
/// @param option 音效可选项
- (void)playEffect:(uint32_t)effectId effectOption:(NERtcCreateAudioEffectOption *)option;

/// 结束伴音
/// @param effectId 音效id
- (void)stopEffect:(uint32_t)effectId;

/// 设置混音发送音量
/// @param volume 音量
- (void)setAudioMixingSendVolume:(uint32_t)volume;

/// 设置混音耳返音量
/// @param volume 音量
- (void)setAudioMixingPlaybackVolume:(uint32_t)volume;

/// 设置伴音发送音量
/// @param effectId 音效id
/// @param volume 音量
- (void)setEffectSendVolume:(uint32_t)effectId volume:(uint32_t)volume;

/// 设置伴音耳返音量
/// @param effectId 音效id
/// @param volume 音量
- (void)setEffectPlaybackVolume:(uint32_t)effectId volume:(uint32_t)volume;

/// 停止所有伴音
- (void)stopAllEffects;


@end

NS_ASSUME_NONNULL_END
