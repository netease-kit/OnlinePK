//
//  NSMacro.m
//  NLiteAVDemo
//
//  Created by Think on 2020/8/26.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NSMacro.h"

void ntes_main_sync_safe(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void ntes_main_async_safe(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        block();
    }else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

bool isEmptyString(NSString *string) {
    if (string && [string length] > 0) {
        return false;
    }
    return true;
}

NSString * kFormatNum(int32_t num)
{
    if (num < 10000) {
        return [NSString stringWithFormat:@"%d", num];
    } else if (num % 10000 == 0) {
        return [NSString stringWithFormat:@"%.0f万", num / 10000.0];
    } else if (num % 1000 == 0) {
        return [NSString stringWithFormat:@"%.1f万", num / 10000.0];
    }
    return [NSString stringWithFormat:@"%.2f万", num / 10000.0];
}
