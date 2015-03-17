//
//  BLYYoutubeURL.m
//  BLYYoutubeExtractor
//
//  Created by Jeremy Levy on 22/01/2014.
//  Copyright (c) 2014 Jeremy Levy. All rights reserved.
//

#import "BLYYoutubeURL.h"

@implementation BLYYoutubeURL

- (void)populateWithValues:(NSDictionary *)values
{
    NSTimeInterval expiresAt = [values[@"expire"] doubleValue];
    
    self.itag = [values[@"itag"] integerValue];
    self.expiresAt = [NSDate dateWithTimeIntervalSince1970:expiresAt];
    self.value = values[@"url"];
    self.sig = values[@"sig"];
    self.s = values[@"s"];
    
    if (!self.sig && values[@"signature"]) {
        self.sig = values[@"signature"];
    }
}

- (BOOL)isExpired
{
    NSDate *now = [NSDate date];
    
    return [self.expiresAt compare:now] == NSOrderedAscending;
}

@end
