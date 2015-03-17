//
//  Util.m
//  Quize
//
//  Created by anton bill on 12/11/13.
//  Copyright (c) 2013 anton bill. All rights reserved.
//

#import "Util.h"
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import "CustomIOS7AlertView.h"

@implementation Util

static CustomIOS7AlertView *waitAlert;

/***************************************************************/
/***************************************************************/
/* Indicator Management *****************************************/
/***************************************************************/
/***************************************************************/

+ (void) showIndicator
{
    if (waitAlert == nil) {
        waitAlert =  [[CustomIOS7AlertView alloc] init];
        UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        loadingView.backgroundColor = [UIColor blackColor];
        loadingView.layer.cornerRadius = 5.0;
        loadingView.layer.borderWidth  = 0;
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.center = loadingView.center;
        [activityView startAnimating];
        
        [loadingView addSubview:activityView];
        
        // Add some custom content to the alert view
        [waitAlert setContainerView:loadingView];
        
        // Modify the parameters
        [waitAlert setButtonTitles:[NSMutableArray arrayWithObjects:nil]];
        
        // You may use a Block, rather than a delegate.
        [waitAlert setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
            [alertView close];
        }];
    }
    
    [waitAlert show];
    [waitAlert setUseMotionEffects:true];
}

+ (void) hideIndicator
{
    [waitAlert close];
}

/***************************************************************/
/***************************************************************/
/* NSString Management *****************************************/
/***************************************************************/
/***************************************************************/

+ (NSString*)trim:(NSString*)strInput
{
    NSString *ret = [strInput stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return ret;
}

+ (NSString*)strip:(NSString*)strInput
{
    NSString *ret = @"";
    for (int temp = 0; temp < [strInput length]; temp++){ //run through the string
        unichar charItem = [strInput characterAtIndex: temp];
        if (charItem == '\n')
            charItem = ' ';
        
        ret = [ret stringByAppendingString:[NSString stringWithFormat:@"%C", charItem]];
    }
    ret = [ret stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    ret = [self trim:ret];
    ret = [ret stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ret = [self stringByStrippingHTML:ret];
    return ret;
}

+ (NSString *) stringByStrippingHTML:(NSString*)string {
    NSRange r;
    NSString *s = string;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

/***************************************************************/
/***************************************************************/
/* Date  Management ********************************************/
/***************************************************************/
/***************************************************************/

+(NSString *)getTodayDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *curDate = [dateFormatter stringFromDate:[NSDate date]];
    
    return curDate;
}

+(NSString *)getTodayDateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *curDate = [dateFormatter stringFromDate:[NSDate date]];
    
    return curDate;
}

+ (NSString *) getAWSDateTime
{
    NSDate *today = nil;
    NSString *dateString = nil;
    
    NSString *awsURL = @"http://s3.amazonaws.com";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:awsURL]];
    [request setHTTPMethod:@"HEAD"];
    
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        dateString = [[response allHeaderFields] objectForKey:@"Date"];
        dateString = [dateString stringByReplacingOccurrencesOfString:@"GMT" withString:@"+0000"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss z";
        df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        today = [df dateFromString:dateString];
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh-mm-ss"];
    NSString *strToday = [dateFormatter stringFromDate:today];
    
    return strToday;
}

+ (NSString *) getISO8601DateTime
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *curDate = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"hh:mm:ss"];
    curDate = [curDate stringByAppendingFormat:@"%@%@", @"T", [dateFormatter stringFromDate:[NSDate date]]];
    
    NSDate* sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    int offset = (int)interval / 3600;
    if (offset >= 0) {
        if (offset > 9) {
            curDate = [curDate stringByAppendingFormat:@"+%d00", offset];
        } else {
            curDate = [curDate stringByAppendingFormat:@"+0%d00", offset];
        }
    } else {
        if (abs(offset) > 9) {
            curDate = [curDate stringByAppendingFormat:@"-%d00", abs(offset)];
        } else {
            curDate = [curDate stringByAppendingFormat:@"-0%d00", abs(offset)];
        }
        
    }
    
    return curDate;
}

