
//
//  FBAlertPrompt.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSAlertPrompt.h"
#import "NSObject+additions.h"

@implementation NETSAlertPrompt

+ (void)showAlert:(UIAlertControllerStyle)alertStyle title:(NSString *)title message:(NSString *)messgae actionArr:(NSArray *)array actionColors:(NSArray *)actionColors cancel:(NSString *)cancel index:(void(^)(NSInteger index))index presentVc:(UIViewController *)presentVc {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:messgae preferredStyle:alertStyle];
//    if (@available(iOS 13.0, *)) {
//        alertVC.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
//    }
    if (![NSObject isNullOrNilWithObject:title]) {
        NSMutableAttributedString *titleAttributed = [[NSMutableAttributedString alloc] initWithString:title];
        [titleAttributed addAttributes:@{NSFontAttributeName:TextFont_15,NSForegroundColorAttributeName:HEXCOLOR(0x333333)} range:NSMakeRange(0, title.length)];
        [alertVC setValue:titleAttributed forKey:@"attributedTitle"];
    }
    if (![NSObject isNullOrNilWithObject:messgae]) {
        NSMutableAttributedString *messageAttributed = [[NSMutableAttributedString alloc] initWithString:messgae];
        [messageAttributed addAttributes:@{NSFontAttributeName:TextFont_14,NSForegroundColorAttributeName:HEXCOLOR(0x808080)} range:NSMakeRange(0, messgae.length)];
        [alertVC setValue:messageAttributed forKey:@"attributedMessage"];
    }
    for (NSInteger i = 0; i < array.count; i++) {
       UIAlertAction *action = [UIAlertAction actionWithTitle:array[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (index) {
                index(i+1);
            }
        }];
       
        if (actionColors.count) {
            [action setValue:actionColors[i] forKey:@"_titleTextColor"];
            [alertVC addAction:action];
        }else {
            [action setValue:UIColor.redColor forKey:@"_titleTextColor"];
            [alertVC addAction:action];
        }
    }
    
    if (cancel.length && cancel) {
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (index) {
                index(AlertPromptTypeCancel);
            }
        }];
        [alertVC addAction:cancleAction];
        [cancleAction setValue:HEXCOLOR(0x666666) forKey:@"_titleTextColor"];

    }
    if ([NSObject isNullOrNilWithObject:presentVc]) {
        presentVc = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    [presentVc presentViewController:alertVC animated:YES completion:nil];
}

+ (void)showAlert:(UIAlertControllerStyle)alertStyle title:(NSString *)title message:(NSString *)messgae messageAlignment:(NSTextAlignment)messageAlignment actionArr:(NSArray *)array actionColors:(NSArray *)actionColors cancel:(NSString *)cancel index:(void(^)(NSInteger index))index presentVc:(UIViewController *)presentVc {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:messgae preferredStyle:alertStyle];
    if (@available(iOS 13.0, *)) {
        alertVC.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    if (![NSObject isNullOrNilWithObject:title]) {
        NSMutableAttributedString *titleAttributed = [[NSMutableAttributedString alloc] initWithString:title];
        [titleAttributed addAttributes:@{NSFontAttributeName:TextFont_16,NSForegroundColorAttributeName:HEXCOLOR(0x333333)} range:NSMakeRange(0, title.length)];
        [alertVC setValue:titleAttributed forKey:@"attributedTitle"];
    }
    if (![NSObject isNullOrNilWithObject:messgae]) {
        NSMutableAttributedString *messageAttributed = [[NSMutableAttributedString alloc] initWithString:messgae];
        NSMutableParagraphStyle *messageParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        messageParagraphStyle.alignment = messageAlignment;
        [messageAttributed addAttributes:@{NSFontAttributeName:TextFont_14,NSForegroundColorAttributeName:HEXCOLOR(0x808080),NSParagraphStyleAttributeName:messageParagraphStyle} range:NSMakeRange(0, messgae.length)];
        [alertVC setValue:messageAttributed forKey:@"attributedMessage"];
    }
    for (NSInteger i = 0; i < array.count; i++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:array[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (index) {
                index(i+1);
            }
        }];
        
        if (actionColors.count) {
            [action setValue:actionColors[i] forKey:@"_titleTextColor"];
            [alertVC addAction:action];
        }else {
            [action setValue:UIColor.redColor  forKey:@"_titleTextColor"];
            [alertVC addAction:action];
        }
    }
    
    if (cancel.length && cancel) {
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (index) {
                index(AlertPromptTypeCancel);
            }
        }];
        [alertVC addAction:cancleAction];
        [cancleAction setValue:HEXCOLOR(0x333333) forKey:@"_titleTextColor"];
        
    }
    if ([NSObject isNullOrNilWithObject:presentVc]) {
        presentVc = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    [presentVc presentViewController:alertVC animated:YES completion:nil];
}

+ (void)showAlertWithAlertStyle:(UIAlertControllerStyle)alertStyle title:(NSString *)title message:(NSString *)messgae actionArr:(NSArray *)array actionColors:(NSArray *)actionColors cancel:(NSString *)cancel cancelColor:(UIColor *)cancelColor index:(void(^)(NSInteger index))index presentVc:(UIViewController *)presentVc {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:messgae preferredStyle:alertStyle];
    if (@available(iOS 13.0, *)) {
        alertVC.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    if (![NSObject isNullOrNilWithObject:title]) {
        NSMutableAttributedString *titleAttributed = [[NSMutableAttributedString alloc] initWithString:title];
        [titleAttributed addAttributes:@{NSFontAttributeName:TextFont_16,NSForegroundColorAttributeName:HEXCOLOR(0x333333)} range:NSMakeRange(0, title.length)];
        [alertVC setValue:titleAttributed forKey:@"attributedTitle"];
    }
    if (![NSObject isNullOrNilWithObject:messgae]) {
        NSMutableAttributedString *messageAttributed = [[NSMutableAttributedString alloc] initWithString:messgae];
        [messageAttributed addAttributes:@{NSFontAttributeName:TextFont_14,NSForegroundColorAttributeName:HEXCOLOR(0x808080)} range:NSMakeRange(0, messgae.length)];
        [alertVC setValue:messageAttributed forKey:@"attributedMessage"];
    }

    for (NSInteger i = 0; i < array.count; i++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:array[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (index) {
                index(i+1);
            }
        }];
        
        if (actionColors.count) {
            [action setValue:actionColors[i] forKey:@"_titleTextColor"];
            [alertVC addAction:action];
        }else {
            [action setValue:UIColor.redColor  forKey:@"_titleTextColor"];
            [alertVC addAction:action];
        }
    }
    
    if (cancel.length && cancel) {
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (index) {
                index(AlertPromptTypeCancel);
            }
        }];
        [alertVC addAction:cancleAction];
        if (![NSObject isNullOrNilWithObject:cancelColor]) {
             [cancleAction setValue:cancelColor forKey:@"_titleTextColor"];
        }else {
            [cancleAction setValue:HEXCOLOR(0x666666) forKey:@"_titleTextColor"];
        }
        
    }
    //    if (@available(iOS 9.0, *))  {
    //        UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]];
    //        [appearanceLabel setAppearanceFont:TextFont_17];
    //    }else {
    //        UILabel *appearanceLabel = [UILabel appearanceWhenContainedIn:[UIAlertController class], nil];
    //        [appearanceLabel setAppearanceFont:TextFont_17];
    //
    //    }
    if ([NSObject isNullOrNilWithObject:presentVc]) {
        presentVc = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    [presentVc presentViewController:alertVC animated:YES completion:nil];
}


@end
