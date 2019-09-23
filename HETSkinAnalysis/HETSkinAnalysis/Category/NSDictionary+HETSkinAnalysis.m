//
//  NSDictionary+HETSkinAnalysis.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/17.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "NSDictionary+HETSkinAnalysis.h"

FOUNDATION_EXTERN_INLINE NSString *HETSafeNonNilString(NSString *string)
{
    if (string && string.length > 0) {
        return string;
    }
    return @"";
}

FOUNDATION_EXTERN_INLINE NSDictionary *HETSafeDictionaryForKeyInDict(id object, NSString *key)
{
    if (!object || !key) {
        return nil;
    }
    
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary*)object;
        if ([dictionary.allKeys containsObject:key]) {
            id value =  dictionary[key];
            if (value && [value isKindOfClass:[NSDictionary class]]) {
                return value;
            }
        }
    }
    return nil;
}

FOUNDATION_EXTERN_INLINE NSString *HETSafeStringForKeyInDict(id object , NSString *key)
{
    if (object && key && [object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary*)object;
        if ([dictionary.allKeys containsObject:key]) {
            id value = dictionary[key];
            if (value && [value isKindOfClass:[NSString class]]) {
                return value;
            }
            else if (value && [value isKindOfClass:[NSNumber class]]) {
                return [(NSNumber*)value stringValue];
            }
        }
    }
    return @"";
}

FOUNDATION_EXTERN_INLINE NSInteger HETSafeIntegerForKeyInDict(id object , NSString *key)
{
    if (object && key && [object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary*)object;
        if ([dictionary.allKeys containsObject:key])
        {
            id value = dictionary[key];
            if (value && [value isKindOfClass:[NSNumber class]]) {
                return [(NSNumber*)value integerValue];
            }
        }
    }
    return 0;
}

FOUNDATION_EXTERN_INLINE NSArray *HETSafeArrayForKeyInDict(id object , NSString *key)
{
    if (object && key && [object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary*)object;
        if ([dictionary.allKeys containsObject:key])
        {
            id value = dictionary[key];
            if (value && [value isKindOfClass:[NSArray class]]) {
                return value;
            }
        }
    }
    return nil;
}

FOUNDATION_EXTERN_INLINE NSNumber *HETSafeNumberForKeyInDict(id object , NSString *key)
{
    if (object && key && [object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary*)object;
        if ([dictionary.allKeys containsObject:key])
        {
            id value = dictionary[key];
            if (value && [value isKindOfClass:[NSNumber class]]) {
                return value;
            }
            else if (value && [value isKindOfClass:[NSString class]]) {
                NSString *string = (NSString*)value;
                if ([string rangeOfString:@"."].location != NSNotFound) {
                    return @(string.floatValue);
                }
                else
                {
                    return @(string.integerValue);
                }
            }
        }
    }
    return nil;
}


@implementation NSDictionary (HETSkinAnalysis)

@end

@implementation NSMutableDictionary (HETSkinAnalysis)
- (void)setSafeObject:(id)anObject forKey:(id<NSCopying>)aKey;
{
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}

-  (NSString*)sortedParamsString
{
    NSArray *keys = [self allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *result = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [result appendFormat:@"%@=%@",key,[self objectForKey:key]];
        [result appendString:@"&"];
    }
    if (result.length > 1) {
        return [result substringToIndex:result.length-1];
    }
    return nil;
}
@end
