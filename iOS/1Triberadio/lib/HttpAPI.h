//
//  HttpAPI.h
//  BarcodeApp
//
//  Created by iOSDev on 3/4/14.
//  Copyright (c) 2014 iOSDev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpAPI : NSObject 

//+ (void) sendRequest:(BOOL) isPost paramDic:(NSMutableDictionary*)paramDic completionBlock: (void (^)(BOOL, NSDictionary *, NSError *))completionBlock ;

+ (void) sendLoginRequest:(BOOL) isPost url:(NSString*) urlString completionBlock: (void (^)(BOOL, NSData *, NSError *))completionBlock;

+ (void) sendLoginRequestNoIndicator:(BOOL) isPost url:(NSString*) urlString completionBlock: (void (^)(BOOL, NSData *, NSError *))completionBlock;
@end
