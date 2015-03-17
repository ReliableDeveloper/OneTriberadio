//
//  BLYYoutubeURLCollection.h
//  BLYYoutubeExtractor
//
//  Created by Jeremy Levy on 22/01/2014.
//  Copyright (c) 2014 Jeremy Levy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLYYoutubeURL;

@interface BLYYoutubeURLCollection : NSObject

- (void)addURL:(BLYYoutubeURL *)URL;
- (BLYYoutubeURL *)URLForVideoWithLowerQuality;
- (BLYYoutubeURL *)URLForVideoWithMediumQuality;
- (BLYYoutubeURL *)URLForVideoWithHigherQuality;

@end
