//
//  NETSFilterSettingActionSheet.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSBaseActionSheet.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSBeautyParam;

@interface NETSFilterSettingActionSheet : NETSBaseActionSheet

///
/// 展示滤镜设置ActionSheet
///
+ (void)show;

/**
 展示滤镜设置ActionSheet
 @param mask    - 是否显示背景遮罩
 */
+ (void)showWithMask:(BOOL)mask;

@end

NS_ASSUME_NONNULL_END
