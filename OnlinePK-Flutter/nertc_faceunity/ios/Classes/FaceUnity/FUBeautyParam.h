// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FUBeautyParam : NSObject
@property(nonatomic, copy) NSString *mTitle;

@property(nonatomic, copy) NSString *mParam;

@property(nonatomic, assign) float mValue;

@property(nonatomic, copy) NSString *mImageStr;

/* 双向的参数  0.5是原始值*/
@property(nonatomic, assign) BOOL iSStyle101;

/* 默认值用于，设置默认和恢复 */
@property(nonatomic, assign) float defaultValue;
@end

NS_ASSUME_NONNULL_END
