//
//  NTESActionSheetNavigationController.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/27.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESActionSheetNavigationController : UINavigationController

/**
 是否点击外侧消失
 */
@property (nonatomic, assign) BOOL dismissOnTouchOutside;

@end


NS_ASSUME_NONNULL_END
