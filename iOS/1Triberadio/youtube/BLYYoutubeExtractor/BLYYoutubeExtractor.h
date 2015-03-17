//
//  BLYYoutubeExtractor.h
//  Blynde
//
//  Created by Jeremy Levy on 03/12/2013.
//  Copyright (c) 2013 Jeremy Levy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BLYYoutubeExtractorErrorCodeForPlayerConfigNotFound,
    BLYYoutubeExtractorErrorCodeForInvalidPlayerConfig,
    BLYYoutubeExtractorErrorCodeForVideoOwnedByCopyrightInfrignement,
    BLYYoutubeExtractorErrorCodeForHTML5FileDoesntContainSignatureMethodCall,
    BLYYoutubeExtractorErrorCodeForInvalidVideoURL,
    BLYYoutubeExtractorErrorCodeForNotFoundVideoURL
} BLYYoutubeExtractorErrorCode;

@class BLYYoutubeURLCollection;

@interface BLYYoutubeExtractor : NSObject

- (void)urlsForVideoID:(NSString *)videoID
          inBackground:(BOOL)inBackground
   withCompletionBlock:(void(^)(BLYYoutubeURLCollection *, NSError *))completionBlock;

@end
