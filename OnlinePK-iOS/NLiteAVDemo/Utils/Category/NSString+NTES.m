//
//  NSString+NTES.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

#import "NSString+NTES.h"

@implementation NSString (NTES)

- (nullable id)jsonObject
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        return object;
    }
    return nil;
}

- (BOOL)isChinese
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

- (NSString *)ne_trimming {
    return [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)ne_isNumber {
    NSString *string = [self ne_trimming];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    return string.length > 0 ? NO : YES;
}
@end
