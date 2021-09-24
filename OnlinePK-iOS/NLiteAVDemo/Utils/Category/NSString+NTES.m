//
//  NSString+NTES.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/24.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NSString+NTES.h"
#import <CommonCrypto/CommonDigest.h>

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


+ (NSString *)md5ForLower32Bate:(NSString *)str{
    
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}
@end
