//
//  Util.h
//  Quize
//
//  Created by anton bill on 12/11/13.
//  Copyright (c) 2013 anton bill. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <sys/sysctl.h>


@interface Util : NSObject

/* Indicator */
+ (void)showIndicator;
+ (void)hideIndicator;

/* NSString Management */
+ (NSString*)trim:(NSString*)strInput;
+ (NSString*)strip:(NSString*)strInput;

/* Date Management */
+ (NSString *)getTodayDate;
+ (NSString *)getTodayDateTime;
+ (NSString *) getAWSDateTime;
+ (NSString *) getISO8601DateTime;
+ (NSString *) getISO8601UtcDateTime;
+ (int) getTodayWeekDay;
+ (NSString *)getBeforeDate:(int)beforeDays;
+ (NSString *)getBeforeDateTime:(NSDate*) startDate beforeDays:(int)beforeDays ;

+ (NSDate*) convertString2Date:(NSString*) strDate;
+ (NSString*) convertCustomString2Date:(NSString*) dateString;

+ (NSString *)getAppName;
+ (NSString *)getAppVersion;
+ (NSString *)getAppBuild;
+ (NSString *)getPlateformString;
+ (NSString *)getSystemVersion;
+ (NSString *)getDeviceCountry;

+ (NSString *) downloadableContentPath;
+ (void) deleteFile:(NSString*)filePath;
+ (NSString*) getDocumentPath:(NSString*)fileName;

+ (UIImage*) getImagefromUrl:(NSString*)imageUrl;


@end
