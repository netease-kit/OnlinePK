// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FULiveModelType) {
  FULiveModelTypeBeautifyFace = 0,
  FULiveModelTypeMakeUp,
  FULiveModelTypeItems,
  FULiveModelTypeAnimoji,
  FULiveModelTypeHair,
  FULiveModelTypeLightMakeup,
  FULiveModelTypeARMarsk,
  FULiveModelTypeHilarious,
  FULiveModelTypePoster,  // 海报换脸
  FULiveModelTypeExpressionRecognition,
  FULiveModelTypeMusicFilter,
  FULiveModelTypeHahaMirror,
  FULiveModelTypeBody,
  FULiveModelTypeWholeAvatar,
  FULiveModelTypeActionRecognition,
  FULiveModelTypeBGSegmentation,
  FULiveModelTypeGestureRecognition,
  FULiveModelTypeLvMu

};

@interface FULiveModel : NSObject

@property(nonatomic, assign) NSInteger maxFace;

@property(nonatomic, copy) NSString *title;

@property(nonatomic, assign) BOOL enble;

@property(nonatomic, assign) FULiveModelType type;
/* 对比 */
@property(nonatomic, assign) int conpareCode;

@property(nonatomic, assign) NSArray *modules;

@property(nonatomic, strong) NSArray<NSString *> *items;

@property(nonatomic, assign) int selIndex;
@end
