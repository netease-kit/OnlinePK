//
//  NETSLiveListVC.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 直播列表页 VC
///

@interface NETSLiveListVC : UIViewController



/// 构造方法
/// @param roomType 房间类型
- (instancetype)initWithNavRoomType:(NERoomType)roomType;

@end

NS_ASSUME_NONNULL_END
