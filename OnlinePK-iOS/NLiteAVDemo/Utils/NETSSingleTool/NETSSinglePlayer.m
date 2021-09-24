//
//  NETSSinglePlayer.m
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2021/1/7.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSSinglePlayer.h"

#import <NELivePlayerFramework/NELivePlayerFramework.h>

@interface NETSSinglePlayer ()
@property(nonatomic, strong) NELivePlayerController *videoPlayer;
@end

@implementation NETSSinglePlayer

+ (instancetype )sharePlayerManager {
    static dispatch_once_t onceToken;
    static NETSSinglePlayer *_playManager;
    dispatch_once(&onceToken, ^{
        _playManager = [[NETSSinglePlayer alloc] init];
    });
    return _playManager;
}

- (void)destoryPlayer {
    [self.videoPlayer shutdown];
    YXAlogInfo(@"SHUTDOWN PLAYER: %p...", self);
    [self.videoPlayer.view removeFromSuperview];
    self.videoPlayer = nil;
}

-(NELivePlayerController *)currentPlayer {
    return self.videoPlayer;
}

- (NELivePlayerController *)videoPlayer {
    if (!_videoPlayer) {
         NSError *error = nil;
        _videoPlayer = [[NELivePlayerController alloc] initWithContentURL:self.playUrl config:nil error:&error];
        [_videoPlayer setBufferStrategy:NELPLowDelay];
        [_videoPlayer setScalingMode:NELPMovieScalingModeNone];
        [_videoPlayer setShouldAutoplay:YES];
        [_videoPlayer setHardwareDecoder:YES];
        [_videoPlayer setPauseInBackground:NO];
        [_videoPlayer setPlaybackTimeout:15 *1000];
        [_videoPlayer prepareToPlay];
    }
    return _videoPlayer;
}

@end
