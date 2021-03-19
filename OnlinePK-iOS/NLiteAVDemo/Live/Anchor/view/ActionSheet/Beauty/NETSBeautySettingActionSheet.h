//
//  NETSBeautySettingActionSheet.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/12.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSBaseActionSheet.h"

NS_ASSUME_NONNULL_BEGIN

@class NETSBeautyParam;

///
/// 美颜设置ActionSheet
///

@interface NETSBeautySettingActionSheet : NETSBaseActionSheet

///
/// 展示美颜设置ActionSheet
///
+ (void)show;

/**
 取消遮罩展示美颜设置ActionSheet
 @param mask - 是否显示遮罩
 */
+ (void)showWithMask:(BOOL)mask;

@end

NS_ASSUME_NONNULL_END
