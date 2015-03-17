//
//  BLYYoutubeExtractor.m
//  Blynde
//
//  Created by Jeremy Levy on 03/12/2013.
//  Copyright (c) 2013 Jeremy Levy. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "BLYYoutubeExtractor.h"
#import "BLYHTTPConnection.h"
#import "NSString+Escaping.h"
#import "NSString+Matching.h"
#import "BLYYoutubeURL.h"
#import "BLYYoutubeURLCollection.h"

NSString * const BLYYoutubeExtractorWatchURLPattern = @"http://www.youtube.com/watch?v=%@";
NSString * const BLYYoutubeExtractorGetVideoInfoURLPattern = @"https://www.youtube.com/get_video_info?&video_id=%@&el=embedded&ps=default&eurl=";
NSString * const BLYYoutubeExtractorWatchURLUserAgent = @"Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)";
NSString * const BLYYoutubeExtractorLastCachedJsFileUserDefaultsKey = @"BLYYoutubeExtractorLastCachedJsFile";
NSString * const BLYYoutubeExtractorLastDecodeSigFuncNameUserDefaultsKey = @"BLYYoutubeExtractorLastDecodeSigFuncName";

@interface BLYYoutubeExtractor ()

@end

@implementation BLYYoutubeExtractor

- (NSURL *)watchURLForVideoWithID:(NSString *)videoID
{
    videoID = [videoID bly_stringByAddingPercentEscapes];
    
    NSString *url = [NSString stringWithFormat:BLYYoutubeExtractorWatchURLPattern, videoID];
    
    return [NSURL URLWithString:url];
}

- (NSURL *)videoInfoUrlForVideoWithID:(NSString *)videoID
{
    videoID = [videoID bly_stringByAddingPercentEscapes];
    
    NSString *url = [NSString stringWithFormat:BLYYoutubeExtractorGetVideoInfoURLPattern, videoID];
    
    return [NSURL URLWithString:url];
}

