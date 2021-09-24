//
//  NEMenuCell.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/21.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NEMenuCellBlock)(void);

@interface NEMenuCellModel : NSObject
//主标题
@property (nonatomic, copy) NSString    *title;
//副标题
@property (nonatomic, copy) NSString    *subtitle;
//头像
@property (nonatomic, copy) NSString    *icon;

@property (nonatomic, copy) NEMenuCellBlock block;

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                        icon:(NSString *)icon
                       block:(NEMenuCellBlock)block;

@end

///

@interface NEMenuCell : UITableViewCell


+ (NEMenuCell *)cellWithTableView:(UITableView *)tableView
                        indexPath:(NSIndexPath *)indexPath
                             data:(NEMenuCellModel *)data;

+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
