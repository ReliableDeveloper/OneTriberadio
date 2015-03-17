//
//  NSString+Escaping.m
//  Blynde
//
//  Created by Jeremy Levy on 14/10/13.
//  Copyright (c) 2013 Jeremy Levy. All rights reserved.
//

#import "NSString+Escaping.h"

@implementation NSString (Escaping)

- (NSString *)bly_stringByAddingPercentEscapes
{
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

- (NSString *)bly_stringByRemovingPercentEscapes
{
    NSString * decoded = CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, (CFStringRef)@"", kCFStringEncodingUTF8));
    
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%0D%0A" withString:@"\n"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%40" withString:@"@"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%2C" withString:@","];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%3C" withString:@"<"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%3E" withString:@">"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%23" withString:@"#"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%25" withString:@"%"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%22" withString:@"\""];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%3F" withString:@"?"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%7B" withString:@"{"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%7D" withString:@"}"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
    decoded = [decoded stringByReplacingOccurrencesOfString:@"%3B" withString:@";"];
    
    return decoded;
}

- (NSString *)bly_stringByRemovingAccents
{
    NSData *asciiEncoded = [self dataUsingEncoding:NSASCIIStringEncoding
                              allowLossyConversion:YES];
    
    NSString *other = [[NSString alloc] initWithData:asciiEncoded
                                            encoding:NSASCIIStringEncoding];
    
    return other;
}

- (NSString *)bly_stringByRemovingSpaces
{
    NSString *pattern = @"\\s";
    
    return [self bly_stringByReplacingPattern:pattern withString:@""];
}

- (NSString *)bly_stringByRemovingParenthesisAndBracketsContent
{
    NSString *pattern = @"\\s*(\\([^)]*\\)|\\[[^\\]]*\\]|\\{[^}]*\\})";
    
    return [self bly_stringByReplacingPattern:pattern withString:@""];
}

- (NSString *)bly_stringByRemovingParenthesisAndBrackets
{
    NSString *pattern = @"\\(|\\)|\\[|\\]";
    
    return [self bly_stringByReplacingPattern:pattern withString:@""];
}

- (NSString *)bly_stringByReplacingMultipleConsecutiveSpacesToOne
{
    NSString *pattern = @"\\s{2,}";
    
    return [self bly_stringByReplacingPattern:pattern withString:@" "];
}

- (NSString *)bly_artistNameByRemovingRightPartOfComposedArtist
{
    NSString *pattern = @"(\\s&.+|\\s*,.+)";
    
    return [self bly_stringByReplacingPattern:pattern withString:@""];
}

- (NSString *)bly_stringByRemovingNonAlphanumericCharacters
{
    NSString *pattern = @"[^a-zA-z0-9\\s]";
    
    return [self bly_stringByReplacingPattern:pattern withString:@""];
}

- (NSString *)bly_stringByReplacingPattern:(NSString *)pattern
                                withString:(NSString *)replace
{
    NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                    options:NSRegularExpressionCaseInsensitive
                                                                      error:nil];
    
    return [reg stringByReplacingMatchesInString:self
                                         options:0
                                           range:NSMakeRange(0, [self length])
                                    withTemplate:replace];

}

@end
