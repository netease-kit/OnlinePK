//
//  NEAudioOption.m
//  NLiteAVDemo
//
//  Created by vvj on 2021/8/16.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NEAudioOption.h"
#import <NERtcSDK/NERtcSDK.h>
@implementation NEAudioOption

- (void)enableLocalAudio:(BOOL)enabled {
    int ret = [[NERtcEngine sharedEngine] enableLocalAudio:enabled];
    if (ret != kNERtcNoError) {
        return YXAlogError(@"enableLocalAudio faild,Error: %@", NERtcErrorDescription(ret));
    }
}

- (void)muteLocalAudio:(BOOL)muted {
    int ret = [[NERtcEngine sharedEngine] muteLocalAudio:muted];
    if (ret != kNERtcNoError) {
        return YXAlogError(@"muteLocalAudio faild,Error: %@", NERtcErrorDescription(ret));
    }
}

- (void)setAudioCaptureVolume:(uint32_t)volume {
    
    int ret = [NERtcEngine.sharedEngine adjustRecordingSignalVolume:volume];
    if (ret != kNERtcNoError) {
        return YXAlogError(@"setAudioCaptureVolume failed，Error: %@", NERtcErrorDescription(ret));
    }
}

- (void)enableEarBack:(BOOL)enabled{
    int ret = [NERtcEngine.sharedEngine enableEarback:enabled volume:80];
    if (ret != kNERtcNoError) {
        return YXAlogError(@"enableEarBack failed，Error: %@", NERtcErrorDescription(ret));
    }
}

- (void)startAudioMixing:(NERtcCreateAudioMixingOption *)opt{
    int ret = [[NERtcEngine sharedEngine] startAudioMixingWithOption:opt];
    if (ret != 0) {
        YXAlogInfo(@"startAudioMixing failed,Error: %@",NERtcErrorDescription(ret));
    }
}

- (void)stopAudioMixing {
    int ret = [[NERtcEngine sharedEngine] stopAudioMixing];
    if (ret != 0) {
        YXAlogInfo(@"stopAudioMixing failed,Error: %@",NERtcErrorDescription(ret));
    }
}

- (void)playEffect:(uint32_t)effectId effectOption:(NERtcCreateAudioEffectOption *)option{
    int ret = [[NERtcEngine sharedEngine] playEffectWitdId:effectId effectOption:option];
    if (ret != 0) {
        YXAlogInfo(@"playEffect failed,Error: %@",NERtcErrorDescription(ret));
    }
}

- (void)stopEffect:(uint32_t)effectId {
    int ret = [[NERtcEngine sharedEngine] stopEffectWitdId:effectId];
    if (ret != 0) {
        YXAlogInfo(@"stopEffect failed,Error: %@",NERtcErrorDescription(ret));
    }
}

- (void)setAudioMixingSendVolume:(uint32_t)volume {
    int ret = [[NERtcEngine sharedEngine] setAudioMixingSendVolume:volume];
    if (ret != 0) {
        YXAlogInfo(@"setAudioMixingSendVolume failed,Error: %@",NERtcErrorDescription(ret));
    }
}


- (void)setAudioMixingPlaybackVolume:(uint32_t)volume {
    int ret = [[NERtcEngine sharedEngine] setEarbackVolume:volume];
    if (ret != 0) {
        YXAlogInfo(@"setEarbackVolume failed,Error: %@",NERtcErrorDescription(ret));
    }
}


- (void)setEffectSendVolume:(uint32_t)volume {
    int ret = [[NERtcEngine sharedEngine] setEarbackVolume:volume];
    if (ret != 0) {
        YXAlogInfo(@"setEarbackVolume failed,Error: %@",NERtcErrorDescription(ret));
    }
}

- (void)setEffectSendVolume:(uint32_t)effectId volume:(uint32_t)volume{
    int ret = [[NERtcEngine sharedEngine] setEffectSendVolumeWithId:effectId volume:volume];
    if (ret != 0) {
        YXAlogInfo(@"setEarbackVolume failed,Error: %@",NERtcErrorDescription(ret));
    }

}

- (void)setEffectPlaybackVolume:(uint32_t)effectId volume:(uint32_t)volume{
    int ret = [[NERtcEngine sharedEngine] setEffectPlaybackVolumeWithId:effectId volume:volume];
    if (ret != 0) {
        YXAlogInfo(@"setEarbackVolume failed,Error: %@",NERtcErrorDescription(ret));
    }
}

- (void)stopAllEffects {
    int ret = [[NERtcEngine sharedEngine] stopAllEffects];
    if (ret != 0) {
        YXAlogInfo(@"stopAllEffects failed,Error: %@",NERtcErrorDescription(ret));
    }
}


@end
