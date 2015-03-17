//
//  CommonUtils.h
//  baccarat
//
//  Created by kimks on 10/24/12.
//  Copyright (c) 2012 com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "common.h"
typedef long long TIMESTAMP;

@interface CommonUtils : NSObject

+ (TIMESTAMP)currentTime;
+ (NSString *)appVersion;
+ (CGFloat)osVersion;
+ (NSString *)numberExpression:(CGFloat)value :(NSInteger)precision;
+ (NSString *)numberAndUnit:(long long)value;
+ (double)numberFromFormattedPrice:(NSString*) formattedString;

@end
