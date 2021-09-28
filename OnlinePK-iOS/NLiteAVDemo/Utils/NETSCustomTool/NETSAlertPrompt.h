//
//  FBAlertPrompt.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

//点击回调类型
typedef NS_ENUM(NSUInteger,AlertPromptType) {
    AlertPromptTypeCancel = 0,  //取消操作
    AlertPromptTypeNormal       //普通操作
};

@interface NETSAlertPrompt : NSObject

/**
 系统提示框

 @param alertStyle 提示框类型
 @param title 标题
 @param messgae 详细信息
 @param array 选择按钮数组
 @param actionColors 选择按钮颜色数组(默认0x333333,使用默认值时传入@[])
 @param cancel 取消按钮
 @param index 选择事件回调 (NSInteger类型 index=0为系统cancel事件，其余为actionArr事件，从1开始)
 @param presentVc 显示的控制器(非必传)
 */
+ (void)showAlert:(UIAlertControllerStyle)alertStyle title:(NSString *)title message:(NSString *)messgae actionArr:(NSArray *)array actionColors:(NSArray *)actionColors cancel:(NSString *)cancel index:(void(^)(NSInteger index))index presentVc:(UIViewController *)presentVc;

/**
 系统提示框,可设置详细信息对齐方式
 
 @param alertStyle 提示框类型
 @param title 标题
 @param messgae 详细信息
 @param messageAlignment 信息文本对齐方式
 @param array 选择按钮数组
 @param actionColors 选择按钮颜色数组(默认0x333333,使用默认值时传入@[])
 @param cancel 取消按钮
 @param index 选择事件回调 (NSInteger类型 index=0为系统cancel事件，其余为actionArr事件，从1开始)
 @param presentVc 显示的控制器(非必传)
 */
+ (void)showAlert:(UIAlertControllerStyle)alertStyle title:(NSString *)title message:(NSString *)messgae messageAlignment:(NSTextAlignment)messageAlignment actionArr:(NSArray *)array actionColors:(NSArray *)actionColors cancel:(NSString *)cancel index:(void(^)(NSInteger index))index presentVc:(UIViewController *)presentVc;

/**
 系统提示框(可设置取消按钮颜色)
 
 @param alertStyle 提示框类型
 @param title 标题
 @param messgae 详细信息
 @param array 选择按钮数组
 @param actionColors 选择按钮颜色数组(默认0x333333,使用默认值时传入@[])
 @param cancel 取消按钮
 @param cancelColor 取消按钮颜色
 @param index 选择事件回调 (NSInteger类型 index=0为系统cancel事件，其余为actionArr事件，从1开始)
 @param presentVc 显示的控制器(非必传)
 */
+ (void)showAlertWithAlertStyle:(UIAlertControllerStyle)alertStyle title:(NSString *)title message:(NSString *)messgae actionArr:(NSArray *)array actionColors:(NSArray *)actionColors cancel:(NSString *)cancel cancelColor:(UIColor *)cancelColor index:(void(^)(NSInteger index))index presentVc:(UIViewController *)presentVc;



@end