- (void)urlsForVideoID:(NSString *)videoID
          inBackground:(BOOL)inBackground
   withCompletionBlock:(void(^)(BLYYoutubeURLCollection *, NSError *))completionBlock
{
    BLYYoutubeURLCollection *URLCollection = [[BLYYoutubeURLCollection alloc] init];
    NSURL *watchURL = [self watchURLForVideoWithID:videoID];
    
    __weak BLYYoutubeExtractor *weakSelf = self;
    
    void(^extractPlayerConfigCompletionBlock)(NSDictionary*, NSError*) = ^(NSDictionary *playerConfig, NSError *error) {
        if (error) {
            return completionBlock(nil, error);
        }
        
        NSString *HTML5File = playerConfig[@"jsFile"];
        NSArray *_URLs = playerConfig[@"URLs"];
        
        __block NSUInteger remainingURLs = [_URLs count];
        
        if (remainingURLs == 0) {
            error = [weakSelf errorWithCode:BLYYoutubeExtractorErrorCodeForNotFoundVideoURL
                    andLocalizedDescription:@"Video URL not found."];
            
            return completionBlock(nil, error);
        }
        
        void (^addURLWithSignature)(BLYYoutubeURL *, NSString *) = ^(BLYYoutubeURL *URL, NSString *signature){
            NSString *urlAsString = URL.value;
            
            urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&signature=%@", signature]];
            urlAsString = [urlAsString stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
            
            URL.value = urlAsString;
            
            [URLCollection addURL:URL];
            
            remainingURLs--;
            
            if (remainingURLs == 0) {
                completionBlock(URLCollection, nil);
            }
        };
        
        NSMutableArray *signatures = [[NSMutableArray alloc] init];
        
        for (BLYYoutubeURL *URL in _URLs) {
            if (URL.sig) {
                addURLWithSignature(URL, URL.sig);
                
                continue;
            }
            
            if (!URL.s) {
                error = [weakSelf errorWithCode:BLYYoutubeExtractorErrorCodeForInvalidVideoURL
                        andLocalizedDescription:@"Video URL contains neither sig nor s parameter."];
                
                return completionBlock(nil, error);
            }
            
            [signatures addObject:@[URL, URL.s]];
        }
        
        if ([signatures count] > 0) {
            [weakSelf decodeSignatures:signatures
                          forHTML5File:HTML5File
                          inBackground:inBackground
                   withCompletionBlock:^(NSMutableArray *_signatures, NSError *err){
                       
                       for (NSArray *signature in _signatures) {
                           addURLWithSignature([signature objectAtIndex:0], [signature objectAtIndex:1]);
                       }
                       
                   }];
        }
    };
    
    [self extractPlayerConfigArgumentsForVideoID:videoID
                                    withWatchUrl:watchURL
                                    inBackground:inBackground
                             withCompletionBlock:extractPlayerConfigCompletionBlock];
}

- (void)extractPlayerConfigArgumentsForVideoID:(NSString *)videoID
                                  withWatchUrl:(NSURL *)watchURL
                                  inBackground:(BOOL)inBackground
                           withCompletionBlock:(void(^)(NSDictionary *, NSError *))completionBlock
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:watchURL];
    
    // Set user agent to avoid redirection to YouTube mobile site
    [req setValue:BLYYoutubeExtractorWatchURLUserAgent forHTTPHeaderField:@"User-Agent"];
    
    BLYHTTPConnection *connection = [[BLYHTTPConnection alloc] initWithRequest:[req copy]];
    
    connection.displayActivityIndicator = !inBackground;
    
    // In order to keep Youtube extractor object alive don't use weakSelf in this block !
    [connection setCompletionBlock:^(NSData *obj, NSError *error) {
        NSMutableDictionary *playerConfig = [[NSMutableDictionary alloc] init];
        
        if (!error) {
            NSString *watchPageContent = [[NSString alloc] initWithData:obj
                                                               encoding:NSUTF8StringEncoding];
            
            if (watchPageContent) {
                NSRegularExpression *playerConfigReg = [[NSRegularExpression alloc] initWithPattern:@"ytplayer.config\\s*=\\s*(\\{.*?\\});"
                                                                                            options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                                              error:&error];
                
                if (error) {
                    return completionBlock(nil, error);
                }

                NSArray *matches = [playerConfigReg matchesInString:watchPageContent
                                                            options:0
                                                              range:NSMakeRange(0, [watchPageContent length])];
                
                if ([matches count] > 0) {
                    NSTextCheckingResult *result = [matches objectAtIndex:0];
                    
                    if ([result numberOfRanges] >= 2) {
                        NSRange r = [result rangeAtIndex:1];
                        NSString *playerConfigAsString = [watchPageContent substringWithRange:r];
                        
                        NSMutableDictionary *d = [[NSJSONSerialization JSONObjectWithData:[playerConfigAsString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                  options:0
                                                                                    error:&error] mutableCopy];
                        
                        
                        if (error) {
                            return completionBlock(nil, error);
                        }
                        
                        if (!d[@"args"]
                            || !d[@"assets"][@"js"]) {
                            
                            error = [self errorWithCode:BLYYoutubeExtractorErrorCodeForInvalidPlayerConfig
                                    andLocalizedDescription:@"ytplayer.config doesn't contain required values (args & assets)."];
                            
                            return completionBlock(nil, error);
                        }
                        
                        [playerConfig setObject:[[BLYYoutubeURLCollection alloc] init]
                                         forKey:@"URLs"];
                        
                        [playerConfig setObject:[[NSMutableDictionary alloc] init]
                                         forKey:@"jsFile"];
                        
                        NSDictionary * (^parseQueryString)(NSString *, BOOL) = ^ NSDictionary * (NSString *URL, BOOL removePercentEscape){
                            NSMutableDictionary *URLArgs = [[NSMutableDictionary alloc] init];
                            
                            for (NSString *arg in [URL componentsSeparatedByString:@"&"]) {
                                NSMutableArray *args = [[arg componentsSeparatedByString:@"="] mutableCopy];
                                id key = [args objectAtIndex:0];

                                
                                if ([args count] != 2) {
                                    if ([args count] > 2 && [key isEqualToString:@"url"]) {
                                        args[1] = [arg bly_stringByReplacingPattern:@"url=" withString:@""];
                                    } else {
                                        continue;
                                    }
                                }
                                
                                id value = [args objectAtIndex:1];
                                
                                if ([value isKindOfClass:[NSString class]]) {
                                    value = [value bly_stringByRemovingPercentEscapes];
                                }
                                
                                [URLArgs setObject:value forKey:key];
                            }
                            
                            return [URLArgs copy];
                        };
                        
                        void(^parseEncodedFmtStreamMap)(void) = ^{
                            NSArray *videoURLs = [d[@"args"][@"url_encoded_fmt_stream_map"] componentsSeparatedByString:@","];
                            NSMutableArray *videoURLArgsContainer = [[NSMutableArray alloc] init];
                            
                            for (NSString *videoURL in videoURLs) {
                                [videoURLArgsContainer addObject:parseQueryString(videoURL, NO)];
                            }
                            
                            NSMutableArray *URLs = [[NSMutableArray alloc] init];
                            
                            for (NSDictionary *videoURLArgs in videoURLArgsContainer) {
                                NSMutableDictionary *url = [[NSMutableDictionary alloc] init];
                                
                                for (NSString *videoURLArgKey in videoURLArgs) {
                                    NSString *videoURLArgValue = [videoURLArgs objectForKey:videoURLArgKey];
                                    
                                    if ([videoURLArgKey isEqualToString:@"url"]) {
                                        NSURL *rawURL = [NSURL URLWithString:[videoURLArgValue bly_stringByRemovingPercentEscapes]];
                                        NSDictionary *urlArgs = parseQueryString(rawURL.query, YES);
                                        
                                        for (NSString *urlKey in urlArgs) {
                                            if ([url objectForKey:urlKey]) {
                                                continue;
                                            }
                                            
                                            url[urlKey] = urlArgs[urlKey];
                                        }
                                    }
                                    
                                    if ([url objectForKey:videoURLArgKey]) {
                                        continue;
                                    }
                                    
                                    url[videoURLArgKey] = videoURLArgValue;
                                }
                                
                                NSArray *videoType = [url[@"type"] componentsSeparatedByString:@";"];
                                NSString *videoMIMEType = nil;
                                
                                if ([videoType count] > 0) {
                                    videoMIMEType = [videoType objectAtIndex:0];
                                }
                                
                                if (videoMIMEType && ![AVURLAsset isPlayableExtendedMIMEType:videoMIMEType]) {
                                    continue;
                                }
                                
                                BLYYoutubeURL *ytURL = [[BLYYoutubeURL alloc] init];
                                
                                [ytURL populateWithValues:url];
                                
                                [URLs addObject:ytURL];
                            }
                            
                            playerConfig[@"URLs"] = URLs;
                            
                            NSString *jsFile = d[@"assets"][@"js"];
                            NSString *HTTPPattern = @"^https?:";
                            
                            if (![jsFile bly_match:HTTPPattern]) {
                                jsFile = [@"http:" stringByAppendingString:jsFile];
                            }
                            
                            playerConfig[@"jsFile"] = jsFile;
                        };
                        
                        // Video owned
                        if (!d[@"args"][@"url_encoded_fmt_stream_map"]) {
                            NSError *copyrightInfrignementError = nil;
                            
                            copyrightInfrignementError = [self errorWithCode:BLYYoutubeExtractorErrorCodeForVideoOwnedByCopyrightInfrignement
                                                     andLocalizedDescription:@"Video owned by copyright infrignement."];
                            
                            // by age verification
                            if ([watchPageContent bly_match:@"player-age-gate-content\">"]) {
                                NSURL *videoInfoURL = [self videoInfoUrlForVideoWithID:videoID];
                                NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:videoInfoURL];
                                
                                // Set user agent to avoid redirection to YouTube mobile site
                                [req setValue:BLYYoutubeExtractorWatchURLUserAgent forHTTPHeaderField:@"User-Agent"];
                                
                                BLYHTTPConnection *connection = [[BLYHTTPConnection alloc] initWithRequest:[req copy]];
                                
                                connection.displayActivityIndicator = !inBackground;
                                
                                connection.completionBlock = ^(NSData *videoInfo, NSError *videoInfoError) {
                                    if (!error) {
                                        NSString *videoInfoContent = [[NSString alloc] initWithData:videoInfo
                                                                                           encoding:NSUTF8StringEncoding];

                                        NSDictionary *queryString = parseQueryString(videoInfoContent, NO);
                                        
                                        if (queryString[@"url_encoded_fmt_stream_map"]) {
                                            NSString *urlEncodedFmtStreamMap = queryString[@"url_encoded_fmt_stream_map"];
                                            
                                            urlEncodedFmtStreamMap = [urlEncodedFmtStreamMap bly_stringByReplacingPattern:@",\\+"
                                                                                                               withString:@"%2C+"];
                                            
                                            d[@"args"] = [d[@"args"] mutableCopy];
                                            d[@"args"][@"url_encoded_fmt_stream_map"] = urlEncodedFmtStreamMap;
                                            
                                            parseEncodedFmtStreamMap();
                                            
                                            return completionBlock([playerConfig copy], nil);
                                        }
                                    }
                                    
                                    return completionBlock(nil, copyrightInfrignementError);
                                };
                                
                                [connection start];
                                
                                return;
                            }
                            
                            // by copyright infrignement
                            return completionBlock(nil, copyrightInfrignementError);
                        }
                        
                        parseEncodedFmtStreamMap();
                    }
                } else {
                    error = [self errorWithCode:BLYYoutubeExtractorErrorCodeForPlayerConfigNotFound
                        andLocalizedDescription:@"ytplayer.config not found in video page."];
                    
                    return completionBlock(nil, error);
                }
            }
        }
        
        completionBlock([playerConfig copy], error);
    }];
    
    [self cleanYoutubeWebsiteCookies];
    
    [connection start];
}

- (void)cleanYoutubeWebsiteCookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = cookieStorage.cookies;
    
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.domain rangeOfString:@"youtube"].location == NSNotFound) {
            continue;
        }
        
        [cookieStorage deleteCookie:cookie];
    }
}

- (void)decodeSignatures:(NSMutableArray *)signatures
            forHTML5File:(NSString *)HTML5File
            inBackground:(BOOL)inBackground
     withCompletionBlock:(void(^)(NSMutableArray *, NSError *))completionBlock
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [cacheDirectories objectAtIndex:0];
    
    NSArray *HTML5FileURLParts = [HTML5File componentsSeparatedByString:@"/"];
    NSString *HTML5Filename = [HTML5FileURLParts lastObject];
    NSString *HTML5FilePath = [cacheDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", HTML5Filename]];
    
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    
    NSString *lastCachedJSFile = [userDefaults stringForKey:BLYYoutubeExtractorLastCachedJsFileUserDefaultsKey];
    BOOL HTML5FileIsCached = [defaultFileManager fileExistsAtPath:HTML5FilePath];
    
    void(^HTML5FileCompletion)(NSData *, NSError *) = ^(NSData *obj, NSError *error) {
        NSMutableArray *_signatures = [signatures mutableCopy];
        void(^hookedCompletionBlock)(NSMutableArray *, NSError *) = ^(NSMutableArray *a, NSError *e){
            return completionBlock(a, e);
        };
        
        if (!error) {
            NSString *data = [[NSString alloc] initWithData:obj
                                                   encoding:NSUTF8StringEncoding];
            
            if (data) {
                NSString *decodeFunctionName = [userDefaults stringForKey:BLYYoutubeExtractorLastDecodeSigFuncNameUserDefaultsKey];
                NSArray *matches = nil;
                
                if (!decodeFunctionName) {
                    NSRegularExpression *decodeFunctionNameReg = [[NSRegularExpression alloc] initWithPattern:@"signature=(\\w+?)\\([^)]\\)"
                                                                                                      options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                                                        error:nil];
                    
                    matches = [decodeFunctionNameReg matchesInString:data
                                                             options:0
                                                               range:NSMakeRange(0, [data length])];
                }
                
                if (decodeFunctionName || [matches count] > 0) {
                    NSTextCheckingResult *result = nil;
                    
                    if (!decodeFunctionName) {
                        result = [matches objectAtIndex:0];
                    }
                    
                    if (decodeFunctionName || [result numberOfRanges] >= 2) {
                        if (!decodeFunctionName) {
                            NSRange r = [result rangeAtIndex:1];
                            
                            decodeFunctionName = [data substringWithRange:r];
                        }
                        
                        if (!HTML5FileIsCached) {
                            // Remove IIFE (Immediately-Invoked Function Expression) to populate global context
                            data = [data bly_stringByReplacingPattern:@"^\\s*(\\(|!)\\s*function\\s*\\(\\s*\\)\\s*\\{"
                                                           withString:@""];
                            data = [data bly_stringByReplacingPattern:@"\\}\\s*\\)\\s*\\(\\s*\\)\\s*;?\\s*$"
                                                           withString:@""];
                            
                            [data writeToFile:HTML5FilePath
                                   atomically:YES
                                     encoding:NSUTF8StringEncoding
                                        error:&error];
                            
                            if (error) {
                                return completionBlock(nil, error);
                            }
                            
                            [userDefaults setObject:HTML5FilePath
                                             forKey:BLYYoutubeExtractorLastCachedJsFileUserDefaultsKey];
                            [userDefaults setObject:decodeFunctionName
                                             forKey:BLYYoutubeExtractorLastDecodeSigFuncNameUserDefaultsKey];
                            [userDefaults synchronize];
                        }
                        
                        UIWebView *webView = [[UIWebView alloc] init];
                        
                        [webView stringByEvaluatingJavaScriptFromString:data];
                        
                        int index = 0;
                        
                        for (NSArray *signature in signatures) {
                            BLYYoutubeURL *ytURL = [signature objectAtIndex:0];
                            NSString *signatureAsString = [signature objectAtIndex:1];
                            
                            NSString *webviewCall = [NSString stringWithFormat:@"%@(\"%@\");", decodeFunctionName, signatureAsString];
                            
                            signatureAsString = [webView stringByEvaluatingJavaScriptFromString:webviewCall];
                            
                            [_signatures replaceObjectAtIndex:index
                                                   withObject:@[ytURL, signatureAsString]];
                            
                            index++;
                        }
                    }
                } else {
                    error = [self errorWithCode:BLYYoutubeExtractorErrorCodeForHTML5FileDoesntContainSignatureMethodCall
                        andLocalizedDescription:@"HTML5 JS file doesn't contain a 'signature=()' method call."];
                    
                    return hookedCompletionBlock(nil, error);
                }
            }
        }
        
        hookedCompletionBlock(_signatures, error);
    };
    
    void(^HTML5FileHookedCompletion)(NSData *, NSError *) = ^(NSData *d, NSError *e){
        return HTML5FileCompletion(d, e);
    };
    
    if (HTML5FileIsCached) {
        NSData *HTML5FileContent = [NSData dataWithContentsOfFile:HTML5FilePath];
        
        if (HTML5FileContent) {
            return HTML5FileHookedCompletion(HTML5FileContent, nil);
        }
    }
    
    if (lastCachedJSFile) {
        NSError *removeJsFileError = nil;
        
        [[NSFileManager defaultManager] removeItemAtPath:lastCachedJSFile
                                                   error:&removeJsFileError];
        
        if (!removeJsFileError) {
            [userDefaults removeObjectForKey:BLYYoutubeExtractorLastCachedJsFileUserDefaultsKey];
            [userDefaults removeObjectForKey:BLYYoutubeExtractorLastDecodeSigFuncNameUserDefaultsKey];
            
            [userDefaults synchronize];
        }
    }
    
    NSURL *HTML5FileUrl = [NSURL URLWithString:HTML5File];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:HTML5FileUrl];
    
    // Set user agent to avoid redirection to YouTube mobile site
    [req setValue:BLYYoutubeExtractorWatchURLUserAgent
forHTTPHeaderField:@"User-Agent"];
    
    BLYHTTPConnection *connection = [[BLYHTTPConnection alloc] initWithRequest:[req copy]];
    
    connection.completionBlock = HTML5FileHookedCompletion;
    connection.displayActivityIndicator = !inBackground;
    
    [connection start];
}

- (NSError *)errorWithCode:(BLYYoutubeExtractorErrorCode)errorCode
   andLocalizedDescription:(NSString *)localDesc
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    
    [userInfo setValue:localDesc
                forKey:NSLocalizedDescriptionKey];
    
    return  [NSError errorWithDomain:@"com.blynde.blyyoutubeextractor"
                                code:errorCode
                            userInfo:userInfo];
}

@end