+ (NSString *) getISO8601UtcDateTime
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *curDate = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    curDate = [curDate stringByAppendingFormat:@"T%@.000Z", [dateFormatter stringFromDate:[NSDate date]]];
    return curDate;
}

+(int) getTodayWeekDay
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setFirstWeekday:0];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int weekday = [comps weekday];
    int europeanWeekday = ((weekday + 5) % 7) + 1;
    
    return europeanWeekday;
}

+ (NSString *)getBeforeDate:(int)beforeDays {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *today = [dateFormatter dateFromString:[self getTodayDate]];
    
    NSDate *beforeDate = [today dateByAddingTimeInterval:-beforeDays * 24 * 60 * 60];
    NSString *beforeDateString = [dateFormatter stringFromDate:beforeDate];

    return beforeDateString;
}

+ (NSString *)getBeforeDateTime:(NSDate*) startDate beforeDays:(int)beforeDays {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *beforeDate = [startDate dateByAddingTimeInterval:-beforeDays * 24 * 60 * 60];
    NSString *beforeDateString = [dateFormatter stringFromDate:beforeDate];
    
    return beforeDateString;
}

+ (NSDate*) convertString2Date:(NSString*) dateString{

    NSRange range = [dateString rangeOfString : @"."];
    if (range.location != NSNotFound ) {
        dateString = [dateString substringWithRange:NSMakeRange(0, range.location)];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:dateString];

    return dateFromString;
}

+ (NSString*) convertCustomString2Date:(NSString*) dateString{
    
    NSDate *dateFromString = [self convertString2Date:dateString];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM dd yyyy"];
    
    NSString *convertedDateString = [dateFormatter stringFromDate:dateFromString];
    
    return convertedDateString;
}


+ (UIImage*) getImagefromUrl:(NSString*)imageUrl
{
    imageUrl = [NSString stringWithFormat:@"http://%@", imageUrl];
    imageUrl = [Util strip:imageUrl];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
    if (image == nil) {
        image = [UIImage imageNamed:@"placeholderimage.png"];
    }
    return image;
}



+ (NSString*)getDeviceCountry
{
    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    return countryCode;
}

+ (NSString *)getAppName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (NSString *)getAppVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getAppBuild
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString *)platform
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

+ (NSString *)getPlateformString
{
    NSString *platform = [self platform];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (Global)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (Global)";
    
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad-3G (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"iPad3,4"]) return @"iPad-4G (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"]) return @"iPad-4G (GSM)";
    if ([platform isEqualToString:@"iPad3,6"]) return @"iPad-4G (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"]) return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"]) return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad2,5"]) return @"iPad mini-1G (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPad mini-1G (GSM)";
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPad mini-1G (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad mini-2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPad mini-2G (Cellular)";
    
    if ([platform isEqualToString:@"i386"]) return @"Simulator";
    if ([platform isEqualToString:@"x86_64"]) return @"Simulator";
    
    return platform;
}

+ (NSString *)getSystemVersion
{
    return [UIDevice currentDevice].systemVersion;
}

+ (void) deleteFile:(NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    NSLog(@"Path to file: %@", filePath);
    NSLog(@"File exists: %d", fileExists);
    NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:filePath]);
    if (fileExists)
    {
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (!success) NSLog(@"Error: %@", [error localizedDescription]);
    }
}

+ (NSString *) downloadableContentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    directory = [directory stringByAppendingPathComponent:@"Downloads"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:directory] == NO) {
        
        NSError *error;
        if ([fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
            NSLog(@"Error: Unable to create directory: %@", error);
        }
        
        NSURL *url = [NSURL fileURLWithPath:directory];
        // exclude downloads from iCloud backup
        if ([url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error] == NO) {
            NSLog(@"Error: Unable to exclude directory from backup: %@", error);
        }
    }
    
    return directory;
}

+ (NSString*) getDocumentPath:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
}
@end
