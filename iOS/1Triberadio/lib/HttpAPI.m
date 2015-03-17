//
//  HttpAPI.m
//  BarcodeApp
//
//  Created by iOSDev on 3/4/14.
//  Copyright (c) 2014 iOSDev. All rights reserved.
//

#import "HttpAPI.h"
#import "Util.h"
@interface HttpAPI()

@end

@implementation HttpAPI

//+ (void) sendRequest:(BOOL) isPost paramDic:(NSMutableDictionary*)paramDic completionBlock: (void (^)(BOOL, NSDictionary *, NSError *))completionBlock {
//    
//    AwsProductApi* aws = [[AwsProductApi alloc] init];
//    
//    NSString* urlString = [aws getItemByAsin:[paramDic objectForKey:PARAM_ITEM_ID]];
//    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
//
////    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
////    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    
//    [Util showIndicator];
//    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
////                               NSString *json_string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                               NSDictionary *resultDic = [XMLReader dictionaryForXMLData:data error:nil];
//                               
//                               completionBlock(YES, resultDic, error);
//                               [Util hideIndicator];
//                           }];
//}

//+ (void) sendLoginRequest:(BOOL) isPost url:(NSString*) urlString completionBlock: (void (^)(BOOL, NSData *, NSError *))completionBlock {
//    
//    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
//    [Util showIndicator];
//    
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                               completionBlock(YES, data, error);
//                               [Util hideIndicator];
//                           }];
//}
+ (void) sendLoginRequest:(BOOL) isPost url:(NSString*) urlString completionBlock: (void (^)(BOOL, NSData *, NSError *))completionBlock {
    
   // NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
 NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [Util showIndicator];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               completionBlock(YES, data, error);
                               [Util hideIndicator];
                           }];
}

+ (void) sendLoginRequestNoIndicator:(BOOL) isPost url:(NSString*) urlString completionBlock: (void (^)(BOOL, NSData *, NSError *))completionBlock {
    
    // NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               completionBlock(YES, data, error);
                           }];
}

@end
