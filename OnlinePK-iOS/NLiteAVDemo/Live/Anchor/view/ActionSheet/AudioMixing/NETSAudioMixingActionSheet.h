//
//  NETSAudioMixingActionSheet.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/19.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NETSBaseActionSheet.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kNetsRtcEffectStopNoti;

///
/// 直播过程中 混音设置
///

@interface NETSAudioMixingActionSheet : NETSBaseActionSheet

+ (void)show;

@end

NS_ASSUME_NONNULL_END
