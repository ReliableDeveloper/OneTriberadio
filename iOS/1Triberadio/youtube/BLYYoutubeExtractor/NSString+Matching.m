//
//  NSString+Matching.m
//  Blynde
//
//  Created by Jeremy Levy on 02/12/2013.
//  Copyright (c) 2013 Jeremy Levy. All rights reserved.
//

#import "NSString+Matching.h"

@implementation NSString (Matching)

- (BOOL)bly_match:(NSString *)pattern
{
    NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                    options:NSRegularExpressionCaseInsensitive
                                                                      error:nil];
    
    return [reg numberOfMatchesInString:self
                                options:0
                                  range:NSMakeRange(0, [self length])] > 0;
}

@end
