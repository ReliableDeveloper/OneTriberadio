//
//  BLYYoutubeURLCollection.m
//  BLYYoutubeExtractor
//
//  Created by Jeremy Levy on 22/01/2014.
//  Copyright (c) 2014 Jeremy Levy. All rights reserved.
//

#import "BLYYoutubeURLCollection.h"
#import "BLYYoutubeURL.h"

@interface BLYYoutubeURLCollection ()

@property (strong, nonatomic) NSMutableArray *URLs;
@property (strong, nonatomic) NSArray *availableItags;

@end

@implementation BLYYoutubeURLCollection

- (id)init
{
    self = [super init];
    
    if (self) {
        _URLs = [[NSMutableArray alloc] init];
        _availableItags = @[@(17), @(36), @(83), @(18), @(82), @(22), @(84), @(85)];
    }
    
    return self;
}

- (void)addURL:(BLYYoutubeURL *)URL
{
    [self.URLs addObject:URL];
}

- (void)sortURLsByItag
{
    [self.URLs sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        BLYYoutubeURL *URL1 = obj1;
        BLYYoutubeURL *URL2 = obj2;
        NSUInteger itagIdx1 = [self.availableItags indexOfObject:[NSNumber numberWithInteger:URL1.itag]];
        NSUInteger itagIdx2 = [self.availableItags indexOfObject:[NSNumber numberWithInteger:URL2.itag]];
        
        if (itagIdx1 > itagIdx2) {
            return NSOrderedDescending;
        } else if (itagIdx1 < itagIdx2) {
            return NSOrderedAscending;
        }
        
        return NSOrderedSame;
    }];
}

- (BLYYoutubeURL *)URLForVideoWithQuality:(NSString *)quality
{
    if ([self.URLs count] == 0
        || ([self.URLs count] < 3
            && [quality isEqualToString:@"medium"])) {
        return nil;
    }
    
    [self sortURLsByItag];
    
    BLYYoutubeURL *URL = [self.URLs lastObject];
    
    if ([quality isEqualToString:@"min"]) {
        URL = [self.URLs firstObject];
    } else if ([quality isEqualToString:@"medium"]) {
        NSNumber *indexAsNumber = [NSNumber numberWithDouble:floor([self.URLs count] / 2)];
        NSInteger index = [indexAsNumber integerValue];
        
        URL = [self.URLs objectAtIndex:index];
    }
    
    return URL;
}

- (BLYYoutubeURL *)URLForVideoWithLowerQuality
{
    return [self URLForVideoWithQuality:@"min"];
}

- (BLYYoutubeURL *)URLForVideoWithMediumQuality
{
    return [self URLForVideoWithQuality:@"medium"];
}

- (BLYYoutubeURL *)URLForVideoWithHigherQuality
{
    return [self URLForVideoWithQuality:@"max"];
}

@end
