//
//  CommonUtils.m
//  baccarat
//
//  Created by kimks on 10/24/12.
//  Copyright (c) 2012 com. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils


+ (TIMESTAMP)currentTime
{
    return (TIMESTAMP)([[[NSDate alloc] init] timeIntervalSince1970] * 1000);
}


+ (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


+ (CGFloat)osVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}


+ (NSString *)numberExpression:(CGFloat)value :(NSInteger)precision
{
    char buff[1024] = {0, }, data[1500] = {0, };
    sprintf(buff, "%.10f", value);
    
    char *dot = strchr(buff, '.');
    *dot = '\0';

    int len = strlen(buff);
    int remainder = len % 3;

    char *src = buff, *dst = data;
    if (remainder != 0) {
        strncpy(dst, src, remainder);
        src += remainder;
        dst += remainder;
        if (src != dot) {
            *dst = ',';
            dst ++;
        }
    }

    while (src != dot) {
        strncpy(dst, src, 3);
        dst += 3;
        src += 3;
        
        if (src != dot) {
            *dst = ',';
            dst ++;
        } else {
            break;
        }
    }

    *dst = '.';
    dst++;
    strncpy(dst, dot+1, precision);

    return [NSString stringWithUTF8String:data];
}


+ (NSString *)numberAndUnit:(long long)value
{
    long long unitValues[4] = {1000000000000LL, 1000000000LL, 1000000LL, 1000LL};
    NSString *unitSignals[4] = {@"T", @"G", @"M", @"K"};
    for (int i = 0; i < 4; i++) {
        if (value >= unitValues[i]) {
            return [NSString stringWithFormat:@"%lld%@", value/unitValues[i], unitSignals[i]];
        }
    }

    return [NSString stringWithFormat:@"%lld", value];
}

+ (double)numberFromFormattedPrice:(NSString*) formattedString
{
    NSString* alpabet[4] = {@"$", @"?", @"[",@"]"};
    NSString * numString = formattedString;
    for (int i=0; i < 4; i++) {
        numString = [numString stringByReplacingOccurrencesOfString:alpabet[i] withString:@""];
    }
    return [numString doubleValue];
}


@end
