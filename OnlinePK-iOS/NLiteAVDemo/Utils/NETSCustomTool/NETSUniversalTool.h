//
//  NETSUniversalTool.h
//  NLiteAVDemo
//
//  Created by vvj on 2021/5/18.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NETSUniversalTool : NSObject
/**
 获取当前活跃的控制器

 @return 活跃控制器Vc
 */
+ (UIViewController  * _Nullable)getCurrentActivityViewController;

@end

NS_ASSUME_NONNULL_END
