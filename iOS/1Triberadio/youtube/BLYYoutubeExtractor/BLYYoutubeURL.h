//
//  BLYYoutubeURL.h
//  BLYYoutubeExtractor
//
//  Created by Jeremy Levy on 22/01/2014.
//  Copyright (c) 2014 Jeremy Levy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLYYoutubeURL : NSObject

@property (nonatomic) NSInteger itag;
@property (strong, nonatomic) NSDate *expiresAt;
@property (strong, nonatomic) NSString *value;
@property (strong, nonatomic) NSString *sig;
@property (strong, nonatomic) NSString *s;

- (void)populateWithValues:(NSDictionary *)values;
- (BOOL)isExpired;

@end
